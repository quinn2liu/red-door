# Firebase iOS Architecture Summary (v1)

## Problems & Considerations to Solve

1. **Repeated CRUD boilerplate** — the same create, read, update, delete logic was being duplicated across every document-type service file with no shared base.
2. **Bloated ViewModels** — document-based ViewModels that owned all logic for a given type regardless of which screen needed it, growing indefinitely.
3. **Concurrency crashes** — mutable state being accessed simultaneously from multiple async contexts, causing data races.
4. **No atomic operations** — no clean way to coordinate writes across multiple collections that either all succeed or all fail together.
5. **Stale data from other users** — no strategy for detecting when another user changes a document underneath you mid-session.
6. **Expensive Firebase Storage downloads** — unlike Firestore document reads (billed per operation at ~$0.0000018 each), Storage downloads are billed per GB at ~$0.12/GB, making redundant image downloads a meaningful cost driver.

## NOTE:
- This is an initial summary from brainstorming with an LLM. Several areas will need to be ironed out (like realtime listeners)
---

## The Architecture and How Each Problem Is Solved

### 1. Generic Base Repository — Repeat Code

A single generic `Repository<T: Codable>` class provides all standard CRUD operations. Document-specific repositories inherit from it and only define what's unique to their collection. All repositories are plain `class` types — none require `actor` isolation because they hold no mutable state after init (the `CollectionReference` is immutable and the Firestore SDK is internally thread-safe). The one exception is `FirebaseImageActor`, which is a standalone `actor` and does not inherit from `Repository`.

Each operation comes in three flavors: standalone async, batch-participatory, and transaction-participatory:

```swift
class Repository<T: Codable> {
    let collection: CollectionReference

    init(collectionPath: String) {
        self.collection = Firestore.firestore().collection(collectionPath)
    }

    // Standalone async
    func set(_ model: T, id: String) async throws {
        try collection.document(id).setData(from: model)
    }

    func delete(id: String) async throws {
        try await collection.document(id).delete()
    }

    // Batch participatory
    func set(_ model: T, id: String, inBatch batch: WriteBatch) throws {
        try batch.setData(from: model, forDocument: collection.document(id))
    }

    func delete(id: String, inBatch batch: WriteBatch) {
        batch.deleteDocument(collection.document(id))
    }

    // Transaction participatory
    func set(_ model: T, id: String, in transaction: Transaction) throws {
        try transaction.setData(from: model, forDocument:
            Firestore.firestore().collection(collection.collectionID).document(id)
        )
    }

    func delete(id: String, in transaction: Transaction) {
        transaction.deleteDocument(
            Firestore.firestore().collection(collection.collectionID).document(id)
        )
    }
}
```

A concrete repository only adds what's specific to its collection:

```swift
class ItemRepository: Repository<Item> {
    func getItem(id: String) async throws -> Item {
        do {
            let snapshot = try await collection.document(id).getDocument()
            return try snapshot.data(as: Item.self)
        } catch let error as DecodingError {
            throw AppError.decodingFailed
        } catch {
            throw AppError.from(error)
        }
    }

    func updateStock(id: String, quantity: Int) async throws {
        try await collection.document(id).updateData(["stock": quantity])
    }

    func updateStock(id: String, quantity: Int, in transaction: Transaction) {
        transaction.updateData(
            ["stock": quantity],
            forDocument: Firestore.firestore().collection("items").document(id)
        )
    }
}
```

---

### 2. Screen-Specific ViewModels — Bloated ViewModels

Instead of one ViewModel owning all logic for a document type, each ViewModel only contains what its specific screen needs. Repositories are injected at init and called directly.

```swift
// ❌ Before — one ViewModel owns everything, grows forever
class ItemViewModel: ObservableObject {
    func createItem() { ... }
    func deleteItem() { ... }
    func archiveItem() { ... }
    func shareItem() { ... }
}

// ✅ After — each ViewModel is small and focused on its screen
class ItemDetailViewModel: ObservableObject {
    private let itemRepo: ItemRepository

    func archiveItem(id: String) async throws {
        try await itemRepo.set(/* archived item */, id: id)
    }
}

class ItemCheckoutViewModel: ObservableObject {
    private let itemRepo: ItemRepository
    private let orderRepo: OrderRepository

    func purchaseItem(id: String, quantity: Int) async throws {
        // only checkout-relevant logic lives here
    }
}
```

---

### 3. Actors — Concurrency Safety Where It's Needed

All document repositories are plain `class` types. They hold no mutable state — only an immutable `CollectionReference` — so there is nothing to protect from concurrent access, and `actor` would add overhead and unnecessary `await`s for no benefit.

`FirebaseImageActor` is the sole `actor` in the architecture. It exists specifically to protect its image cache from concurrent access, and it does not inherit from `Repository`.

```swift
actor FirebaseImageActor {
    // NSCache handles memory pressure automatically (evicts under low memory)
    // and is internally thread-safe — actor isolation protects the surrounding
    // check-then-fetch logic from racing, which NSCache alone cannot guarantee
    private let cache = NSCache<NSString, UIImage>()

    func getImage(path: String) async throws -> UIImage {
        if let cached = cache.object(forKey: path as NSString) {
            return cached
        }
        let ref = Storage.storage().reference(withPath: path)
        let data = try await ref.data(maxSize: 10 * 1024 * 1024)
        guard let image = UIImage(data: data) else { throw AppError.decodingFailed }
        cache.setObject(image, forKey: path as NSString)
        return image
    }

    func invalidate(path: String) {
        cache.removeObject(forKey: path as NSString)
    }
}
```

`NSCache` is used instead of a plain dictionary because it evicts entries automatically when the OS signals memory pressure, preventing the app from being killed on memory-constrained devices.

---

### 4. Batches and Transactions — Atomic Operations

**Batches** handle multiple writes across repositories that need to succeed or fail together, with no reads required:

```swift
func deleteItemAndCleanup(id: String) async throws {
    let batch = Firestore.firestore().batch()

    itemRepo.delete(id: id, inBatch: batch)
    userRepo.removeItemReference(id: id, inBatch: batch)

    try await batch.commit()
}
```

**Transactions** handle read-then-write flows where data must be validated before writing. `FirestoreService` wraps Firebase's callback-based transaction API into a clean async interface so ViewModels never need to import Firebase directly.

To avoid memory management issues, repositories are captured directly in the transaction closure rather than capturing `self`. Since repositories hold no per-instance mutable state, capturing them is safe — no retain cycle, and no dangling reference if the ViewModel deallocates mid-transaction:

```swift
class FirestoreService {
    private let db = Firestore.firestore()

    func runTransaction<T>(_ block: @escaping (Transaction) throws -> T) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            db.runTransaction({ transaction, errorPointer in
                do {
                    return try block(transaction) as AnyObject
                } catch {
                    errorPointer?.pointee = error as NSError
                    return nil
                }
            }) { result, error in
                if let error { continuation.resume(throwing: AppError.from(error)) }
                else if let result = result as? T { continuation.resume(returning: result) }
                else { continuation.resume(throwing: AppError.unknown(NSError())) }
            }
        }
    }
}

// ViewModel — capture the repo directly, not self
func purchaseItem(id: String, quantity: Int) async throws {
    let itemRepo = self.itemRepo
    try await firestoreService.runTransaction { transaction in
        let item = try itemRepo.getItem(id: id, in: transaction)
        guard item.stock >= quantity else {
            throw AppError.conflict(reason: "Not enough stock.")
        }
        itemRepo.updateStock(id: id, quantity: item.stock - quantity, in: transaction)
    }
}
```

---

### 5. Real-Time Listeners — Stale Data from Other Users

Listeners are used **only when a user is actively viewing a single document**. List views use one-time fetches, which are cheap at ~$0.0000018 per read and avoid the fan-out cost of a collection listener (where every write to any document in the collection triggers a re-read for every active listener).

ViewModels expose `activate()`/`deactivate()` rather than SwiftUI-named methods. The view calls these from `onAppear`/`onDisappear`, but the ViewModel has no dependency on SwiftUI concepts — making it independently testable with a mock repository and no view required:

```swift
@Observable
class ItemDetailViewModel {
    @State var item: Item?
    @State var error: AppError?

    private let itemRepo: ItemRepository
    let id: String

    init(id: String, itemRepo: ItemRepository) {
        self.id = id
        self.itemRepo = itemRepo
    }

    func activate() {
        itemRepo.startListening(to: id) { [weak self] result in
            switch result {
            case .success(let item): self?.item = item
            case .failure(let error): self?.error = AppError.from(error)
            }
        }
    }

    func deactivate() {
        itemRepo.stopListening(to: id)
    }
}

struct ItemDetailView: View {
    @StateObject var viewModel: ItemDetailViewModel

    var body: some View {
        ItemContentView(item: viewModel.item)
            .onAppear { viewModel.activate() }
            .onDisappear { viewModel.deactivate() }
    }
}
```

Listener registration is managed on `@MainActor` since it is always triggered by SwiftUI lifecycle events:

```swift
class ItemRepository: Repository<Item> {
    private var listeners: [String: ListenerRegistration] = [:]

    @MainActor
    func startListening(to id: String, onUpdate: @escaping (Result<Item, Error>) -> Void) {
        guard listeners[id] == nil else { return }
        let listener = collection.document(id).addSnapshotListener { snapshot, error in
            if let error {
                onUpdate(.failure(AppError.from(error)))
                return
            }
            do {
                let item = try snapshot!.data(as: Item.self)
                onUpdate(.success(item))
            } catch {
                onUpdate(.failure(AppError.decodingFailed))
            }
        }
        listeners[id] = listener
    }

    @MainActor
    func stopListening(to id: String) {
        listeners[id]?.remove()
        listeners.removeValue(forKey: id)
    }
}
```

For write operations that validate data before committing, transactions serve as a safety net — they read fresh data from Firestore at commit time, so even if the listener hasn't yet reflected the latest state, the transaction will catch a conflict and fail cleanly.

---

### 6. System-Wide Error Handling

All Firebase errors, decoding errors, and domain errors are mapped to a single `AppError` enum at the repository boundary. ViewModels never see raw Firestore errors or `NSError` — they only ever handle `AppError`. This means no Firebase imports in ViewModels, no scattered `NSError` switch statements, and the UI can bind directly to `error.errorDescription`.

```swift
enum AppError: LocalizedError {
    case notFound
    case permissionDenied
    case networkUnavailable
    case conflict(reason: String)
    case decodingFailed
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .notFound:             return "This item no longer exists."
        case .permissionDenied:     return "You don't have access to this."
        case .networkUnavailable:   return "Check your connection and try again."
        case .conflict(let reason): return reason
        case .decodingFailed:       return "Something went wrong loading this data."
        case .unknown:              return "An unexpected error occurred."
        }
    }
}

extension AppError {
    static func from(_ error: Error) -> AppError {
        let nsError = error as NSError
        guard nsError.domain == FirestoreErrorDomain else {
            if error is DecodingError { return .decodingFailed }
            return .unknown(error)
        }
        switch FirestoreErrorCode(rawValue: nsError.code) {
        case .notFound:         return .notFound
        case .permissionDenied: return .permissionDenied
        case .unavailable:      return .networkUnavailable
        default:                return .unknown(error)
        }
    }
}
```

Repositories convert errors at the boundary so the type is clean by the time it reaches a ViewModel:

```swift
func getItem(id: String) async throws -> Item {
    do {
        let snapshot = try await collection.document(id).getDocument()
        return try snapshot.data(as: Item.self)
    } catch let error as DecodingError {
        throw AppError.decodingFailed
    } catch {
        throw AppError.from(error)
    }
}
```

ViewModels handle errors without any Firebase knowledge:

```swift
func loadItem(id: String) async {
    do {
        item = try await itemRepo.getItem(id: id)
    } catch let error as AppError {
        self.error = error  // @Published — UI reacts automatically
    }
}
```

---

### 7. Image Caching — Expensive Storage Downloads

Firebase Storage charges ~$0.12/GB for egress. `FirebaseImageActor` (a standalone `actor`) maintains an `NSCache`-backed image cache keyed by storage path. Images are fetched once and served from cache on subsequent requests. `NSCache` is used instead of a plain dictionary because it evicts entries under memory pressure automatically, preventing the app from being killed on memory-constrained devices.

```swift
actor FirebaseImageActor {
    private let cache = NSCache<NSString, UIImage>()

    func getImage(path: String) async throws -> UIImage {
        if let cached = cache.object(forKey: path as NSString) {
            return cached
        }
        let ref = Storage.storage().reference(withPath: path)
        let data = try await ref.data(maxSize: 10 * 1024 * 1024)
        guard let image = UIImage(data: data) else { throw AppError.decodingFailed }
        cache.setObject(image, forKey: path as NSString)
        return image
    }

    func invalidate(path: String) {
        cache.removeObject(forKey: path as NSString)
    }
}
```

`FirebaseImageActor` does not inherit from `Repository<T>` — it is a standalone `actor`, and actors cannot inherit from classes in Swift.
