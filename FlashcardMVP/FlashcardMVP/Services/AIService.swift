//
//  AIService.swift
//  FlashcardMVP
//
//  Service for generating flashcards from text using AI
//

import Foundation

enum AIServiceError: Error {
    case invalidAPIKey
    case networkError(String)
    case invalidResponse
    case rateLimitExceeded
    case noCardsGenerated
}

// MARK: - Generated Card Model

struct GeneratedCard: Identifiable, Codable {
    let id = UUID()
    var front: String
    var back: String
    var confidence: Double? // Optional confidence score

    enum CodingKeys: String, CodingKey {
        case front, back, confidence
    }
}

// MARK: - AI Service Protocol

protocol AIServiceProtocol {
    func generateFlashcards(from text: String) async throws -> [GeneratedCard]
}

// MARK: - OpenAI Implementation

class OpenAIFlashcardService: AIServiceProtocol {
    private let apiKey: String
    private let endpoint = "https://api.openai.com/v1/chat/completions"
    private let model = "gpt-3.5-turbo" // or "gpt-4" for better results

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    func generateFlashcards(from text: String) async throws -> [GeneratedCard] {
        guard !apiKey.isEmpty else {
            throw AIServiceError.invalidAPIKey
        }

        let prompt = """
        You are an expert educational assistant. Analyze the following text and generate flashcards for studying.

        For each flashcard:
        - Create a clear, concise question for the front
        - Provide a complete, accurate answer for the back
        - Focus on key concepts, definitions, and important facts
        - Generate 5-15 cards depending on content length

        Return ONLY valid JSON in this exact format (no markdown, no code blocks):
        [{"front": "question here", "back": "answer here"}]

        Text to analyze:
        \(text)
        """

        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": model,
            "messages": [
                ["role": "system", "content": "You are a flashcard generator. Always respond with valid JSON arrays only."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7,
            "max_tokens": 2000
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIServiceError.networkError("Invalid response")
        }

        if httpResponse.statusCode == 429 {
            throw AIServiceError.rateLimitExceeded
        }

        guard httpResponse.statusCode == 200 else {
            throw AIServiceError.networkError("HTTP \(httpResponse.statusCode)")
        }

        // Parse OpenAI response
        let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        guard let content = openAIResponse.choices.first?.message.content else {
            throw AIServiceError.invalidResponse
        }

        // Extract JSON from content (remove markdown code blocks if present)
        let jsonString = content
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let jsonData = jsonString.data(using: .utf8) else {
            throw AIServiceError.invalidResponse
        }

        let cards = try JSONDecoder().decode([GeneratedCard].self, from: jsonData)

        guard !cards.isEmpty else {
            throw AIServiceError.noCardsGenerated
        }

        return cards
    }

    // MARK: - OpenAI Response Models

    private struct OpenAIResponse: Codable {
        let choices: [Choice]
    }

    private struct Choice: Codable {
        let message: Message
    }

    private struct Message: Codable {
        let content: String
    }
}

// MARK: - Mock Service for Development/Testing

class MockAIFlashcardService: AIServiceProtocol {
    func generateFlashcards(from text: String) async throws -> [GeneratedCard] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds

        // Generate mock cards based on text length
        let words = text.split(separator: " ")
        let cardCount = min(max(words.count / 20, 3), 10)

        var cards: [GeneratedCard] = []
        for i in 1...cardCount {
            cards.append(GeneratedCard(
                front: "Question \(i) from the material",
                back: "Answer \(i) based on: \(words.prefix(10).joined(separator: " "))...",
                confidence: 0.85
            ))
        }

        return cards
    }
}

// MARK: - Configuration

class AIServiceConfiguration {
    static var shared = AIServiceConfiguration()

    private var _apiKey: String?

    var apiKey: String? {
        get {
            // Try to get from UserDefaults, then from _apiKey
            if let stored = UserDefaults.standard.string(forKey: "ai_service_api_key") {
                return stored
            }
            return _apiKey
        }
        set {
            _apiKey = newValue
            if let key = newValue {
                UserDefaults.standard.set(key, forKey: "ai_service_api_key")
            } else {
                UserDefaults.standard.removeObject(forKey: "ai_service_api_key")
            }
        }
    }

    func createService() -> AIServiceProtocol {
        if let apiKey = apiKey, !apiKey.isEmpty {
            return OpenAIFlashcardService(apiKey: apiKey)
        } else {
            // Use mock service when no API key is configured
            return MockAIFlashcardService()
        }
    }
}
