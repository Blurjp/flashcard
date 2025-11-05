//
//  DeckDetailViewModel.swift
//  FlashcardMVP
//
//  ViewModel for managing deck detail and card operations
//

import CoreData
import Foundation
import SwiftUI

@MainActor
class DeckDetailViewModel: ObservableObject {
    private let context: NSManagedObjectContext
    let deck: Deck

    @Published var searchText: String = ""

    init(deck: Deck, context: NSManagedObjectContext = PersistenceController.shared.viewContext) {
        self.deck = deck
        self.context = context
    }

    // MARK: - Computed Properties

    var filteredCards: [Card] {
        if searchText.isEmpty {
            return deck.cardsArray
        }
        return deck.cardsArray.filter { card in
            card.front.localizedCaseInsensitiveContains(searchText) ||
            card.back.localizedCaseInsensitiveContains(searchText)
        }
    }

    var dueCards: [Card] {
        deck.cardsArray.filter { $0.isDue }
    }

    var totalCards: Int {
        deck.totalCardsCount
    }

    var dueCardsCount: Int {
        deck.dueCardsCount
    }

    // MARK: - Card Operations

    func deleteCard(_ card: Card) {
        context.delete(card)
        saveContext()
    }

    func deleteCards(at offsets: IndexSet) {
        let cardsToDelete = offsets.map { filteredCards[$0] }
        cardsToDelete.forEach { context.delete($0) }
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
