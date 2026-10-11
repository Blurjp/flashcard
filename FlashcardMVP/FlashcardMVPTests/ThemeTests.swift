//
//  ThemeTests.swift
//  FlashcardMVPTests
//
//  Tests for app themes and themed starter decks
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

    // MARK: - Theme Metadata

    func testScienceOlympiadThemeExists() {
        XCTAssertTrue(AppTheme.allCases.contains(.scienceOlympiad))
        XCTAssertEqual(AppTheme(rawValue: "scienceOlympiad"), .scienceOlympiad)
        XCTAssertFalse(AppTheme.scienceOlympiad.displayName.isEmpty)
    }

    func testAllThemesHaveMetadata() {
        for theme in AppTheme.allCases {
            XCTAssertFalse(theme.displayName.isEmpty, "Missing displayName for \(theme.rawValue)")
            XCTAssertFalse(theme.iconName.isEmpty, "Missing iconName for \(theme.rawValue)")
        }
    }

    func testRawValuesAreUnique() {
        let rawValues = AppTheme.allCases.map(\.rawValue)
        XCTAssertEqual(rawValues.count, Set(rawValues).count)
    }

    func testCategoriesCoverAllThemes() {
        let categorized = ThemeCategory.allCases.flatMap { AppTheme.themes(in: $0) }
        XCTAssertEqual(Set(categorized), Set(AppTheme.allCases))
    }

    func testExpectedThemesExist() {
        let expected: [AppTheme] = [
            .mathOlympiad, .spellingBee, .geographyBee, .quizBowl, .debate,
            .satAct, .apExams, .greToefl, .mcat,
            .languages, .coding, .history, .musicTheory,
            .midnight, .forest, .ocean, .sunset, .kids, .highContrast
        ]
        for theme in expected {
            XCTAssertTrue(AppTheme.allCases.contains(theme), "Missing theme \(theme.rawValue)")
        }
    }

    func testAppearanceOnlyThemesHaveNoStarterDeck() {
        let appearanceOnly: [AppTheme] = [.standard, .midnight, .forest, .ocean, .sunset, .kids, .highContrast]
        for theme in appearanceOnly {
            XCTAssertFalse(theme.hasStarterDeck, "\(theme.rawValue) should not have a starter deck")
        }
    }

    // MARK: - Starter Decks

    func testCreateScienceOlympiadDeck() {
        let viewModel = DeckListViewModel(context: context)
        viewModel.createScienceOlympiadDeck()

        let decks = try? context.fetch(Deck.fetchRequest() as NSFetchRequest<Deck>)
        XCTAssertEqual(decks?.count, 1)
        XCTAssertEqual(decks?.first?.cardsArray.count, AppTheme.scienceOlympiadCards.count)
    }

    func testCreateStarterDeckForEachContentTheme() {
        let viewModel = DeckListViewModel(context: context)
        let contentThemes = AppTheme.allCases.filter(\.hasStarterDeck)

        var created = 0
        for theme in contentThemes {
            XCTAssertFalse(theme.starterCards.isEmpty, "\(theme.rawValue) has a starter deck but no cards")
            viewModel.createStarterDeck(for: theme)
            created += 1

            let decks = try? context.fetch(Deck.fetchRequest() as NSFetchRequest<Deck>)
            XCTAssertEqual(decks?.count, created)
        }

        let decks = try? context.fetch(Deck.fetchRequest() as NSFetchRequest<Deck>)
        XCTAssertEqual(decks?.count, contentThemes.count)
    }

    func testCreateStarterDeckForAppearanceThemeDoesNothing() {
        let viewModel = DeckListViewModel(context: context)
        viewModel.createStarterDeck(for: .midnight)

        let decks = try? context.fetch(Deck.fetchRequest() as NSFetchRequest<Deck>)
        XCTAssertEqual(decks?.count, 0)
    }

    // MARK: - Appearance Attributes

    func testMidnightForcesDarkScheme() {
        XCTAssertEqual(AppTheme.midnight.preferredColorScheme, .dark)
        XCTAssertNil(AppTheme.standard.preferredColorScheme)
    }

    func testHighContrastThemeExists() {
        XCTAssertTrue(AppTheme.allCases.contains(.highContrast))
        XCTAssertFalse(AppTheme.highContrast.displayName.isEmpty)
    }

    func testKidsThemeUsesLargerText() {
        XCTAssertNotNil(AppTheme.kids.preferredDynamicTypeSize)
        XCTAssertNil(AppTheme.standard.preferredDynamicTypeSize)
    }
}
