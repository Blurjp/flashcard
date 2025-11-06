//
//  CardGeneratorViewModel.swift
//  FlashcardMVP
//
//  ViewModel for photo-to-flashcard generation
//

import CoreData
import Foundation
import SwiftUI
import UIKit

enum GenerationStep {
    case selectImage
    case recognizingText
    case generatingCards
    case reviewingCards
    case complete
}

enum GenerationError: LocalizedError {
    case noImageSelected
    case textRecognitionFailed(String)
    case cardGenerationFailed(String)
    case noAPIKey

    var errorDescription: String? {
        switch self {
        case .noImageSelected:
            return NSLocalizedString("No image selected", comment: "")
        case .textRecognitionFailed(let message):
            return NSLocalizedString("Text recognition failed: \(message)", comment: "")
        case .cardGenerationFailed(let message):
            return NSLocalizedString("Card generation failed: \(message)", comment: "")
        case .noAPIKey:
            return NSLocalizedString("No API key configured. Using mock generator.", comment: "")
        }
    }
}

@MainActor
class CardGeneratorViewModel: ObservableObject {
    private let context: NSManagedObjectContext
    private let deck: Deck
    private let aiService: AIServiceProtocol

    @Published var currentStep: GenerationStep = .selectImage
    @Published var selectedImage: UIImage?
    @Published var recognizedText: String = ""
    @Published var generatedCards: [GeneratedCard] = []
    @Published var progress: Double = 0.0
    @Published var errorMessage: String?
    @Published var isProcessing: Bool = false

    // For editing generated cards before saving
    @Published var selectedCardForEdit: GeneratedCard?

    init(
        deck: Deck,
        context: NSManagedObjectContext = PersistenceController.shared.viewContext,
        aiService: AIServiceProtocol? = nil
    ) {
        self.deck = deck
        self.context = context
        self.aiService = aiService ?? AIServiceConfiguration.shared.createService()
    }

    // MARK: - Main Generation Flow

    func processImage(_ image: UIImage) async {
        selectedImage = image
        isProcessing = true
        errorMessage = nil

        do {
            // Step 1: Recognize text
            currentStep = .recognizingText
            progress = 0.0

            recognizedText = try await TextRecognitionService.recognizeText(from: image) { prog in
                await MainActor.run {
                    self.progress = prog * 0.4 // 0-40%
                }
            }

            progress = 0.5 // 50%

            // Step 2: Generate cards
            currentStep = .generatingCards

            generatedCards = try await aiService.generateFlashcards(from: recognizedText)

            progress = 1.0 // 100%

            // Step 3: Review cards
            currentStep = .reviewingCards

        } catch let error as TextRecognitionError {
            errorMessage = handleTextRecognitionError(error)
            currentStep = .selectImage
        } catch let error as AIServiceError {
            errorMessage = handleAIServiceError(error)
            currentStep = .selectImage
        } catch {
            errorMessage = error.localizedDescription
            currentStep = .selectImage
        }

        isProcessing = false
    }

    // MARK: - Card Management

    func updateCard(_ card: GeneratedCard, front: String, back: String) {
        if let index = generatedCards.firstIndex(where: { $0.id == card.id }) {
            generatedCards[index].front = front
            generatedCards[index].back = back
        }
    }

    func deleteCard(_ card: GeneratedCard) {
        generatedCards.removeAll { $0.id == card.id }
    }

    func saveAllCards() {
        for generatedCard in generatedCards {
            _ = Card(
                context: context,
                front: generatedCard.front,
                back: generatedCard.back,
                deck: deck
            )
        }

        saveContext()
        currentStep = .complete
    }

    func saveSelectedCards(_ selectedCards: Set<UUID>) {
        for generatedCard in generatedCards where selectedCards.contains(generatedCard.id) {
            _ = Card(
                context: context,
                front: generatedCard.front,
                back: generatedCard.back,
                deck: deck
            )
        }

        saveContext()
        currentStep = .complete
    }

    func reset() {
        currentStep = .selectImage
        selectedImage = nil
        recognizedText = ""
        generatedCards = []
        progress = 0.0
        errorMessage = nil
        isProcessing = false
    }

    // MARK: - Error Handling

    private func handleTextRecognitionError(_ error: TextRecognitionError) -> String {
        switch error {
        case .noTextFound:
            return NSLocalizedString("No text found in the image. Please try a clearer photo.", comment: "")
        case .recognitionFailed(let message):
            return NSLocalizedString("Text recognition failed: \(message)", comment: "")
        case .invalidImage:
            return NSLocalizedString("Invalid image format.", comment: "")
        }
    }

    private func handleAIServiceError(_ error: AIServiceError) -> String {
        switch error {
        case .invalidAPIKey:
            return NSLocalizedString("Invalid API key. Please check your settings.", comment: "")
        case .networkError(let message):
            return NSLocalizedString("Network error: \(message)", comment: "")
        case .invalidResponse:
            return NSLocalizedString("Invalid response from AI service.", comment: "")
        case .rateLimitExceeded:
            return NSLocalizedString("Rate limit exceeded. Please try again later.", comment: "")
        case .noCardsGenerated:
            return NSLocalizedString("No flashcards could be generated from this text.", comment: "")
        }
    }

    // MARK: - Private Helpers

    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
                errorMessage = "Failed to save cards: \(error.localizedDescription)"
            }
        }
    }
}
