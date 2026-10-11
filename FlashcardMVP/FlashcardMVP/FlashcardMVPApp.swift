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
            themedRoot
                .onAppear {
                    #if DEBUG
                    if ProcessInfo.processInfo.arguments.contains("-SeedDemoData") {
                        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                        DeckListViewModel(context: persistenceController.viewContext).seedDemoDataIfNeeded()
                    }
                    #endif
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

    @ViewBuilder
    private var themedRoot: some View {
        let base = DeckListView(context: persistenceController.viewContext)
            .environment(\.managedObjectContext, persistenceController.viewContext)
            .tint(theme.accentColor)
            .preferredColorScheme(theme.preferredColorScheme)

        if let size = theme.preferredDynamicTypeSize {
            base.dynamicTypeSize(size)
        } else {
            base
        }
    }
}
