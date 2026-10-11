//
//  DemoCaptureUITests.swift
//  FlashcardMVPUITests
//
//  Walks the app for App Store capture: screenshots via XCTAttachment
//  while the simulator screen is recorded for the preview video.
//

import XCTest

final class DemoCaptureUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-SeedDemoData", "YES"]
        app.launch()
    }

    private func snap(_ name: String) {
        let shot = XCTAttachment(screenshot: app.screenshot())
        shot.name = name
        shot.lifetime = .keepAlways
        add(shot)
    }

    private func waitStable(_ seconds: UInt32 = 1) {
        sleep(seconds)
    }

    func testDemoFlowCapture() throws {
        // 1. Deck list
        XCTAssertTrue(app.navigationBars["Decks"].waitForExistence(timeout: 10))
        waitStable(2)
        snap("01-deck-list")

        // 2. Open a themed deck
        let deck = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Science Olympiad")).firstMatch
        XCTAssertTrue(deck.waitForExistence(timeout: 5))
        deck.tap()
        waitStable(2)
        snap("02-deck-detail")

        // 3. Review session — question
        let startReview = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Start Review")).firstMatch
        XCTAssertTrue(startReview.waitForExistence(timeout: 5))
        startReview.tap()
        waitStable(2)
        snap("03-review-question")

        // 4. Flip the card
        let showAnswer = app.buttons["Show Answer"]
        XCTAssertTrue(showAnswer.waitForExistence(timeout: 5))
        showAnswer.tap()
        waitStable(2)
        snap("04-review-answer")

        // 5. Rate a few cards
        for _ in 0..<2 {
            let good = app.buttons["Good"]
            if good.waitForExistence(timeout: 3) {
                good.tap()
                waitStable(1)
                let next = app.buttons["Show Answer"]
                if next.waitForExistence(timeout: 2) {
                    next.tap()
                    waitStable(1)
                }
            }
        }

        // 6. Session complete (or back out if cards remain)
        if app.staticTexts["Session Complete!"].waitForExistence(timeout: 3) {
            waitStable(2)
            snap("05-session-complete")
        }
        app.buttons.firstMatch.tap() // dismiss completion if shown
        sleep(1)
        if app.navigationBars["Decks"].exists == false {
            app.navigationBars.buttons.firstMatch.tap()
            waitStable(1)
        }

        // 7. Settings with themes
        let gear = app.buttons["Settings"]
        if gear.waitForExistence(timeout: 5) {
            gear.tap()
            waitStable(2)
            snap("06-settings-themes")

            // Scroll to show the theme pickers on video
            app.swipeUp()
            waitStable(2)
            snap("07-settings-scrolled")
        }
    }
}
