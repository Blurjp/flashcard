//
//  PersistenceTests.swift
//  FlashcardMVPTests
//
//  Unit tests for Core Data persistence
//

import XCTest
import CoreData
@testable import FlashcardMVP

final class PersistenceTests: XCTestCase {
    var persistenceController: PersistenceController!
    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        persistenceController = PersistenceController(inMemory: true)
        context = persistenceController.viewContext
    }

    override func tearDown() {
        persistenceController = nil
        context = nil
        super.tearDown()
    }

    // MARK: - Deck Tests

    func testCreateDeck() {
        let deck = Deck(context: context, name: "Test Deck")

        XCTAssertNotNil(deck.id)
        XCTAssertEqual(deck.name, "Test Deck")
        XCTAssertNotNil(deck.createdAt)
        XCTAssertNotNil(deck.updatedAt)
        XCTAssertEqual(deck.cardsArray.count, 0)
    }

    func testUpdateDeck() {
        let deck = Deck(context: context, name: "Original Name")
        let originalUpdatedAt = deck.updatedAt

        // Wait a tiny bit to ensure timestamp changes
        Thread.sleep(forTimeInterval: 0.01)

        deck.update(name: "Updated Name")

        XCTAssertEqual(deck.name, "Updated Name")
        XCTAssertGreaterThan(deck.updatedAt, originalUpdatedAt)
    }

    func testDeleteDeck() throws {
        let deck = Deck(context: context, name: "Delete Me")
        try context.save()

        let fetchRequest: NSFetchRequest<Deck> = Deck.fetchRequest()
        var decks = try context.fetch(fetchRequest)
        XCTAssertEqual(decks.count, 1)

        context.delete(deck)
        try context.save()

        decks = try context.fetch(fetchRequest)
        XCTAssertEqual(decks.count, 0)
    }

    // MARK: - Card Tests

    func testCreateCard() {
        let deck = Deck(context: context, name: "Test Deck")
        let card = Card(context: context, front: "Question", back: "Answer", deck: deck)

        XCTAssertNotNil(card.id)
        XCTAssertEqual(card.front, "Question")
        XCTAssertEqual(card.back, "Answer")
        XCTAssertEqual(card.deck, deck)
        XCTAssertEqual(card.repetition, 0)
        XCTAssertEqual(card.intervalDays, 1)
        XCTAssertEqual(card.easeFactor, 2.5, accuracy: 0.01)
        XCTAssertNotNil(card.dueDate)
        XCTAssertTrue(card.isDue)
    }

    func testUpdateCard() {
        let deck = Deck(context: context, name: "Test Deck")
        let card = Card(context: context, front: "Old Front", back: "Old Back", deck: deck)
        let originalUpdatedAt = card.updatedAt

        Thread.sleep(forTimeInterval: 0.01)

        card.update(front: "New Front", back: "New Back", imageData: nil)

        XCTAssertEqual(card.front, "New Front")
        XCTAssertEqual(card.back, "New Back")
        XCTAssertGreaterThan(card.updatedAt, originalUpdatedAt)
    }

    func testCardWithImage() {
        let deck = Deck(context: context, name: "Test Deck")
        let imageData = Data([0x00, 0x01, 0x02, 0x03])
        let card = Card(context: context, front: "Front", back: "Back", deck: deck, imageData: imageData)

        XCTAssertNotNil(card.imageData)
        XCTAssertEqual(card.imageData, imageData)
    }

    func testCardDueStatus() {
        let deck = Deck(context: context, name: "Test Deck")
        let card = Card(context: context, front: "Q", back: "A", deck: deck)

        // Card is due by default (dueDate = now)
        XCTAssertTrue(card.isDue)

        // Set due date to tomorrow
        card.dueDate = Date().addingTimeInterval(86400)
        XCTAssertFalse(card.isDue)

        // Set due date to yesterday
        card.dueDate = Date().addingTimeInterval(-86400)
        XCTAssertTrue(card.isDue)
    }

    func testApplySchedule() {
        let deck = Deck(context: context, name: "Test Deck")
        let card = Card(context: context, front: "Q", back: "A", deck: deck)

        let result = SRSResult(
            newEaseFactor: 2.6,
            newIntervalDays: 3,
            newRepetition: 2,
            newDueDate: Date().addingTimeInterval(86400 * 3)
        )

        card.applySchedule(result: result)

        XCTAssertEqual(card.easeFactor, 2.6, accuracy: 0.01)
        XCTAssertEqual(card.intervalDays, 3)
        XCTAssertEqual(card.repetition, 2)
    }

    // MARK: - ReviewLog Tests

    func testCreateReviewLog() {
        let deck = Deck(context: context, name: "Test Deck")
        let card = Card(context: context, front: "Q", back: "A", deck: deck)
        let log = ReviewLog(context: context, card: card, rating: .good)

        XCTAssertNotNil(log.id)
        XCTAssertEqual(log.card, card)
        XCTAssertEqual(log.rating, 2)
        XCTAssertEqual(log.ratingEnum, .good)
        XCTAssertNotNil(log.timestamp)
    }

    // MARK: - Relationship Tests

    func testDeckCardsRelationship() {
        let deck = Deck(context: context, name: "Test Deck")
        XCTAssertEqual(deck.cardsArray.count, 0)

        _ = Card(context: context, front: "Q1", back: "A1", deck: deck)
        _ = Card(context: context, front: "Q2", back: "A2", deck: deck)
        _ = Card(context: context, front: "Q3", back: "A3", deck: deck)

        XCTAssertEqual(deck.cardsArray.count, 3)
    }

    func testDeckDueCardsCount() {
        let deck = Deck(context: context, name: "Test Deck")

        let card1 = Card(context: context, front: "Q1", back: "A1", deck: deck)
        card1.dueDate = Date() // Due now

        let card2 = Card(context: context, front: "Q2", back: "A2", deck: deck)
        card2.dueDate = Date().addingTimeInterval(-86400) // Due yesterday

        let card3 = Card(context: context, front: "Q3", back: "A3", deck: deck)
        card3.dueDate = Date().addingTimeInterval(86400) // Due tomorrow

        XCTAssertEqual(deck.dueCardsCount, 2) // card1 and card2 are due
        XCTAssertEqual(deck.totalCardsCount, 3)
    }

    func testCardReviewLogsRelationship() {
        let deck = Deck(context: context, name: "Test Deck")
        let card = Card(context: context, front: "Q", back: "A", deck: deck)

        XCTAssertEqual(card.reviewLogsArray.count, 0)

        _ = ReviewLog(context: context, card: card, rating: .good)
        Thread.sleep(forTimeInterval: 0.01)
        _ = ReviewLog(context: context, card: card, rating: .easy)

        XCTAssertEqual(card.reviewLogsArray.count, 2)
        // Should be sorted by timestamp descending
        XCTAssertEqual(card.reviewLogsArray.first?.ratingEnum, .easy)
    }

    func testDeleteDeckCascadesToCards() throws {
        let deck = Deck(context: context, name: "Test Deck")
        _ = Card(context: context, front: "Q1", back: "A1", deck: deck)
        _ = Card(context: context, front: "Q2", back: "A2", deck: deck)

        try context.save()

        let cardFetch: NSFetchRequest<Card> = Card.fetchRequest()
        var cards = try context.fetch(cardFetch)
        XCTAssertEqual(cards.count, 2)

        context.delete(deck)
        try context.save()

        cards = try context.fetch(cardFetch)
        // Cards should be deleted when deck is deleted (cascade rule)
        XCTAssertEqual(cards.count, 0)
    }

    // MARK: - Save and Fetch Tests

    func testSaveAndFetch() throws {
        let deck = Deck(context: context, name: "Saved Deck")
        _ = Card(context: context, front: "Q", back: "A", deck: deck)

        try context.save()

        let fetchRequest: NSFetchRequest<Deck> = Deck.fetchRequest()
        let decks = try context.fetch(fetchRequest)

        XCTAssertEqual(decks.count, 1)
        XCTAssertEqual(decks.first?.name, "Saved Deck")
        XCTAssertEqual(decks.first?.cardsArray.count, 1)
    }

    func testFetchWithPredicate() throws {
        let deck1 = Deck(context: context, name: "Alpha")
        let deck2 = Deck(context: context, name: "Beta")
        let deck3 = Deck(context: context, name: "Gamma")

        try context.save()

        let fetchRequest: NSFetchRequest<Deck> = Deck.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name CONTAINS[cd] %@", "a")
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Deck.name, ascending: true)]

        let decks = try context.fetch(fetchRequest)

        XCTAssertEqual(decks.count, 2) // Alpha and Gamma contain 'a'
        XCTAssertEqual(decks[0].name, "Alpha")
        XCTAssertEqual(decks[1].name, "Gamma")
    }
}
