//
//  PreviewContainer.swift
//  FlashcardMVP
//
//  Preview container for SwiftUI previews
//

import CoreData
import Foundation

struct PreviewContainer {
    static var shared: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        PreviewData.createSampleData(in: controller.viewContext)
        return controller
    }()
}
