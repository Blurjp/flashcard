# FlashcardMVP - Project Overview

A comprehensive guide to understanding the FlashcardMVP codebase.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    FlashcardMVP App                      │
│                    (SwiftUI + MVVM)                      │
└─────────────────────────────────────────────────────────┘
                            │
            ┌───────────────┼───────────────┐
            │               │               │
        ┌───▼────┐    ┌────▼─────┐   ┌────▼──────┐
        │ Views  │◄───│ViewModels│◄──│  Models   │
        └────────┘    └──────────┘   └───────────┘
                            │
                      ┌─────▼─────┐
                      │   Core    │
                      │   Data    │
                      └─────┬─────┘
                            │
                      ┌─────▼─────┐
                      │ CloudKit  │
                      │   Sync    │
                      └───────────┘
```

## Component Breakdown

### 1. Application Layer

**File**: `FlashcardMVPApp.swift`

Entry point of the application. Responsibilities:
- Initialize Core Data stack
- Manage app lifecycle
- Handle onboarding state
- Inject dependencies into views

```swift
@main
struct FlashcardMVPApp: App {
    let persistenceController = PersistenceController.shared
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    // ...
}
```

### 2. Persistence Layer

**File**: `Persistence/PersistenceController.swift`

Core Data stack manager with CloudKit integration:
- Singleton pattern for app-wide access
- NSPersistentCloudKitContainer for iCloud sync
- In-memory store support for testing/previews
- Automatic merge from remote changes

**Key Methods**:
- `init(inMemory:)`: Initialize store
- `save()`: Save context changes
- `newBackgroundContext()`: Create background contexts

**Files**: `Models/Deck.swift`, `Models/Card.swift`, `Models/ReviewLog.swift`

NSManagedObject subclasses with convenience methods:
- **Deck**: Collection of cards
- **Card**: Individual flashcard with SRS metadata
- **ReviewLog**: History of user reviews

### 3. Business Logic Layer

**File**: `SRS/Scheduler.swift`

Spaced Repetition System implementation:
- SM-2 inspired algorithm
- Rating enum: Again, Hard, Good, Easy
- SRSResult struct for scheduling updates
- Pure functions for testability

**Core Algorithm**:
```swift
func schedule(
    now: Date,
    repetition: Int,
    intervalDays: Int,
    easeFactor: Double,
    rating: Rating
) -> SRSResult
```

### 4. ViewModel Layer

ViewModels manage business logic and state for views:

#### DeckListViewModel
- CRUD operations for decks
- Create sample deck for onboarding
- Uses view context for immediate UI updates

#### DeckDetailViewModel
- Manage cards within a deck
- Filter/search functionality
- Due card calculations
- Delete operations

#### CardEditorViewModel
- Create/edit card logic
- Image handling and compression
- Form validation
- Dual mode: create or edit

#### ReviewSessionViewModel
- Session state management
- Progress tracking
- SRS algorithm integration
- Statistics calculation
- Review log creation

### 5. View Layer

SwiftUI views following single responsibility principle:

#### DeckListView
- Home screen
- Deck list with FetchRequest
- Empty state handling
- Navigation to detail/settings
- Add deck sheet

#### DeckDetailView
- Card list for a deck
- Search functionality
- Due cards indicator
- Review button overlay
- Edit/delete cards

#### CardEditorView
- Form for card creation/editing
- PhotosPicker integration
- Image preview and removal
- Validation UI feedback

#### ReviewSessionView
- Card display (front/back)
- Rating buttons with colors
- Progress indicator
- Session statistics
- Complete/restart flow

#### OnboardingView
- TabView carousel
- Three onboarding pages
- Get started action
- Sample deck creation

#### SettingsView
- iCloud sync status
- Data export functionality
- App version info
- Share sheet integration

### 6. Preview Support

**Files**: `PreviewSupport/PreviewData.swift`, `PreviewSupport/PreviewContainer.swift`

Support for SwiftUI Previews:
- In-memory Core Data container
- Sample data generation
- Multiple decks with varied states
- Enables rapid UI iteration

### 7. Resources

#### Localization
- `Base.lproj/Localizable.strings`: English
- `zh-Hans.lproj/Localizable.strings`: Chinese Simplified

All user-facing strings use `NSLocalizedString()` for i18n.

#### Assets
- App icon placeholder
- Color assets (optional)
- Image assets (optional)

## Data Flow Patterns

### 1. Creating a Card

```
User Interaction
    │
    ▼
CardEditorView (User input)
    │
    ▼
CardEditorViewModel.save()
    │
    ▼
Card(context:front:back:deck:) initializer
    │
    ▼
PersistenceController.save()
    │
    ▼
Core Data + CloudKit Sync
    │
    ▼
UI Updates via @FetchRequest/@ObservedObject
```

### 2. Review Session Flow

```
User taps "Start Review"
    │
    ▼
ReviewSessionViewModel.init(deck:)
    │ (Fetch due cards)
    ▼
Display CardContentView
    │ (User rates card)
    ▼
ReviewSessionViewModel.rate(:)
    │
    ├─► Scheduler.schedule() → SRSResult
    │
    ├─► Card.applySchedule(result:)
    │
    ├─► ReviewLog(context:card:rating:)
    │
    └─► PersistenceController.save()
        │
        ▼
    Next card or Complete
```

### 3. CloudKit Sync

```
Local Change (Add/Edit/Delete)
    │
    ▼
context.save()
    │
    ▼
NSPersistentCloudKitContainer
    │
    ├─► Upload to CloudKit (automatic)
    │
    └─► Notification: .NSPersistentStoreRemoteChange
        │
        ▼
    PersistenceController receives notification
        │
        ▼
    context.refreshAllObjects()
        │
        ▼
    UI updates automatically
```

## Key Design Decisions

### 1. MVVM Architecture

**Rationale**:
- Clear separation of concerns
- Testable business logic
- SwiftUI-friendly with @Published properties

**Benefits**:
- Views are lightweight and focused on UI
- ViewModels can be unit tested
- Easy to mock for testing

### 2. Core Data + CloudKit

**Rationale**:
- Built-in iOS frameworks (no dependencies)
- Automatic sync with NSPersistentCloudKitContainer
- Offline-first by design
- Conflict resolution handled by framework

**Trade-offs**:
- Requires Apple Developer account for CloudKit
- Limited to Apple ecosystem
- Less control over sync conflicts

### 3. Manual NSManagedObject Subclasses

**Rationale**:
- Full control over entity behavior
- Add computed properties and methods
- Better Swift integration

**Benefits**:
- Type-safe relationships
- Convenience initializers
- Domain logic in model layer

### 4. In-Memory Testing

**Rationale**:
- Fast test execution
- No persistent state between tests
- Same for SwiftUI previews

**Implementation**:
```swift
PersistenceController(inMemory: true)
```

### 5. Pure SRS Functions

**Rationale**:
- Stateless scheduler is easier to test
- No side effects in core algorithm
- Reusable in different contexts

**Benefits**:
- Comprehensive unit tests
- Predictable behavior
- Easy to modify algorithm

## Testing Strategy

### Unit Tests

1. **SchedulerTests**:
   - Test all rating scenarios
   - Verify ease factor calculations
   - Test boundary conditions
   - Multi-review cycles

2. **PersistenceTests**:
   - CRUD operations
   - Relationship integrity
   - Cascade deletes
   - Fetch requests
   - In-memory store verification

### Integration Tests (Future)

- Full review session flow
- CloudKit sync scenarios
- Data export/import
- UI navigation paths

### Preview Tests

All views have SwiftUI previews for:
- Visual regression testing
- Different states (empty, populated)
- Different screen sizes
- Dark mode verification

## Performance Considerations

### 1. Image Optimization

**Location**: `Card.compressImage()`

- Resize to max 512px dimension
- JPEG compression at 0.8 quality
- Happens at save time (not runtime)

### 2. Efficient Queries

**Pattern**: Use `@FetchRequest` with predicates
```swift
@FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Deck.updatedAt, ascending: false)],
    animation: .default
)
```

### 3. Lazy Loading

- Cards loaded on-demand via relationships
- Images stored as data (not eager-loaded)
- Review logs only fetched when needed

### 4. Background Contexts

Available for long-running operations:
```swift
let bgContext = PersistenceController.shared.newBackgroundContext()
```

## Accessibility Features

### VoiceOver Support

All interactive elements have labels:
```swift
.accessibilityLabel("Again")
.accessibilityHint("Rate your recall")
```

### Dynamic Type

Views use semantic font styles:
```swift
.font(.headline)  // Scales with user preference
```

### Haptic Feedback

Rating buttons provide tactile feedback:
```swift
UIImpactFeedbackGenerator(style: .light).impactOccurred()
```

### Color Contrast

Rating buttons use distinct colors:
- Red (Again)
- Orange (Hard)
- Green (Good)
- Blue (Easy)

## Localization Strategy

### String Keys

All user-facing strings use NSLocalizedString:
```swift
Text(NSLocalizedString("Start Review", comment: ""))
```

### Supported Languages

1. **Base (English)**: Default fallback
2. **zh-Hans (Chinese Simplified)**: Full translation

### Adding New Languages

1. Create `{language}.lproj/` folder
2. Copy and translate `Localizable.strings`
3. Add language in Xcode project settings

## Future Enhancement Ideas

### Easy Wins
- [ ] Pull to refresh on deck list
- [ ] Swipe actions on cards
- [ ] Undo delete with snackbar
- [ ] Card statistics in detail view

### Medium Complexity
- [ ] Import decks from JSON
- [ ] Streak tracking
- [ ] Daily goal setting
- [ ] Study reminders

### Advanced Features
- [ ] Shared decks (public CloudKit)
- [ ] Collaborative editing
- [ ] Apple Watch app
- [ ] Widgets for home screen
- [ ] Siri shortcuts

## Code Quality Standards

### Swift Style
- Use Swift naming conventions
- Prefer structs over classes where possible
- Use extensions for code organization
- Document complex algorithms

### SwiftUI Best Practices
- Keep views small and focused
- Extract subviews for reusability
- Use @StateObject for view models
- Prefer composition over inheritance

### Core Data Guidelines
- Always save on main context for UI changes
- Use background contexts for heavy operations
- Set proper delete rules
- Handle fetch errors gracefully

## Debugging Tips

### Core Data Issues
```swift
// Enable SQL debugging
-com.apple.CoreData.SQLDebug 1
```

### CloudKit Issues
```swift
// Check CloudKit container status
CKContainer.default().accountStatus { status, error in
    print("iCloud status: \(status)")
}
```

### View Debugging
- Use SwiftUI previews for quick iteration
- Add breakpoints in ViewModels
- Use `print()` statements strategically
- Test with different simulator sizes

---

**This overview should help you understand and extend the FlashcardMVP codebase effectively!**
