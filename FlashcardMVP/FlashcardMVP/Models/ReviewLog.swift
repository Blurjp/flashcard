//
//  ReviewLog.swift
//  FlashcardMVP
//
//  Core Data entity extension for ReviewLog
//

import CoreData
import Foundation

@objc(ReviewLog)
public class ReviewLog: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var rating: Int16
    @NSManaged public var timestamp: Date
    @NSManaged public var card: Card?

    // MARK: - Computed Properties

    public var ratingEnum: Rating? {
        Rating(rawValue: Int(rating))
    }

    // MARK: - Convenience Initializer

    convenience init(
        context: NSManagedObjectContext,
        card: Card,
        rating: Rating
    ) {
        self.init(context: context)
        self.id = UUID()
        self.card = card
        self.rating = Int16(rating.rawValue)
        self.timestamp = Date()
    }
}

extension ReviewLog: Identifiable {}
