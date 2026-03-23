# AGENTS.md - RedDoor Development Guide

Guidelines for agentic coding agents working on the RedDoor iOS project.

## Project Overview

- **Type**: iOS/macOS SwiftUI Application
- **UI Framework**: SwiftUI
- **Backend**: Firebase (Firestore, Storage)
- **Architecture**: MVVM with `@Observable` macro

## Directory Structure

```
src/
├── Models/           # Data models (Model, Item, Room, RDList, etc.)
├── ViewModels/       # ViewModels using @Observable macro
├── Views/            # SwiftUI views organized by feature
│   ├── Components/   # Reusable UI components
│   ├── Model/        # Model-related views
│   ├── Item/         # Item-related views
│   ├── PullList/     # Pull list views
│   ├── InstalledList/ # Installed list views
│   └── Room/         # Room-related views
├── Utils/            # Utilities (Navigation, PDF, Scanner, Address)
├── Firebase/         # Firebase integrations
├── Errors/           # Custom error types
└── Assets.xcassets/ # Images and colors
```

## Build, Lint, and Test Commands

### Building
```bash
xcodebuild -project RedDoor.xcodeproj -scheme RedDoor -configuration Debug build
xcodebuild -workspace RedDoor.xcworkspace -scheme RedDoor -configuration Debug build
xcodebuild -project RedDoor.xcodeproj -scheme RedDoor -destination 'platform=iOS Simulator,name=iPhone 15' build
```

### Running the App
```bash
xcrun simctl boot "iPhone 15"
xcodebuild -project RedDoor.xcodeproj -scheme RedDoor -destination 'platform=iOS Simulator,name=iPhone 15' build
xcrun simctl install booted build/Build/Products/Debug-iphonesimulator/RedDoor.app
xcrun simctl launch booted com.quinnliu.reddoor
```

### Linting
No SwiftLint configuration exists. Project relies on Xcode's built-in warnings.

### Testing
**No tests currently exist.** To add tests:
```bash
# Run all tests
xcodebuild test -project RedDoor.xcodeproj -scheme RedDoor
# Run single test class
xcodebuild test -project RedDoor.xcodeproj -scheme RedDoor -only-testing:ModelTests
# Run single test method
xcodebuild test -project RedDoor.xcodeproj -scheme RedDoor -only-testing:ModelTests/testModelCreation
```

## Code Style Guidelines

### Imports
Grouped by framework, alphabetical within groups:
```swift
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import Foundation
import SwiftUI
```

### Header
```swift
//
//  Filename.swift
//  RedDoor
//
//  Created by Quinn Liu on MM/DD/YY.
//
```

### Naming Conventions
- **Types**: PascalCase (`Model`, `ModelViewModel`, `PullListValidationError`)
- **Properties/Variables**: camelCase (`selectedModel`, `itemCount`, `isLoading`)
- **Constants**: camelCase (`colorMap`, `typeOptions`)
- **Enums**: PascalCase with camelCase members (`case camera`, `case photoLibrary`)
- **Error Enums**: PascalCase with descriptive cases

### SwiftUI Conventions
- Use `@Observable` macro (iOS 17+) for ViewModels
- Views: struct-based with `some View`
- Use `@Environment` for dependency injection
- Use `@State` for local view state, `@Binding` for two-way binding

### Error Handling
- Use Swift's `try`/`throw` pattern
- Custom errors in `src/Errors/` using enums
- Firebase operations use `do`/`catch`:
  ```swift
  do {
      try modelDocumentRef.setData(from: selectedModel)
  } catch {
      print("Error updating model: \(error)")
  }
  ```
- Use `try await` for async operations with proper error propagation

### Type Annotations
- Explicit types for function parameters and return types
- Use `some View` for view return types
- Type inference acceptable for local variables

### Access Control
- Use `private` for implementation details
- Use `final` for classes not intended for subclassing

### Documentation
- Use `// MARK:` for organizing code sections
- Add doc comments for public APIs

### Best Practices
1. **Async/Await**: Prefer Swift's concurrency over completion handlers
2. **Main Actor**: Use `@MainActor` for UI updates
3. **Firebase**: Use batched writes for multiple operations
4. **Images**: Compress images before upload (JPEG 0.3 quality)
5. **Navigation**: Use `NavigationCoordinator` for tab-based navigation

### Common Patterns
- **Model + ViewModel pairs**: `Model.swift` + `ModelViewModel.swift`
- **Document Views**: `XxxDocumentView.swift`
- **Detail Views**: `XxxDetailView.swift`
- **Edit Sheets**: `EditXxxSheet.swift`

### Firebase Conventions
- Collections: lowercase plural (`models`, `items`, `rooms`)
- Documents: use UUID strings as IDs
- Images: stored in `model_images/{modelId}/{imageId}`
- Use batched writes for atomic operations

## Important Notes
- Requires `GoogleService-Info.plist` for Firebase
- Uses tab-based navigation with `NavigationCoordinator`
- No authentication implemented (see TODO in codebase)
- Target iOS 17+ for `@Observable` support
