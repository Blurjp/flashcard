//
//  PreviewData.swift
//  FlashcardMVP
//
//  Sample data for SwiftUI previews
//

import CoreData
import Foundation

struct PreviewData {
    static func createSampleData(in context: NSManagedObjectContext) {
        // Create Spanish deck
        let spanishDeck = Deck(context: context, name: "Spanish Basics")

        let spanishCards = [
            ("Hello", "Hola"),
            ("Thank you", "Gracias"),
            ("Good morning", "Buenos días"),
            ("Goodbye", "Adiós"),
            ("Please", "Por favor")
        ]

        for (index, (front, back)) in spanishCards.enumerated() {
            let card = Card(context: context, front: front, back: back, deck: spanishDeck)
            // Make some cards due
            if index % 2 == 0 {
                card.dueDate = Date().addingTimeInterval(-86400) // Due yesterday
            } else {
                card.dueDate = Date().addingTimeInterval(86400) // Due tomorrow
            }
        }

        // Create Math deck
        let mathDeck = Deck(context: context, name: "Basic Math")

        let mathCards = [
            ("2 + 2 = ?", "4"),
            ("5 × 3 = ?", "15"),
            ("10 ÷ 2 = ?", "5"),
            ("7 - 3 = ?", "4"),
            ("3² = ?", "9")
        ]

        for (front, back) in mathCards {
            _ = Card(context: context, front: front, back: back, deck: mathDeck)
        }

        // Create Science deck
        let scienceDeck = Deck(context: context, name: "Science Facts")

        let scienceCards = [
            ("What is H₂O?", "Water"),
            ("What is the largest planet?", "Jupiter"),
            ("What is photosynthesis?", "Process plants use to convert light energy into chemical energy")
        ]

        for (front, back) in scienceCards {
            let card = Card(context: context, front: front, back: back, deck: scienceDeck)
            card.dueDate = Date() // All due today
        }

        do {
            try context.save()
        } catch {
            print("Error creating preview data: \(error)")
        }
    }
}
