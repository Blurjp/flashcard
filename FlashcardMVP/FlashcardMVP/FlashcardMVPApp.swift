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
    @AppStorage(AppTheme.storageKey) private var themeRaw = AppTheme.standard.rawValue
    @State private var showingOnboarding = false

    private var theme: AppTheme { AppTheme(rawValue: themeRaw) ?? .standard }

    var body: some Scene {
        WindowGroup {
            DeckListView(context: persistenceController.viewContext)
                .environment(\.managedObjectContext, persistenceController.viewContext)
                .tint(theme.accentColor)
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
