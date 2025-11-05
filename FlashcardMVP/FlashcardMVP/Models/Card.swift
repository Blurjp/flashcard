//
//  Card.swift
//  FlashcardMVP
//
//  Core Data entity extension for Card
//

import CoreData
import Foundation
import UIKit

@objc(Card)
public class Card: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var front: String
    @NSManaged public var back: String
    @NSManaged public var imageData: Data?
    @NSManaged public var repetition: Int16
    @NSManaged public var intervalDays: Int16
    @NSManaged public var easeFactor: Double
    @NSManaged public var dueDate: Date
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var deck: Deck?
    @NSManaged public var reviewLogs: NSSet?

    // MARK: - Computed Properties

    public var image: UIImage? {
        guard let imageData = imageData else { return nil }
        return UIImage(data: imageData)
    }

    public var isDue: Bool {
        dueDate <= Date()
    }

    public var reviewLogsArray: [ReviewLog] {
        let set = reviewLogs as? Set<ReviewLog> ?? []
        return set.sorted { $0.timestamp > $1.timestamp }
    }

    public var lastReviewDate: Date? {
        reviewLogsArray.first?.timestamp
    }

    // MARK: - Convenience Initializer

    convenience init(
        context: NSManagedObjectContext,
        front: String,
        back: String,
        deck: Deck,
        imageData: Data? = nil
    ) {
        self.init(context: context)
        self.id = UUID()
        self.front = front
        self.back = back
        self.deck = deck
        self.imageData = imageData
        self.repetition = 0
        self.intervalDays = 1
        self.easeFactor = 2.5
        self.dueDate = Date()
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Update

    public func update(front: String, back: String, imageData: Data?) {
        self.front = front
        self.back = back
        self.imageData = imageData
        self.updatedAt = Date()
    }

    // MARK: - SRS Update

    public func applySchedule(result: SRSResult) {
        self.easeFactor = result.newEaseFactor
        self.intervalDays = Int16(result.newIntervalDays)
        self.repetition = Int16(result.newRepetition)
        self.dueDate = result.newDueDate
        self.updatedAt = Date()
    }

    // MARK: - Image Compression

    public static func compressImage(_ image: UIImage, maxDimension: CGFloat = 512) -> Data? {
        let size = image.size
        let ratio = min(maxDimension / size.width, maxDimension / size.height)

        if ratio < 1 {
            let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.draw(in: CGRect(origin: .zero, size: newSize))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return resizedImage?.jpegData(compressionQuality: 0.8)
        }

        return image.jpegData(compressionQuality: 0.8)
    }
}

// MARK: - Generated accessors for reviewLogs
extension Card {
    @objc(addReviewLogsObject:)
    @NSManaged public func addToReviewLogs(_ value: ReviewLog)

    @objc(removeReviewLogsObject:)
    @NSManaged public func removeFromReviewLogs(_ value: ReviewLog)

    @objc(addReviewLogs:)
    @NSManaged public func addToReviewLogs(_ values: NSSet)

    @objc(removeReviewLogs:)
    @NSManaged public func removeFromReviewLogs(_ values: NSSet)
}

extension Card: Identifiable {}
