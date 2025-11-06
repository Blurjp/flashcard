//
//  ViewModelIntegrationTests.swift
//  FlashcardMVPTests
//
//  Integration tests for ViewModels with Core Data
//

import XCTest
import CoreData
@testable import FlashcardMVP

@MainActor
final class ViewModelIntegrationTests: XCTestCase {
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

    // MARK: - DeckListViewModel Tests

    func testCreateDeck() {
        let viewModel = DeckListViewModel(context: context)

        viewModel.createDeck(name: "Test Deck")

        let fetchRequest: NSFetchRequest<Deck> = Deck.fetchRequest()
        let decks = try? context.fetch(fetchRequest)

        XCTAssertEqual(decks?.count, 1)
        XCTAssertEqual(decks?.first?.name, "Test Deck")
    }

    func testDeleteDeck() {
        let deck = Deck(context: context, name: "Delete Me")
        try? context.save()

        let viewModel = DeckListViewModel(context: context)
        viewModel.deleteDeck(deck)

        let fetchRequest: NSFetchRequest<Deck> = Deck.fetchRequest()
        let decks = try? context.fetch(fetchRequest)

        XCTAssertEqual(decks?.count, 0)
    }

    // MARK: - DeckDetailViewModel Tests

    func testFilterCards() {
        let deck = Deck(context: context, name: "Test Deck")
        _ = Card(context: context, front: "Apple", back: "A fruit", deck: deck)
        _ = Card(context: context, front: "Banana", back: "Yellow fruit", deck: deck)
        try? context.save()

        let viewModel = DeckDetailViewModel(deck: deck, context: context)
        viewModel.searchText = "Apple"

        XCTAssertEqual(viewModel.filteredCards.count, 1)
        XCTAssertEqual(viewModel.filteredCards.first?.front, "Apple")
    }

    func testDueCardsCount() {
        let deck = Deck(context: context, name: "Test Deck")

        let dueCard = Card(context: context, front: "Q1", back: "A1", deck: deck)
        dueCard.dueDate = Date().addingTimeInterval(-86400) // Yesterday

        let notDueCard = Card(context: context, front: "Q2", back: "A2", deck: deck)
        notDueCard.dueDate = Date().addingTimeInterval(86400) // Tomorrow

        try? context.save()

        let viewModel = DeckDetailViewModel(deck: deck, context: context)

        XCTAssertEqual(viewModel.dueCardsCount, 1)
        XCTAssertEqual(viewModel.totalCards, 2)
    }

    // MARK: - ReviewSessionViewModel Tests

    func testReviewSessionInitialization() {
        let deck = Deck(context: context, name: "Test Deck")
        let card1 = Card(context: context, front: "Q1", back: "A1", deck: deck)
        card1.dueDate = Date().addingTimeInterval(-3600) // 1 hour ago

        let card2 = Card(context: context, front: "Q2", back: "A2", deck: deck)
        card2.dueDate = Date().addingTimeInterval(86400) // Tomorrow

        try? context.save()

        let viewModel = ReviewSessionViewModel(deck: deck, dueOnly: true, context: context)

        XCTAssertEqual(viewModel.cards.count, 1, "Should only load due cards")
        XCTAssertNotNil(viewModel.currentCard)
    }

    func testRateCardUpdatesSchedule() {
        let deck = Deck(context: context, name: "Test Deck")
        let card = Card(context: context, front: "Q", back: "A", deck: deck)
        card.dueDate = Date()
        card.repetition = 0
        card.intervalDays = 1
        card.easeFactor = 2.5
        try? context.save()

        let viewModel = ReviewSessionViewModel(deck: deck, dueOnly: true, context: context)
        viewModel.rate(.good)

        // Card should be updated
        XCTAssertGreaterThan(card.repetition, 0)
        XCTAssertGreaterThan(card.dueDate, Date())

        // Review log should be created
        XCTAssertEqual(card.reviewLogsArray.count, 1)
        XCTAssertEqual(card.reviewLogsArray.first?.ratingEnum, .good)
    }

    func testSessionStatistics() {
        let deck = Deck(context: context, name: "Test Deck")
        _ = Card(context: context, front: "Q1", back: "A1", deck: deck)
        _ = Card(context: context, front: "Q2", back: "A2", deck: deck)
        _ = Card(context: context, front: "Q3", back: "A3", deck: deck)
        try? context.save()

        let viewModel = ReviewSessionViewModel(deck: deck, dueOnly: false, context: context)

        viewModel.rate(.good)
        viewModel.rate(.easy)
        viewModel.rate(.again)

        XCTAssertEqual(viewModel.totalAnswered, 3)
        XCTAssertEqual(viewModel.goodOrEasyCount, 2)
        XCTAssertEqual(viewModel.successRate, 66.66, accuracy: 0.1)
    }

    // MARK: - CardGeneratorViewModel Tests

    func testCardGeneratorInitialState() {
        let deck = Deck(context: context, name: "Test Deck")
        let viewModel = CardGeneratorViewModel(deck: deck, context: context)

        XCTAssertEqual(viewModel.currentStep, .selectImage)
        XCTAssertTrue(viewModel.generatedCards.isEmpty)
        XCTAssertFalse(viewModel.isProcessing)
    }

    func testSaveAllCards() {
        let deck = Deck(context: context, name: "Test Deck")
        let viewModel = CardGeneratorViewModel(deck: deck, context: context)

        // Simulate generated cards
        viewModel.generatedCards = [
            GeneratedCard(front: "Q1", back: "A1", confidence: 0.9),
            GeneratedCard(front: "Q2", back: "A2", confidence: 0.8)
        ]

        viewModel.saveAllCards()

        XCTAssertEqual(deck.cardsArray.count, 2)
        XCTAssertEqual(viewModel.currentStep, .complete)
    }
}
