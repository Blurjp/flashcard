//
//  TextRecognitionService.swift
//  FlashcardMVP
//
//  Service for extracting text from images using Vision framework
//

import UIKit
import Vision

enum TextRecognitionError: Error {
    case noTextFound
    case recognitionFailed(String)
    case invalidImage
}

class TextRecognitionService {

    /// Extract text from an image using Vision framework
    /// - Parameter image: The UIImage to process
    /// - Returns: Extracted text as a single string
    static func recognizeText(from image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else {
            throw TextRecognitionError.invalidImage
        }

        return try await withCheckedThrowingContinuation { continuation in
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])

            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: TextRecognitionError.recognitionFailed(error.localizedDescription))
                    return
                }

                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(throwing: TextRecognitionError.noTextFound)
                    return
                }

                let recognizedText = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }.joined(separator: "\n")

                if recognizedText.isEmpty {
                    continuation.resume(throwing: TextRecognitionError.noTextFound)
                } else {
                    continuation.resume(returning: recognizedText)
                }
            }

            // Configure for best accuracy
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true

            do {
                try requestHandler.perform([request])
            } catch {
                continuation.resume(throwing: TextRecognitionError.recognitionFailed(error.localizedDescription))
            }
        }
    }

    /// Recognize text with progress callback (for longer operations)
    /// - Parameters:
    ///   - image: The UIImage to process
    ///   - progressHandler: Called with progress updates (0.0 to 1.0)
    /// - Returns: Extracted text
    static func recognizeText(
        from image: UIImage,
        progressHandler: @escaping (Double) -> Void
    ) async throws -> String {
        // For now, Vision doesn't support progress callbacks, but we can simulate stages
        progressHandler(0.3)

        let text = try await recognizeText(from: image)

        progressHandler(1.0)
        return text
    }
}
