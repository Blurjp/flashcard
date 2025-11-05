//
//  PersistenceController.swift
//  FlashcardMVP
//
//  Core Data stack with NSPersistentCloudKitContainer for iCloud sync
//

import CoreData
import Foundation

final class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentCloudKitContainer

    var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    // MARK: - Initialization

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "FlashcardMVP")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
            // Disable CloudKit for in-memory stores
            container.persistentStoreDescriptions.first?.cloudKitContainerOptions = nil
        } else {
            // Enable automatic migration
            let description = container.persistentStoreDescriptions.first
            description?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            description?.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        }

        container.loadPersistentStores { description, error in
            if let error = error {
                // In production, handle this error appropriately
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        // Set up notification for remote changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(processRemoteStoreChange),
            name: .NSPersistentStoreRemoteChange,
            object: container.persistentStoreCoordinator
        )
    }

    // MARK: - Remote Change Handling

    @objc private func processRemoteStoreChange(_ notification: Notification) {
        viewContext.perform {
            self.viewContext.refreshAllObjects()
        }
    }

    // MARK: - Save Context

    func save() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("Error saving context: \(nsError), \(nsError.userInfo)")
            }
        }
    }

    // MARK: - Background Context

    func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }

    // MARK: - Preview Support

    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext

        // Create sample data
        let sampleDeck = Deck(context: context)
        sampleDeck.id = UUID()
        sampleDeck.name = "Spanish Basics"
        sampleDeck.createdAt = Date()
        sampleDeck.updatedAt = Date()

        let card1 = Card(context: context)
        card1.id = UUID()
        card1.front = "Hello"
        card1.back = "Hola"
        card1.deck = sampleDeck
        card1.repetition = 0
        card1.intervalDays = 1
        card1.easeFactor = 2.5
        card1.dueDate = Date()
        card1.createdAt = Date()
        card1.updatedAt = Date()

        let card2 = Card(context: context)
        card2.id = UUID()
        card2.front = "Thank you"
        card2.back = "Gracias"
        card2.deck = sampleDeck
        card2.repetition = 0
        card2.intervalDays = 1
        card2.easeFactor = 2.5
        card2.dueDate = Date().addingTimeInterval(-86400) // Due yesterday
        card2.createdAt = Date()
        card2.updatedAt = Date()

        do {
            try context.save()
        } catch {
            print("Error creating preview data: \(error)")
        }

        return controller
    }()
}
