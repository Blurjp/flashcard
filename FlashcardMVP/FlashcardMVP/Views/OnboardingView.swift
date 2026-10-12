//
//  OnboardingView.swift
//  FlashcardMVP
//
//  First-time user onboarding experience
//

import SwiftUI
import CoreData

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: DeckListViewModel

    @State private var currentPage = 0

    init(context: NSManagedObjectContext = PersistenceController.shared.viewContext) {
        _viewModel = StateObject(wrappedValue: DeckListViewModel(context: context))
    }

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                OnboardingPageView(
                    systemImage: "square.stack.3d.up.fill",
                    title: NSLocalizedString("Create Decks", comment: ""),
                    description: NSLocalizedString("Organize your flashcards into decks by topic or subject", comment: "")
                )
                .tag(0)

                OnboardingPageView(
                    systemImage: "rectangle.on.rectangle.fill",
                    title: NSLocalizedString("Add Cards", comment: ""),
                    description: NSLocalizedString("Create flashcards with questions and answers, including images", comment: "")
                )
                .tag(1)

                OnboardingPageView(
                    systemImage: "brain.head.profile",
                    title: NSLocalizedString("Review Daily", comment: ""),
                    description: NSLocalizedString("Smart spaced repetition helps you remember what you learn", comment: "")
                )
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            VStack(spacing: 16) {
                Button {
                    getStarted()
                } label: {
                    Text(NSLocalizedString("Get Started", comment: ""))
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [.accentColor, .accentColor.opacity(0.75)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .shadow(color: .accentColor.opacity(0.35), radius: 10, y: 5)
                }
                .padding(.horizontal)

                Button {
                    dismiss()
                } label: {
                    Text(NSLocalizedString("Skip", comment: ""))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.bottom)
        }
        .background(
            LinearGradient(
                colors: [Color.accentColor.opacity(0.06), Color(.systemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }

    private func getStarted() {
        viewModel.createSampleDeck()
        dismiss()
    }
}

// MARK: - Onboarding Page View

struct OnboardingPageView: View {
    let systemImage: String
    let title: String
    let description: String

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.10))
                    .frame(width: 150, height: 150)

                Image(systemName: systemImage)
                    .font(.system(size: 64))
                    .foregroundColor(.accentColor)
            }

            VStack(spacing: 12) {
                Text(title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()
        }
        .padding()
    }
}

// MARK: - Previews

#Preview {
    OnboardingView(context: PersistenceController.preview.viewContext)
}
