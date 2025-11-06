//
//  AIServiceTests.swift
//  FlashcardMVPTests
//
//  Tests for AI flashcard generation services
//

import XCTest
@testable import FlashcardMVP

final class AIServiceTests: XCTestCase {

    // MARK: - Mock AI Service Tests

    func testMockServiceGeneratesCards() async throws {
        let service = MockAIFlashcardService()
        let text = "The mitochondria is the powerhouse of the cell. DNA stands for deoxyribonucleic acid."

        let cards = try await service.generateFlashcards(from: text)

        XCTAssertGreaterThan(cards.count, 0, "Should generate at least one card")
        XCTAssertFalse(cards[0].front.isEmpty, "Card front should not be empty")
        XCTAssertFalse(cards[0].back.isEmpty, "Card back should not be empty")
    }

    func testMockServiceHandlesShortText() async throws {
        let service = MockAIFlashcardService()
        let text = "Short text"

        let cards = try await service.generateFlashcards(from: text)

        XCTAssertGreaterThanOrEqual(cards.count, 3, "Should generate at least 3 cards even for short text")
    }

    func testMockServiceHandlesLongText() async throws {
        let service = MockAIFlashcardService()
        let longText = String(repeating: "Sample text about science. ", count: 100)

        let cards = try await service.generateFlashcards(from: longText)

        XCTAssertLessThanOrEqual(cards.count, 10, "Should not generate more than 10 cards")
    }

    // MARK: - Generated Card Model Tests

    func testGeneratedCardDecoding() throws {
        let json = """
        {
            "front": "What is DNA?",
            "back": "Deoxyribonucleic acid",
            "confidence": 0.95
        }
        """

        let data = json.data(using: .utf8)!
        let card = try JSONDecoder().decode(GeneratedCard.self, from: data)

        XCTAssertEqual(card.front, "What is DNA?")
        XCTAssertEqual(card.back, "Deoxyribonucleic acid")
        XCTAssertEqual(card.confidence, 0.95)
    }

    func testGeneratedCardArrayDecoding() throws {
        let json = """
        [
            {"front": "Question 1", "back": "Answer 1"},
            {"front": "Question 2", "back": "Answer 2"}
        ]
        """

        let data = json.data(using: .utf8)!
        let cards = try JSONDecoder().decode([GeneratedCard].self, from: data)

        XCTAssertEqual(cards.count, 2)
        XCTAssertEqual(cards[0].front, "Question 1")
        XCTAssertEqual(cards[1].back, "Answer 2")
    }

    // MARK: - Configuration Tests

    func testAPIKeyConfiguration() {
        let config = AIServiceConfiguration.shared

        // Test setting API key
        config.apiKey = "test-api-key-123"
        XCTAssertEqual(config.apiKey, "test-api-key-123")

        // Test clearing API key
        config.apiKey = nil
        XCTAssertNil(config.apiKey)
    }

    func testServiceCreation() {
        let config = AIServiceConfiguration.shared

        // With API key - should create OpenAI service
        config.apiKey = "sk-test123"
        let serviceWithKey = config.createService()
        XCTAssertTrue(serviceWithKey is OpenAIFlashcardService)

        // Without API key - should create Mock service
        config.apiKey = nil
        let serviceWithoutKey = config.createService()
        XCTAssertTrue(serviceWithoutKey is MockAIFlashcardService)
    }
}
