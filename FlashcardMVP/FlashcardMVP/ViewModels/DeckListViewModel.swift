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
