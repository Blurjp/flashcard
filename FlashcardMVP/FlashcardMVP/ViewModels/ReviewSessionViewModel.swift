//
//  ReviewSessionViewModel.swift
//  FlashcardMVP
//
//  ViewModel for managing review sessions with SRS
//

import CoreData
import Foundation
import SwiftUI

@MainActor
class ReviewSessionViewModel: ObservableObject {
    private let context: NSManagedObjectContext
    private let deck: Deck

    @Published var cards: [Card] = []
    @Published var currentIndex: Int = 0
    @Published var isRevealed: Bool = false
    @Published var sessionComplete: Bool = false
    @Published var ratings: [Rating] = []

    var currentCard: Card? {
        guard currentIndex < cards.count else { return nil }
        return cards[currentIndex]
    }

    var progress: Double {
        guard !cards.isEmpty else { return 0 }
        return Double(currentIndex) / Double(cards.count)
    }

    var progressText: String {
        "\(currentIndex + 1) / \(cards.count)"
    }

    var hasNext: Bool {
        currentIndex < cards.count - 1
    }

    var isLastCard: Bool {
        currentIndex == cards.count - 1
    }

    // MARK: - Session Statistics

    var totalAnswered: Int {
        ratings.count
    }

    var goodOrEasyCount: Int {
        ratings.filter { $0 == .good || $0 == .easy }.count
    }

    var successRate: Double {
        guard totalAnswered > 0 else { return 0 }
        return Double(goodOrEasyCount) / Double(totalAnswered) * 100
    }

    init(
        deck: Deck,
        dueOnly: Bool = true,
        context: NSManagedObjectContext = PersistenceController.shared.viewContext
    ) {
        self.deck = deck
        self.context = context

        let allCards = deck.cardsArray
        if dueOnly {
            let dueCards = allCards.filter { $0.isDue }
            self.cards = dueCards
        } else {
            self.cards = allCards
        }

        // Shuffle due cards for variety
        if !self.cards.isEmpty {
            self.cards.shuffle()
        }
    }

    // MARK: - Card Navigation

    func reveal() {
        isRevealed = true
    }

    func rate(_ rating: Rating) {
        guard let card = currentCard else { return }

        // Apply SRS scheduling
        let result = Scheduler.schedule(
            now: Date(),
            repetition: Int(card.repetition),
            intervalDays: Int(card.intervalDays),
            easeFactor: card.easeFactor,
            rating: rating
        )

        card.applySchedule(result: result)

        // Create review log
        _ = ReviewLog(context: context, card: card, rating: rating)

        // Save rating for statistics
        ratings.append(rating)

        // Save context
        saveContext()

        // Move to next card or complete session
        if isLastCard {
            sessionComplete = true
        } else {
            currentIndex += 1
            isRevealed = false
        }
    }

    func restart() {
        currentIndex = 0
        isRevealed = false
        sessionComplete = false
        ratings = []
        cards.shuffle()
    }

    // MARK: - Preview Helpers

    func previewDueDate(for rating: Rating) -> Date {
        guard let card = currentCard else { return Date() }
        return Scheduler.previewNextDueDate(
            from: Date(),
            repetition: Int(card.repetition),
            intervalDays: Int(card.intervalDays),
            easeFactor: card.easeFactor,
            rating: rating
        )
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
