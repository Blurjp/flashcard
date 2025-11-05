# FlashcardMVP - iOS Flashcard Application

A polished iOS flashcard application built with SwiftUI, featuring spaced repetition learning, iCloud sync, and a clean MVVM architecture.

![iOS](https://img.shields.io/badge/iOS-16.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange)
![Xcode](https://img.shields.io/badge/Xcode-15.0%2B-blue)
![License](https://img.shields.io/badge/License-MIT-green)

## Features

### Core Functionality

- **Deck Management**: Create, edit, and organize flashcard decks
- **Card Creation**: Add flashcards with front/back text and optional images
- **Spaced Repetition**: SM-2 inspired algorithm for optimal learning
- **Review Sessions**: Interactive study sessions with 4-level rating system
- **iCloud Sync**: Automatic sync across all your devices via CloudKit
- **Offline-First**: Full functionality without internet connection

### User Experience

- **Onboarding**: First-time user introduction with sample deck
- **Search**: Quick card search within decks
- **Progress Tracking**: View due card counts and study statistics
- **Dark Mode**: Full support for dark appearance
- **Accessibility**: VoiceOver labels, Dynamic Type support
- **Localization**: English and Simplified Chinese

### Technical Highlights

- **MVVM Architecture**: Clean separation of concerns
- **Core Data + CloudKit**: Persistent storage with iCloud sync
- **Unit Tests**: Comprehensive test coverage for scheduler and persistence
- **SwiftUI Previews**: Quick development iteration
- **No Third-Party Dependencies**: Pure iOS SDK implementation

## Project Structure

```
FlashcardMVP/
├── FlashcardMVP/
│   ├── FlashcardMVPApp.swift          # App entry point
│   ├── Persistence/
│   │   ├── PersistenceController.swift # Core Data stack
│   │   └── FlashcardMVP.xcdatamodeld  # Core Data model
│   ├── Models/
│   │   ├── Deck.swift                 # Deck entity extension
│   │   ├── Card.swift                 # Card entity extension
│   │   └── ReviewLog.swift            # ReviewLog entity extension
│   ├── SRS/
│   │   └── Scheduler.swift            # Spaced repetition algorithm
│   ├── ViewModels/
│   │   ├── DeckListViewModel.swift    # Deck list logic
│   │   ├── DeckDetailViewModel.swift  # Deck detail logic
│   │   ├── CardEditorViewModel.swift  # Card editing logic
│   │   └── ReviewSessionViewModel.swift # Review session logic
│   ├── Views/
│   │   ├── DeckListView.swift         # Deck list UI
│   │   ├── DeckDetailView.swift       # Deck detail UI
│   │   ├── CardEditorView.swift       # Card editor UI
│   │   ├── ReviewSessionView.swift    # Review session UI
│   │   ├── OnboardingView.swift       # Onboarding UI
│   │   └── SettingsView.swift         # Settings UI
│   ├── Resources/
│   │   ├── Assets.xcassets            # Images and colors
│   │   ├── Base.lproj/
│   │   │   └── Localizable.strings    # English strings
│   │   └── zh-Hans.lproj/
│   │       └── Localizable.strings    # Chinese strings
│   └── PreviewSupport/
│       ├── PreviewData.swift          # Sample data
│       └── PreviewContainer.swift     # Preview container
├── FlashcardMVPTests/
│   ├── SchedulerTests.swift           # SRS algorithm tests
│   └── PersistenceTests.swift         # Core Data tests
├── CoreDataModel.md                    # Core Data setup guide
└── README.md                           # This file
```

## Getting Started

### Prerequisites

- macOS 13.0 or later
- Xcode 15.0 or later
- iOS 16.0+ deployment target
- Apple Developer account (for device testing and CloudKit)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd flashcard
   ```

2. **Open in Xcode**
   ```bash
   open FlashcardMVP/FlashcardMVP.xcodeproj
   ```

3. **Create Core Data Model**

   ⚠️ **Important**: The Core Data model file (`.xcdatamodeld`) needs to be created in Xcode:

   - Follow the detailed instructions in `CoreDataModel.md`
   - Create three entities: `Deck`, `Card`, and `ReviewLog`
   - Set up all attributes and relationships as specified
   - Save the file in `FlashcardMVP/Persistence/` directory

4. **Configure Signing**

   - Select the project in Xcode navigator
   - Under "Signing & Capabilities", select your team
   - Xcode will automatically configure the bundle identifier

5. **Configure iCloud (Required for CloudKit sync)**

   - In Xcode, go to project settings → Signing & Capabilities
   - Click "+ Capability" and add "iCloud"
   - Enable "CloudKit"
   - Xcode will create a default container (or select existing one)

   **Note**: iCloud capabilities require a paid Apple Developer account.

6. **Build and Run**
   ```
   Select a simulator or device
   Press ⌘R to build and run
   ```

## Development

### Running Tests

```bash
# Run all tests
⌘U in Xcode

# Or use command line
xcodebuild test -scheme FlashcardMVP -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Testing Without iCloud

If you want to test without iCloud (on simulator without Apple ID):

1. Open `PersistenceController.swift`
2. In the `init` method, you can temporarily disable CloudKit:
   ```swift
   // Disable CloudKit for testing
   container.persistentStoreDescriptions.first?.cloudKitContainerOptions = nil
   ```
3. The app will work fully offline without iCloud sync

Alternatively, use an in-memory store for testing:
```swift
let controller = PersistenceController(inMemory: true)
```

### SwiftUI Previews

All views include SwiftUI previews for rapid development:

```swift
#Preview {
    DeckListView(context: PersistenceController.preview.viewContext)
}
```

## Architecture

### MVVM Pattern

The app follows the Model-View-ViewModel pattern:

- **Models**: Core Data entities (Deck, Card, ReviewLog)
- **Views**: SwiftUI views for UI presentation
- **ViewModels**: Business logic and state management

### Data Flow

```
View → ViewModel → Core Data → CloudKit
  ↑                                  ↓
  └──────── Sync Changes ────────────┘
```

### Spaced Repetition Algorithm

The app uses an SM-2 inspired algorithm:

1. **Initial Reviews**: Cards start with 1-day intervals
2. **Rating System**:
   - Again (0): Resets progress, 1-day interval
   - Hard (1): Resets progress, 1-day interval
   - Good (2): Continues progression
   - Easy (3): Increases ease factor
3. **Ease Factor**: Adjusted based on performance (min 1.3)
4. **Interval Calculation**: Previous interval × ease factor

See `Scheduler.swift` for implementation details.

## Usage

### Creating Your First Deck

1. Launch the app - you'll see the onboarding screen
2. Tap "Get Started" to create a sample deck
3. Or skip and create your own deck with the "+" button

### Adding Cards

1. Select a deck from the list
2. Tap the "+" button in the top right
3. Enter front and back text
4. Optionally add an image
5. Tap "Save"

### Reviewing Cards

1. Open a deck
2. Tap "Start Review" button at the bottom
3. Read the question, tap "Show Answer"
4. Rate your recall:
   - **Again**: Didn't remember at all
   - **Hard**: Remembered with difficulty
   - **Good**: Remembered correctly
   - **Easy**: Remembered instantly
5. Complete the session to see statistics

### Exporting Data

1. Go to Settings (gear icon)
2. Tap "Export All Decks"
3. Share the JSON file via any method

## Keyboard Shortcuts (Review Session)

When using an external keyboard:

- **A**: Rate as "Again"
- **H**: Rate as "Hard"
- **G**: Rate as "Good"
- **E**: Rate as "Easy"
- **Space**: Show answer

## Localization

The app supports:
- English (Base)
- Chinese Simplified (zh-Hans)

To add more languages:
1. Add a new `.lproj` folder in `Resources/`
2. Copy `Localizable.strings` and translate
3. Add the language in Xcode project settings

## CloudKit Considerations

### Development vs Production

- The app uses the **private database** (user-specific data)
- No schema setup required - Core Data handles it automatically
- CloudKit console: https://icloud.developer.apple.com/

### Testing iCloud Sync

1. Sign in to iCloud on your test device/simulator
2. Enable iCloud Drive in Settings
3. Run the app and create some decks/cards
4. Install on another device with the same Apple ID
5. Changes should sync automatically

### Disabling CloudKit for Testing

See "Testing Without iCloud" section above.

## Troubleshooting

### Build Errors

**Problem**: "No such module 'CoreData'"
- Solution: Ensure deployment target is iOS 16.0+

**Problem**: Core Data entity errors
- Solution: Follow `CoreDataModel.md` to create the model file correctly

### Runtime Issues

**Problem**: App crashes on launch
- Solution: Check that Core Data model is created and named correctly

**Problem**: iCloud sync not working
- Solution: Verify iCloud capability is enabled and you're signed in

**Problem**: Images not loading
- Solution: Ensure you've granted photo library permissions

## Testing

### Unit Tests

The project includes comprehensive unit tests:

- **SchedulerTests.swift**: Tests for SRS algorithm correctness
  - Rating calculations
  - Ease factor boundaries
  - Interval progressions
  - Edge cases

- **PersistenceTests.swift**: Tests for Core Data operations
  - CRUD operations
  - Relationships
  - Cascade deletes
  - Fetch requests

Run tests with `⌘U` in Xcode.

## Performance

- Lightweight: < 5MB app size
- Fast: SwiftUI rendering, optimized Core Data queries
- Efficient: Images compressed to max 512px, JPEG quality 0.8
- Battery-friendly: No background processing except CloudKit sync

## Future Enhancements

Potential features for future versions:

- [ ] Import decks from JSON
- [ ] Statistics dashboard (streak, daily review count)
- [ ] Study reminder notifications
- [ ] Text-to-speech for cards
- [ ] Card tags and filtering
- [ ] Shared decks (public CloudKit database)
- [ ] Apple Watch companion app
- [ ] Widgets for home screen

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see below:

```
MIT License

Copyright (c) 2024 FlashcardMVP

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## Acknowledgments

- SM-2 algorithm by Piotr Wozniak
- SwiftUI framework by Apple
- Core Data and CloudKit by Apple

## Support

For issues, questions, or suggestions:
- Open an issue on GitHub
- Check existing issues for solutions
- Review the troubleshooting section above

## Authors

Built as an iOS development MVP demonstrating:
- Modern SwiftUI best practices
- MVVM architecture
- Core Data with CloudKit integration
- Spaced repetition learning algorithms
- Comprehensive testing
- Accessibility and localization

---

**Happy Learning! 📚✨**
