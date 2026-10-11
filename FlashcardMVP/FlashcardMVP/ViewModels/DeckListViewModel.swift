//
//  DeckListViewModel.swift
//  FlashcardMVP
//
//  ViewModel for managing deck list operations
//

import CoreData
import Foundation
import SwiftUI

@MainActor
class DeckListViewModel: ObservableObject {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.viewContext) {
        self.context = context
    }

    // MARK: - CRUD Operations

    func createDeck(name: String) {
        let deck = Deck(context: context, name: name)
        saveContext()
    }

    func deleteDeck(_ deck: Deck) {
        context.delete(deck)
        saveContext()
    }

    func updateDeck(_ deck: Deck, name: String) {
        deck.update(name: name)
        saveContext()
    }

    // MARK: - Sample Data

    func createSampleDeck() {
        let deck = Deck(context: context, name: NSLocalizedString("Sample Deck", comment: ""))

        let sampleCards = [
            ("What is the capital of France?", "Paris"),
            ("What is 2 + 2?", "4"),
            ("What is the largest planet?", "Jupiter"),
            ("Who wrote Romeo and Juliet?", "William Shakespeare"),
            ("What is the chemical symbol for water?", "H₂O")
        ]

        for (front, back) in sampleCards {
            _ = Card(context: context, front: front, back: back, deck: deck)
        }

        saveContext()
    }

    func createScienceOlympiadDeck() {
        createStarterDeck(for: .scienceOlympiad)
    }

    /// Creates the themed starter deck for any theme that ships one.
    func createStarterDeck(for theme: AppTheme) {
        guard theme.hasStarterDeck else { return }

        let deck = Deck(context: context, name: theme.starterDeckName)

        for (front, back) in theme.starterCards {
            _ = Card(context: context, front: front, back: back, deck: deck)
        }

        saveContext()
    }

    #if DEBUG
    /// Seeds a small demo dataset for App Store capture runs (-SeedDemoData).
    func seedDemoDataIfNeeded() {
        let decks = (try? context.fetch(Deck.fetchRequest())) ?? []
        guard decks.isEmpty else { return }

        let demoDecks: [(String, [(String, String)])] = [
            ("Science Olympiad", [
                ("What is the SI unit of force?", "Newton (N)"),
                ("What organelle produces most of a cell's ATP?", "Mitochondrion"),
                ("What is Avogadro's number?", "6.022 × 10²³ per mole")
            ]),
            ("Math Olympiad", [
                ("State the quadratic formula.", "x = (−b ± √(b² − 4ac)) / 2a"),
                ("State the Pythagorean theorem.", "a² + b² = c²")
            ]),
            ("Languages", [
                ("Chinese (HSK 1): 你好", "Hello (nǐ hǎo)"),
                ("Japanese (JLPT N5): ありがとう", "Thank you (arigatō)"),
                ("Spanish: 'Where is the library?'", "¿Dónde está la biblioteca?")
            ]),
            ("Coding", [
                ("What is the time complexity of binary search?", "O(log n) on a sorted array"),
                ("Which design pattern ensures one instance?", "Singleton")
            ])
        ]

        for (name, cards) in demoDecks {
            let deck = Deck(context: context, name: name)
            for (front, back) in cards {
                _ = Card(context: context, front: front, back: back, deck: deck)
            }
        }

        saveContext()
    }
    #endif

    // MARK: - Private Helpers

    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
}
