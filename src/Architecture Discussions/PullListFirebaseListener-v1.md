# PullList Firebase Listener — Architecture Discussion v1

## Goal

Design and plan a new screen for the RedDoor iOS app that displays a `PullListV2` (an updated version of `RDList`), with real-time Firestore listeners so that multiple collaborators viewing the same list simultaneously see each other's changes live. No code has been written yet — this is entirely a planning/architecture discussion.

## Instructions

- **Do not modify or reference the old `RDListViewModel`** — it is considered outdated. The new screen will use a standalone `PullListV2ViewModel`, not extending the existing inheritance chain (`PullListViewModel`/`InstalledListViewModel` extending `RDListViewModel`).
- **Use v2 types throughout**: `ItemV2`, `ModelV2`, `PullListV2` (yet to be created), `ItemWithModelV2` (yet to be created).
- **Use the existing repository pattern** (`GenericRepository`, `ItemRepository`) and extend it with a new `PullListRepository`.
- The screen will have a **bottom sheet for adding items**, driven by a separate `AddItemToPullListViewModel`.
- **No per-item Firestore listeners** are needed — items are fetched one-shot when rooms change. A full audit of items/models happens at submit time when a user locks in changes.
- The listener strategy chosen is **Option A (room-scoped re-fetch)**: on any `documentChanges` event for a room, re-fetch all items+models for that specific room only (no granular diffing of `itemModelIdMap`).

## Discoveries

**Firestore data structure:**
- Pull lists live at `pull_lists/{listId}` (top-level collection)
- Rooms are a subcollection: `pull_lists/{listId}/rooms/{roomId}`
- Items live at top-level `items/` collection
- Models live at top-level `models/` collection
- `Room.itemModelIdMap: [String: String]` maps `itemId → modelId` and is stored directly on the Room document — item additions/removals from a room are captured by the rooms subcollection listener automatically (no need for item-level listeners)

**Listener architecture:**
- A single `addSnapshotListener` on `pull_lists/{listId}/rooms` covers both "room added/removed" and "item added/removed from room's map"
- `QuerySnapshot.documentChanges` provides granular `.added`, `.modified`, `.removed` events — no need to re-fetch all rooms on every change
- On `.modified`: re-fetch all items+models for that room only (replace that room's dict entry)
- On `.added`: fetch items+models for the new room
- On `.removed`: remove the room's entry from the dict
- `ListenerRegistration` must be stored and `.remove()` called on ViewModel `deinit`

**ViewModel state shape:**
```swift
@Observable class PullListV2ViewModel {
    var selectedList: PullListV2
    var rooms: [Room] = []
    var itemsByRoom: [String: [ItemWithModelV2]] = [:]  // roomId → [ItemWithModelV2]
    private var modelsCache: [String: ModelV2] = [:]    // shared across rooms, avoids re-fetching same model
    private var roomsListener: ListenerRegistration?
    deinit { roomsListener?.remove() }
}
```

**Write operation (add item to room):**
- Touches two documents → must use a `WriteBatch`
- `PullListRepository.addItemToRoom(itemId, modelId, roomId, listId, inBatch:)` → updates `Room.itemModelIdMap[itemId] = modelId`
- `ItemRepository.markItemAddedToList(itemId, listId, inBatch:)` → updates `Item.isAvailable = false`, `Item.listId = listId`
- `AddItemToPullListViewModel` creates the batch, calls both repos, commits — neither repo commits itself

**Timing clarification:** The listener update is triggered by the Firestore write completing, NOT by sheet dismissal. These are independent — dismiss the sheet on write success, let the listener handle the display update separately.

**Subcollection gap in `GenericRepository`:** `GenericRepository` only handles top-level collections via `db.collection(T.collectionName)`. Rooms are a subcollection, so `PullListRepository` must extend `GenericRepository<PullListV2>` with additional methods that dynamically construct the subcollection reference using a `listId` parameter.

## Accomplished

- Analyzed existing models (`RDList`, `Room`, `Item`, `ItemWithModel`)
- Analyzed existing ViewModels (`RDListViewModel`, `RoomViewModel`, `PullListViewModel`)
- Analyzed existing repository pattern (`GenericRepository`, `ItemRepository`, `ModelRepository`)
- Confirmed Firestore collection/subcollection structure
- Decided on listener architecture (rooms subcollection listener, room-scoped re-fetch on change)
- Decided on ViewModel separation (`PullListV2ViewModel` for display, `AddItemToPullListViewModel` for writes)
- Decided on repository extension pattern for subcollections
- Confirmed `GenericRepository` has no dead `self.batch` property — it is already clean; all batch methods take an external `WriteBatch` parameter

## Open Questions (before implementation begins)

1. Should `PullListV2` mirror all `RDList` fields (address, installDate, uninstallDate, status, client, roomIds) or restructure? Should `roomIds` remain on the list document or be dropped in favor of the subcollection as single source of truth?
2. Where should `ItemWithModelV2` live — `Models-v2/` folder?
3. Should `AddItemToPullListViewModel` also handle item removal, or will that be a separate ViewModel?

## Relevant Files / Directories

```
src/Models/
  RDList.swift               — v1 list model (reference only, being superseded)
  Room.swift                 — Room model with itemModelIdMap (still in use)
  Item.swift                 — v1 Item model
  Model.swift                — contains ItemWithModel v1 bundled struct

src/Models-v2/
  Item-v2.swift              — ItemV2 model (use this)
  Model-v2.swift (implied)   — ModelV2 model (use this)
  [PullListV2.swift]         — TO BE CREATED
  [ItemWithModelV2.swift]    — TO BE CREATED

src/Repositories/
  GenericRepository.swift    — base repo class (clean — no dead self.batch property)
  ItemRepository.swift       — needs markItemAddedToList(inBatch:) added
  ModelRepository.swift      — may need get methods for model fetching
  [PullListRepository.swift] — TO BE CREATED (subcollection support + listener)

[New ViewModels to create]
  PullListV2ViewModel.swift         — owns rooms listener, itemsByRoom dict, modelsCache
  AddItemToPullListViewModel.swift  — owns batch write logic for adding item to room
```
