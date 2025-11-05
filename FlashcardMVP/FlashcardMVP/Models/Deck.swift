//
//  Deck.swift
//  FlashcardMVP
//
//  Core Data entity extension for Deck
//

import CoreData
import Foundation

@objc(Deck)
public class Deck: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var cards: NSSet?

    // MARK: - Computed Properties

    public var cardsArray: [Card] {
        let set = cards as? Set<Card> ?? []
        return set.sorted { $0.createdAt < $1.createdAt }
    }

    public var dueCardsCount: Int {
        let now = Date()
        return cardsArray.filter { $0.dueDate <= now }.count
    }

    public var totalCardsCount: Int {
        cardsArray.count
    }

    // MARK: - Convenience Initializer

    convenience init(context: NSManagedObjectContext, name: String) {
        self.init(context: context)
        self.id = UUID()
        self.name = name
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Update

    public func update(name: String) {
        self.name = name
        self.updatedAt = Date()
    }
}

// MARK: - Generated accessors for cards
extension Deck {
    @objc(addCardsObject:)
    @NSManaged public func addToCards(_ value: Card)

    @objc(removeCardsObject:)
    @NSManaged public func removeFromCards(_ value: Card)

    @objc(addCards:)
    @NSManaged public func addToCards(_ values: NSSet)

    @objc(removeCards:)
    @NSManaged public func removeFromCards(_ values: NSSet)
}

extension Deck: Identifiable {}
