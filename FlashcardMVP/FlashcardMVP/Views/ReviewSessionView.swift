//
//  ReviewSessionView.swift
//  FlashcardMVP
//
//  Review session with spaced repetition
//

import SwiftUI

struct ReviewSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ReviewSessionViewModel
    @State private var showingSummary = false

    init(
        deck: Deck,
        dueOnly: Bool = true,
        context: NSManagedObjectContext = PersistenceController.shared.viewContext
    ) {
        _viewModel = StateObject(wrappedValue: ReviewSessionViewModel(
            deck: deck,
            dueOnly: dueOnly,
            context: context
        ))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if viewModel.cards.isEmpty {
                    emptyStateView
                } else if viewModel.sessionComplete {
                    sessionSummaryView
                } else {
                    reviewContentView
                }
            }
            .navigationTitle(NSLocalizedString("Review", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("Close", comment: "")) {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Views

    private var reviewContentView: some View {
        VStack(spacing: 0) {
            // Progress bar
            ProgressView(value: viewModel.progress)
                .progressViewStyle(.linear)
                .tint(.accentColor)
                .padding(.horizontal)

            Text(viewModel.progressText)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 8)

            Spacer()

            // Card content
            if let card = viewModel.currentCard {
                CardContentView(
                    card: card,
                    isRevealed: viewModel.isRevealed,
                    onReveal: viewModel.reveal
                )
            }

            Spacer()

            // Rating buttons
            if viewModel.isRevealed {
                ratingButtons
            }
        }
        .padding()
    }

    private var ratingButtons: some View {
        VStack(spacing: 12) {
            Text(NSLocalizedString("How did you do?", comment: ""))
                .font(.headline)
                .padding(.bottom, 4)

            HStack(spacing: 12) {
                ForEach(Rating.allCases, id: \.self) { rating in
                    RatingButton(rating: rating) {
                        withAnimation {
                            viewModel.rate(rating)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color(.systemBackground))
        .shadow(radius: 4)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private var sessionSummaryView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)

            Text(NSLocalizedString("Session Complete!", comment: ""))
                .font(.title)
                .fontWeight(.bold)

            VStack(spacing: 12) {
                StatRow(
                    title: NSLocalizedString("Cards Reviewed", comment: ""),
                    value: "\(viewModel.totalAnswered)"
                )

                StatRow(
                    title: NSLocalizedString("Success Rate", comment: ""),
                    value: String(format: "%.0f%%", viewModel.successRate)
                )

                StatRow(
                    title: NSLocalizedString("Good or Easy", comment: ""),
                    value: "\(viewModel.goodOrEasyCount) / \(viewModel.totalAnswered)"
                )
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)

            VStack(spacing: 12) {
                Button {
                    viewModel.restart()
                } label: {
                    Text(NSLocalizedString("Review Again", comment: ""))
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                Button {
                    dismiss()
                } label: {
                    Text(NSLocalizedString("Done", comment: ""))
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                }
            }
        }
        .padding()
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 64))
                .foregroundColor(.green)

            Text(NSLocalizedString("All Caught Up!", comment: ""))
                .font(.title2)
                .fontWeight(.semibold)

            Text(NSLocalizedString("No cards are due for review right now", comment: ""))
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button {
                dismiss()
            } label: {
                Text(NSLocalizedString("Done", comment: ""))
                    .fontWeight(.semibold)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)
        }
        .padding()
    }
}

// MARK: - Card Content View

struct CardContentView: View {
    let card: Card
    let isRevealed: Bool
    let onReveal: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            // Front side
            VStack(spacing: 12) {
                Text(NSLocalizedString("Question", comment: ""))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)

                Text(card.front)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let image = card.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200)
                    .cornerRadius(12)
            }

            Divider()
                .padding(.vertical)

            // Back side
            if isRevealed {
                VStack(spacing: 12) {
                    Text(NSLocalizedString("Answer", comment: ""))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)

                    Text(card.back)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .transition(.scale.combined(with: .opacity))
            } else {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        onReveal()
                    }
                } label: {
                    Text(NSLocalizedString("Show Answer", comment: ""))
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .shadow(radius: 4)
    }
}

// MARK: - Rating Button

struct RatingButton: View {
    let rating: Rating
    let action: () -> Void

    var body: some View {
        Button {
            action()
            // Haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        } label: {
            VStack(spacing: 4) {
                Text(rating.title)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(colorForRating(rating))
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .accessibilityLabel(rating.title)
        .accessibilityHint(NSLocalizedString("Rate your recall", comment: ""))
    }

    private func colorForRating(_ rating: Rating) -> Color {
        switch rating {
        case .again: return .red
        case .hard: return .orange
        case .good: return .green
        case .easy: return .blue
        }
    }
}

// MARK: - Stat Row

struct StatRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.body)
            Spacer()
            Text(value)
                .font(.body)
                .fontWeight(.semibold)
        }
    }
}

// MARK: - Previews

#Preview("Review Session") {
    ReviewSessionView(
        deck: PersistenceController.preview.viewContext.registeredObjects
            .compactMap { $0 as? Deck }
            .first!,
        context: PersistenceController.preview.viewContext
    )
}
