//
//  ReviewSessionView.swift
//  FlashcardMVP
//
//  Review session with spaced repetition
//

import SwiftUI
import CoreData

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
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.accentColor.opacity(0.12))
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.accentColor.opacity(0.7), .accentColor],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(8, geo.size.width * viewModel.progress))
                        .animation(.easeInOut(duration: 0.3), value: viewModel.progress)
                }
            }
            .frame(height: 8)
            .padding(.horizontal)

            Text(viewModel.progressText)
                .font(.caption.weight(.medium).monospacedDigit())
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
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top, 12)

            HStack(spacing: 10) {
                ForEach(Rating.allCases, id: \.self) { rating in
                    RatingButton(rating: rating) {
                        withAnimation {
                            viewModel.rate(rating)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 12)
        }
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .shadow(color: .black.opacity(0.06), radius: 14, y: 6)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private var sessionSummaryView: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.10))
                    .frame(width: 128, height: 128)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 72))
                    .foregroundColor(.green)
            }
            .padding(.top, 24)

            Text(NSLocalizedString("Session Complete!", comment: ""))
                .font(.title)
                .fontWeight(.bold)

            VStack(spacing: 14) {
                StatRow(
                    title: NSLocalizedString("Cards Reviewed", comment: ""),
                    value: "\(viewModel.totalAnswered)"
                )

                Divider()

                StatRow(
                    title: NSLocalizedString("Success Rate", comment: ""),
                    value: String(format: "%.0f%%", viewModel.successRate)
                )

                Divider()

                StatRow(
                    title: NSLocalizedString("Good or Easy", comment: ""),
                    value: "\(viewModel.goodOrEasyCount) / \(viewModel.totalAnswered)"
                )
            }
            .padding(20)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            VStack(spacing: 12) {
                Button {
                    viewModel.restart()
                } label: {
                    Text(NSLocalizedString("Review Again", comment: ""))
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(
                            LinearGradient(
                                colors: [.accentColor, .accentColor.opacity(0.75)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }

                Button {
                    dismiss()
                } label: {
                    Text(NSLocalizedString("Done", comment: ""))
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Color(.secondarySystemBackground))
                        .foregroundColor(.primary)
                        .clipShape(Capsule())
                }
            }
        }
        .padding()
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.10))
                    .frame(width: 128, height: 128)
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 56))
                    .foregroundColor(.green)
            }

            Text(NSLocalizedString("All Caught Up!", comment: ""))
                .font(.system(.title2, design: .rounded).weight(.semibold))

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
            VStack(spacing: 10) {
                Text(NSLocalizedString("Question", comment: ""))
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.accentColor)
                    .textCase(.uppercase)
                    .tracking(1.2)

                Text(card.front)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let image = card.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200)
                    .cornerRadius(14)
            }

            // Back side
            if isRevealed {
                VStack(spacing: 10) {
                    Text(NSLocalizedString("Answer", comment: ""))
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.accentColor)
                        .textCase(.uppercase)
                        .tracking(1.2)

                    Text(card.back)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(Color.accentColor.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .transition(.scale(scale: 0.96).combined(with: .opacity))
            } else {
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        onReveal()
                    }
                } label: {
                    Text(NSLocalizedString("Show Answer", comment: ""))
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
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
                .padding(.top, 4)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.04), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 16, y: 8)
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
            Text(rating.title)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(colorForRating(rating).opacity(0.14), in: Capsule())
                .foregroundColor(colorForRating(rating))
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
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(.subheadline, design: .rounded).weight(.semibold))
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
