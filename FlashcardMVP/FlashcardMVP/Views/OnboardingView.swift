//
//  OnboardingView.swift
//  FlashcardMVP
//
//  First-time user onboarding experience
//

import SwiftUI

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
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
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

            Image(systemName: systemImage)
                .font(.system(size: 80))
                .foregroundColor(.accentColor)

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
