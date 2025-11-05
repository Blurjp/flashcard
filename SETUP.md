# Quick Setup Guide

This guide will help you get FlashcardMVP running in Xcode.

## Prerequisites

- macOS 13.0+
- Xcode 15.0+
- Apple Developer account (for device testing)

## Step-by-Step Setup

### 1. Create Xcode Project

Since the source files are provided but not the Xcode project file, you'll need to create a new project:

1. Open Xcode
2. Select **File → New → Project**
3. Choose **iOS → App**
4. Configure the project:
   - Product Name: `FlashcardMVP`
   - Team: Select your team
   - Organization Identifier: `com.yourcompany` (or your reverse domain)
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Storage: **Core Data** ✓ (CHECK THIS!)
   - Tests: **Include Tests** ✓
5. Save in the root directory of this repository (where this SETUP.md file is located)

### 2. Add Source Files to Project

After creating the project, you'll need to add the source files:

1. In Xcode's Project Navigator, **delete** the following auto-generated files:
   - `FlashcardMVPApp.swift` (we have our own)
   - `ContentView.swift` (we don't need this)
   - The auto-generated Core Data files (we have our own)

2. **Drag and drop** the following folders from Finder into your Xcode project:
   - `FlashcardMVP/Persistence/`
   - `FlashcardMVP/Models/`
   - `FlashcardMVP/SRS/`
   - `FlashcardMVP/ViewModels/`
   - `FlashcardMVP/Views/`
   - `FlashcardMVP/Resources/`
   - `FlashcardMVP/PreviewSupport/`
   - `FlashcardMVP/FlashcardMVPApp.swift`

3. When prompted, check:
   - ✓ Copy items if needed
   - ✓ Create groups
   - ✓ Add to target: FlashcardMVP

4. **Drag and drop** test files:
   - `FlashcardMVPTests/SchedulerTests.swift`
   - `FlashcardMVPTests/PersistenceTests.swift`
   - Add to target: FlashcardMVPTests

### 3. Create Core Data Model

**CRITICAL STEP**: You must manually create the Core Data model:

1. Select the `FlashcardMVP/Persistence/` group in Project Navigator
2. Go to **File → New → File...**
3. Select **Core Data → Data Model**
4. Name it: `FlashcardMVP`
5. Click Create

6. Follow the detailed instructions in `CoreDataModel.md` to add:
   - Deck entity (with id, name, createdAt, updatedAt, cards)
   - Card entity (with all attributes and relationships)
   - ReviewLog entity (with id, rating, timestamp, card)

7. Set up relationships and inverse relationships as specified
8. Set Codegen to "Manual/None" for all entities

### 4. Configure Localization

1. Select the project in Project Navigator
2. Select the project (blue icon) under PROJECT
3. Go to **Info** tab
4. Under **Localizations**, click **+**
5. Add **Chinese (Simplified)**
6. Select `Localizable.strings` files when prompted

### 5. Add iCloud Capability

1. Select the project → Target: FlashcardMVP
2. Go to **Signing & Capabilities** tab
3. Click **+ Capability**
4. Add **iCloud**
5. Check **CloudKit**
6. Xcode will create a container automatically

**Note**: This requires a paid Apple Developer account. If you don't have one, you can disable CloudKit temporarily (see README.md).

### 6. Configure App Info

1. Select `Info.plist` (or go to Target → Info)
2. Add the following keys if not present:
   - **Privacy - Photo Library Usage Description**: "To attach images to your flashcards"
   - Value: "FlashcardMVP needs access to your photo library to attach images to flashcards for better memorization."

### 7. Build and Run

1. Select a simulator (iPhone 15 recommended) or your device
2. Press **⌘R** to build and run
3. The app should launch with the onboarding screen

## Troubleshooting

### "No such module 'CoreData'" error
- Make sure Storage is set to "Core Data" in project settings
- Check that the Core Data model file is created correctly

### "Cannot find type 'Deck' in scope"
- Verify the Core Data model is created with all three entities
- Check that Codegen is set to "Manual/None"
- Make sure all Model files are added to the target

### Build fails with missing files
- Verify all source files are added to the correct target
- Check that file references are not red in Project Navigator

### CloudKit errors on simulator
- Sign in to iCloud on the simulator (Settings → Apple ID)
- Or disable CloudKit for testing (see README.md)

### Localization not working
- Make sure both `Base.lproj` and `zh-Hans.lproj` folders are added
- Check that `Localizable.strings` files are included in the target
- Verify localization is enabled in project settings

## Verification Checklist

Before running, verify:

- ✓ Xcode project created with Core Data support
- ✓ All source files added to correct groups
- ✓ Core Data model created with all entities
- ✓ Relationships and inverse relationships set
- ✓ Localization configured for Base and zh-Hans
- ✓ iCloud capability added (or disabled for testing)
- ✓ Photo library usage description added
- ✓ Project builds without errors (⌘B)
- ✓ Tests run successfully (⌘U)

## Alternative: Use Provided Project Files

If you want to skip manual setup, you can also:

1. Create a branch with pre-configured Xcode project files
2. Download and use that as a starting point

However, manual setup is recommended for learning purposes.

## Need Help?

- Check the main README.md for detailed documentation
- Review CoreDataModel.md for Core Data setup
- Open an issue on GitHub for specific problems

---

**Once setup is complete, you should have a fully functional flashcard app!**
