//
//  ThemeTests.swift
//  FlashcardMVPTests
//
//  Tests for app themes and the Science Olympiad starter deck
//

import XCTest
import CoreData
@testable import FlashcardMVP

@MainActor
final class ThemeTests: XCTestCase {
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

    func testScienceOlympiadThemeExists() {
        XCTAssertTrue(AppTheme.allCases.contains(.scienceOlympiad))
        XCTAssertEqual(AppTheme(rawValue: "scienceOlympiad"), .scienceOlympiad)
        XCTAssertFalse(AppTheme.scienceOlympiad.displayName.isEmpty)
    }

    func testCreateScienceOlympiadDeck() {
        let viewModel = DeckListViewModel(context: context)
        viewModel.createScienceOlympiadDeck()

        let decks = try? context.fetch(Deck.fetchRequest() as NSFetchRequest<Deck>)
        XCTAssertEqual(decks?.count, 1)
        XCTAssertEqual(decks?.first?.cardsArray.count, AppTheme.scienceOlympiadCards.count)
    }
}
