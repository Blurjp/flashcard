//
//  TextRecognitionTests.swift
//  FlashcardMVPTests
//
//  Tests for Vision OCR text recognition
//

import XCTest
import UIKit
@testable import FlashcardMVP

final class TextRecognitionTests: XCTestCase {

    // MARK: - Image Creation Helpers

    func createTestImage(with text: String) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 400, height: 200))
        return renderer.image { context in
            // White background
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: CGSize(width: 400, height: 200)))

            // Black text
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .bold),
                .foregroundColor: UIColor.black
            ]
            let attributedString = NSAttributedString(string: text, attributes: attributes)
            attributedString.draw(at: CGPoint(x: 20, y: 80))
        }
    }

    // MARK: - Text Recognition Tests

    func testRecognizeSimpleText() async throws {
        let image = createTestImage(with: "Hello World")

        let text = try await TextRecognitionService.recognizeText(from: image)

        XCTAssertFalse(text.isEmpty, "Should recognize text")
        XCTAssertTrue(text.contains("Hello"), "Should contain 'Hello'")
    }

    func testRecognizeMultilineText() async throws {
        let image = createTestImage(with: "Line 1\nLine 2\nLine 3")

        let text = try await TextRecognitionService.recognizeText(from: image)

        XCTAssertTrue(text.contains("\n"), "Should preserve line breaks")
    }

    func testRecognizeNumbersAndText() async throws {
        let image = createTestImage(with: "Question 1: What is 2+2?")

        let text = try await TextRecognitionService.recognizeText(from: image)

        XCTAssertTrue(text.contains("Question"), "Should recognize text")
        XCTAssertTrue(text.contains("1") || text.contains("2"), "Should recognize numbers")
    }

    func testInvalidImageThrowsError() async {
        // Create an invalid/corrupted image
        let invalidImage = UIImage() // Empty image

        do {
            _ = try await TextRecognitionService.recognizeText(from: invalidImage)
            XCTFail("Should throw error for invalid image")
        } catch TextRecognitionError.invalidImage {
            // Expected error
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }

    func testProgressCallback() async throws {
        let image = createTestImage(with: "Test")
        var progressUpdates: [Double] = []

        _ = try await TextRecognitionService.recognizeText(from: image) { progress in
            progressUpdates.append(progress)
        }

        XCTAssertFalse(progressUpdates.isEmpty, "Should report progress")
        XCTAssertEqual(progressUpdates.last, 1.0, accuracy: 0.01, "Final progress should be 1.0")
    }
}
