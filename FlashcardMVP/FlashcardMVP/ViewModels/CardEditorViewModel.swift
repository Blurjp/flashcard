//
//  CardEditorViewModel.swift
//  FlashcardMVP
//
//  ViewModel for card creation and editing
//

import CoreData
import Foundation
import SwiftUI
import UIKit

@MainActor
class CardEditorViewModel: ObservableObject {
    private let context: NSManagedObjectContext
    private let deck: Deck
    private let existingCard: Card?

    @Published var front: String
    @Published var back: String
    @Published var selectedImage: UIImage?
    @Published var showImagePicker = false

    var isEditing: Bool {
        existingCard != nil
    }

    var isValid: Bool {
        !front.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !back.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    init(
        deck: Deck,
        card: Card? = nil,
        context: NSManagedObjectContext = PersistenceController.shared.viewContext
    ) {
        self.deck = deck
        self.existingCard = card
        self.context = context
        self.front = card?.front ?? ""
        self.back = card?.back ?? ""
        self.selectedImage = card?.image
    }

    // MARK: - Actions

    func save() {
        guard isValid else { return }

        let trimmedFront = front.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedBack = back.trimmingCharacters(in: .whitespacesAndNewlines)
        let imageData = selectedImage.flatMap { Card.compressImage($0) }

        if let existingCard = existingCard {
            existingCard.update(front: trimmedFront, back: trimmedBack, imageData: imageData)
        } else {
            _ = Card(
                context: context,
                front: trimmedFront,
                back: trimmedBack,
                deck: deck,
                imageData: imageData
            )
        }

        saveContext()
    }

    func removeImage() {
        selectedImage = nil
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
