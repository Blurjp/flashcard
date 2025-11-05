//
//  FlashcardMVPApp.swift
//  FlashcardMVP
//
//  Main application entry point
//

import SwiftUI

@main
struct FlashcardMVPApp: App {
    let persistenceController = PersistenceController.shared

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showingOnboarding = false

    var body: some Scene {
        WindowGroup {
            DeckListView(context: persistenceController.viewContext)
                .environment(\.managedObjectContext, persistenceController.viewContext)
                .onAppear {
                    if !hasCompletedOnboarding {
                        showingOnboarding = true
                    }
                }
                .sheet(isPresented: $showingOnboarding) {
                    OnboardingView(context: persistenceController.viewContext)
                        .interactiveDismissDisabled()
                        .onDisappear {
                            hasCompletedOnboarding = true
                        }
                }
        }
    }
}
