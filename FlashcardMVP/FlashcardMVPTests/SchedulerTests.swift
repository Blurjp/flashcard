//
//  SchedulerTests.swift
//  FlashcardMVPTests
//
//  Unit tests for SRS Scheduler
//

import XCTest
@testable import FlashcardMVP

final class SchedulerTests: XCTestCase {

    func testInitialReviewWithGoodRating() {
        let now = Date()
        let result = Scheduler.schedule(
            now: now,
            repetition: 0,
            intervalDays: 1,
            easeFactor: 2.5,
            rating: .good
        )

        // First repetition should give 1 day interval
        XCTAssertEqual(result.newRepetition, 1)
        XCTAssertEqual(result.newIntervalDays, 1)
        XCTAssertGreaterThanOrEqual(result.newEaseFactor, 2.5)

        // Due date should be approximately 1 day from now
        let expectedDate = Calendar.current.date(byAdding: .day, value: 1, to: now)!
        let timeDifference = abs(result.newDueDate.timeIntervalSince(expectedDate))
        XCTAssertLessThan(timeDifference, 60) // Within 1 minute tolerance
    }

    func testSecondReviewWithGoodRating() {
        let now = Date()
        let result = Scheduler.schedule(
            now: now,
            repetition: 1,
            intervalDays: 1,
            easeFactor: 2.6,
            rating: .good
        )

        // Second repetition should give 3 days interval
        XCTAssertEqual(result.newRepetition, 2)
        XCTAssertEqual(result.newIntervalDays, 3)
    }

    func testSubsequentReviewsScaleByEaseFactor() {
        let now = Date()
        let result = Scheduler.schedule(
            now: now,
            repetition: 2,
            intervalDays: 3,
            easeFactor: 2.5,
            rating: .good
        )

        // Third+ repetition should scale by ease factor
        XCTAssertEqual(result.newRepetition, 3)
        // 3 * 2.5 = 7.5, rounded = 8
        XCTAssertEqual(result.newIntervalDays, 8)
    }

    func testAgainRatingResetsProgress() {
        let now = Date()
        let result = Scheduler.schedule(
            now: now,
            repetition: 5,
            intervalDays: 30,
            easeFactor: 2.8,
            rating: .again
        )

        // Again should reset repetition and interval
        XCTAssertEqual(result.newRepetition, 0)
        XCTAssertEqual(result.newIntervalDays, 1)
        // Ease factor should decrease
        XCTAssertLessThan(result.newEaseFactor, 2.8)
    }

    func testHardRatingResetsProgress() {
        let now = Date()
        let result = Scheduler.schedule(
            now: now,
            repetition: 3,
            intervalDays: 10,
            easeFactor: 2.5,
            rating: .hard
        )

        // Hard should also reset repetition
        XCTAssertEqual(result.newRepetition, 0)
        XCTAssertEqual(result.newIntervalDays, 1)
    }

    func testEasyRatingIncreasesEaseFactor() {
        let initialEase = 2.5
        let result = Scheduler.schedule(
            now: Date(),
            repetition: 1,
            intervalDays: 1,
            easeFactor: initialEase,
            rating: .easy
        )

        // Easy rating should increase ease factor
        XCTAssertGreaterThan(result.newEaseFactor, initialEase)
    }

    func testEaseFactorMinimum() {
        // Start with very low ease factor
        let result = Scheduler.schedule(
            now: Date(),
            repetition: 0,
            intervalDays: 1,
            easeFactor: 1.3,
            rating: .again
        )

        // Ease factor should never go below 1.3
        XCTAssertGreaterThanOrEqual(result.newEaseFactor, 1.3)
    }

    func testEaseFactorCalculation() {
        // Test the SM-2 ease factor formula
        // EF' = EF + (0.1 - (3 - q) * (0.08 + (3 - q) * 0.02))

        // For Good (q=2): delta = 0.1 - 1 * (0.08 + 1 * 0.02) = 0.1 - 0.1 = 0
        let resultGood = Scheduler.schedule(
            now: Date(),
            repetition: 0,
            intervalDays: 1,
            easeFactor: 2.5,
            rating: .good
        )
        XCTAssertEqual(resultGood.newEaseFactor, 2.5, accuracy: 0.01)

        // For Easy (q=3): delta = 0.1 - 0 * (0.08 + 0 * 0.02) = 0.1
        let resultEasy = Scheduler.schedule(
            now: Date(),
            repetition: 0,
            intervalDays: 1,
            easeFactor: 2.5,
            rating: .easy
        )
        XCTAssertEqual(resultEasy.newEaseFactor, 2.6, accuracy: 0.01)

        // For Again (q=0): delta = 0.1 - 3 * (0.08 + 3 * 0.02) = 0.1 - 0.42 = -0.32
        let resultAgain = Scheduler.schedule(
            now: Date(),
            repetition: 0,
            intervalDays: 1,
            easeFactor: 2.5,
            rating: .again
        )
        XCTAssertEqual(resultAgain.newEaseFactor, 2.18, accuracy: 0.01)
    }

    func testPreviewNextDueDate() {
        let now = Date()
        let dueDate = Scheduler.previewNextDueDate(
            from: now,
            repetition: 0,
            intervalDays: 1,
            easeFactor: 2.5,
            rating: .good
        )

        let expectedDate = Calendar.current.date(byAdding: .day, value: 1, to: now)!
        let timeDifference = abs(dueDate.timeIntervalSince(expectedDate))
        XCTAssertLessThan(timeDifference, 60) // Within 1 minute tolerance
    }

    func testMultipleReviewCycle() {
        var repetition = 0
        var intervalDays = 1
        var easeFactor = 2.5
        var now = Date()

        // First review - Good
        var result = Scheduler.schedule(
            now: now,
            repetition: repetition,
            intervalDays: intervalDays,
            easeFactor: easeFactor,
            rating: .good
        )
        XCTAssertEqual(result.newRepetition, 1)
        XCTAssertEqual(result.newIntervalDays, 1)

        // Update values
        repetition = result.newRepetition
        intervalDays = result.newIntervalDays
        easeFactor = result.newEaseFactor
        now = result.newDueDate

        // Second review - Good
        result = Scheduler.schedule(
            now: now,
            repetition: repetition,
            intervalDays: intervalDays,
            easeFactor: easeFactor,
            rating: .good
        )
        XCTAssertEqual(result.newRepetition, 2)
        XCTAssertEqual(result.newIntervalDays, 3)

        // Update values
        repetition = result.newRepetition
        intervalDays = result.newIntervalDays
        easeFactor = result.newEaseFactor
        now = result.newDueDate

        // Third review - Easy
        result = Scheduler.schedule(
            now: now,
            repetition: repetition,
            intervalDays: intervalDays,
            easeFactor: easeFactor,
            rating: .easy
        )
        XCTAssertEqual(result.newRepetition, 3)
        // Should scale by (now increased) ease factor
        XCTAssertGreaterThan(result.newIntervalDays, 3)
    }
}
