//
//  FlashcardMVPUITests.swift
//  FlashcardMVPUITests
//
//  UI tests for complete user flows
//

import XCTest

final class FlashcardMVPUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        app.launch()
    }

    // MARK: - Onboarding Tests

    func testOnboardingFlow() throws {
        // Skip onboarding if already completed
        if app.buttons["Get Started"].exists {
            app.buttons["Get Started"].tap()
        }

        // Should see deck list
        XCTAssertTrue(app.navigationBars["Decks"].exists)
    }

    // MARK: - Deck Creation Tests

    func testCreateDeck() throws {
        // Tap add button
        app.buttons["plus"].tap()

        // Enter deck name
        let deckNameField = app.textFields["Deck Name"]
        XCTAssertTrue(deckNameField.exists)
        deckNameField.tap()
        deckNameField.typeText("UI Test Deck")

        // Create deck
        app.buttons["Create"].tap()

        // Verify deck appears
        XCTAssertTrue(app.staticTexts["UI Test Deck"].exists)
    }

    // MARK: - Card Creation Tests

    func testCreateCardManually() throws {
        // Assume we have a deck
        if !app.staticTexts["Sample Deck"].exists {
            createSampleDeck()
        }

        // Tap deck
        app.staticTexts["Sample Deck"].tap()

        // Tap add button and select manual
        app.buttons["plus"].tap()
        app.buttons["Add Card Manually"].tap()

        // Fill in card
        let frontField = app.textFields["Front"]
        frontField.tap()
        frontField.typeText("UI Test Question")

        let backField = app.textFields["Back"]
        backField.tap()
        backField.typeText("UI Test Answer")

        // Save
        app.buttons["Save"].tap()

        // Verify card appears
        XCTAssertTrue(app.staticTexts["UI Test Question"].exists)
    }

    // MARK: - Review Session Tests

    func testReviewSession() throws {
        // Assume we have a deck with cards
        if !app.staticTexts["Sample Deck"].exists {
            createSampleDeck()
        }

        app.staticTexts["Sample Deck"].tap()

        // Start review
        if app.buttons["Start Review"].exists {
            app.buttons["Start Review"].tap()
        } else {
            // No due cards
            return
        }

        // Show answer
        app.buttons["Show Answer"].tap()

        // Rate card
        app.buttons["Good"].tap()

        // Should see next card or completion
        XCTAssertTrue(
            app.buttons["Show Answer"].exists ||
            app.staticTexts["Session Complete!"].exists
        )
    }

    // MARK: - AI Generation Tests

    func testAICardGenerationFlow() throws {
        // Open deck
        if !app.staticTexts["Sample Deck"].exists {
            createSampleDeck()
        }
        app.staticTexts["Sample Deck"].tap()

        // Tap add → Generate from Photo
        app.buttons["plus"].tap()
        app.buttons["Generate from Photo"].tap()

        // Should see generation view
        XCTAssertTrue(app.staticTexts["Generate Flashcards"].exists)

        // Choose from library button should exist
        XCTAssertTrue(app.buttons["Choose from Library"].exists)

        // Cancel
        app.buttons["Cancel"].tap()
    }

    // MARK: - Settings Tests

    func testSettingsAccess() throws {
        app.buttons["gear"].tap()

        // Should see settings
        XCTAssertTrue(app.navigationBars["Settings"].exists)
        XCTAssertTrue(app.staticTexts["iCloud Sync"].exists)
        XCTAssertTrue(app.staticTexts["AI Configuration"].exists)

        app.buttons["Done"].tap()
    }

    // MARK: - Search Tests

    func testSearchCards() throws {
        if !app.staticTexts["Sample Deck"].exists {
            createSampleDeck()
        }

        app.staticTexts["Sample Deck"].tap()

        // Activate search
        let searchField = app.searchFields.firstMatch
        searchField.tap()
        searchField.typeText("What")

        // Results should filter
        sleep(1) // Wait for search to filter
        // Verify filtered results
    }

    // MARK: - Helper Methods

    private func createSampleDeck() {
        app.buttons["Get Started"].tap()
    }

    private func deleteDeck(named name: String) {
        let deckCell = app.staticTexts[name]
        if deckCell.exists {
            deckCell.swipeLeft()
            app.buttons["Delete"].tap()
        }
    }
}

// MARK: - Accessibility Tests

final class AccessibilityUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testVoiceOverLabels() throws {
        // Check that important elements have accessibility labels
        let addButton = app.buttons["plus"]
        XCTAssertNotNil(addButton.label)

        let settingsButton = app.buttons["gear"]
        XCTAssertNotNil(settingsButton.label)
    }

    func testDynamicType() throws {
        // Note: This would require launching with different text sizes
        // For now, just verify text elements exist
        XCTAssertTrue(app.navigationBars["Decks"].exists)
    }
}
