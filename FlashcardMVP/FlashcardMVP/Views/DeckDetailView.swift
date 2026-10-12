//
//  DeckDetailView.swift
//  FlashcardMVP
//
//  Deck detail screen showing all cards with search and review option
//

import SwiftUI
import CoreData

struct DeckDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var deck: Deck
    @StateObject private var viewModel: DeckDetailViewModel

    @State private var showingAddCard = false
    @State private var showingReviewSession = false
    @State private var showingCardGenerator = false
    @State private var editingCard: Card?

    init(deck: Deck, context: NSManagedObjectContext = PersistenceController.shared.viewContext) {
        self.deck = deck
        _viewModel = StateObject(wrappedValue: DeckDetailViewModel(deck: deck, context: context))
    }

    var body: some View {
        VStack(spacing: 0) {
            if !viewModel.filteredCards.isEmpty {
                cardsList
            } else {
                emptyStateView
            }
        }
        .navigationTitle(deck.name)
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $viewModel.searchText, prompt: NSLocalizedString("Search cards", comment: ""))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        showingAddCard = true
                    } label: {
                        Label(NSLocalizedString("Add Card Manually", comment: ""), systemImage: "square.and.pencil")
                    }

                    Button {
                        showingCardGenerator = true
                    } label: {
                        Label(NSLocalizedString("Generate from Photo", comment: ""), systemImage: "camera.fill")
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddCard) {
            CardEditorView(deck: deck)
        }
        .sheet(item: $editingCard) { card in
            CardEditorView(deck: deck, card: card)
        }
        .sheet(isPresented: $showingReviewSession) {
            ReviewSessionView(deck: deck)
        }
        .sheet(isPresented: $showingCardGenerator) {
            CardGeneratorView(deck: deck, context: viewContext)
        }
        .overlay(alignment: .bottom) {
            if viewModel.dueCardsCount > 0 {
                reviewButton
            }
        }
    }

    // MARK: - Views

    private var cardsList: some View {
        List {
            Section {
                HStack(spacing: 12) {
                    DeckIconTile(deck: deck)

                    HStack(spacing: 8) {
                        statChip(icon: "rectangle.stack", text: "\(viewModel.totalCards) total", tint: .secondary)
                        if viewModel.dueCardsCount > 0 {
                            statChip(icon: "clock.fill", text: "\(viewModel.dueCardsCount) due", tint: .accentColor)
                        }
                    }
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
            }

            ForEach(viewModel.filteredCards) { card in
                CardRowView(card: card)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        editingCard = card
                    }
            }
            .onDelete(perform: viewModel.deleteCards)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
        }
        .listStyle(.insetGrouped)
    }

    private func statChip(icon: String, text: String, tint: Color) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.caption.weight(.semibold))
        }
        .foregroundColor(tint)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(tint.opacity(0.10), in: Capsule())
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "rectangle.on.rectangle.slash")
                .font(.system(size: 64))
                .foregroundColor(.secondary)

            Text(NSLocalizedString("No Cards Yet", comment: ""))
                .font(.title2)
                .fontWeight(.semibold)

            Text(NSLocalizedString("Add your first card to start reviewing", comment: ""))
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            VStack(spacing: 12) {
                Button {
                    showingAddCard = true
                } label: {
                    Label(NSLocalizedString("Add Card Manually", comment: ""), systemImage: "plus.circle.fill")
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    showingCardGenerator = true
                } label: {
                    Label(NSLocalizedString("Generate from Photo", comment: ""), systemImage: "camera.fill")
                        .font(.headline)
                }
                .buttonStyle(.bordered)
            }
            .padding(.top)
        }
        .padding()
    }

    private var reviewButton: some View {
        Button {
            showingReviewSession = true
        } label: {
            HStack {
                Image(systemName: "brain.head.profile")
                Text(NSLocalizedString("Start Review", comment: ""))
                    .fontWeight(.semibold)
                Text("(\(viewModel.dueCardsCount))")
            }
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
        .padding()
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

// MARK: - Card Row View

struct CardRowView: View {
    @ObservedObject var card: Card

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(card.front)
                .font(.headline)
                .lineLimit(2)

            Text(card.back)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)

            HStack(spacing: 8) {
                if card.image != nil {
                    HStack(spacing: 3) {
                        Image(systemName: "photo")
                            .font(.caption2)
                        Text(NSLocalizedString("Has image", comment: ""))
                            .font(.caption2)
                    }
                    .foregroundColor(.secondary)
                }

                Spacer()

                duePill
            }
        }
        .padding(.vertical, 8)
    }

    private var duePill: some View {
        Text(formatDueDate(card.dueDate))
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(pillColor.opacity(0.12), in: Capsule())
            .foregroundColor(pillColor)
    }

    private var pillColor: Color {
        let now = Date()
        if card.dueDate < now {
            return card.dueDate < Calendar.current.date(byAdding: .day, value: -1, to: now) ?? now
                ? .red : .accentColor
        }
        return .secondary
    }

    private func formatDueDate(_ date: Date) -> String {
        let now = Date()
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            return NSLocalizedString("Due today", comment: "")
        } else if calendar.isDateInYesterday(date) {
            return NSLocalizedString("Due yesterday", comment: "")
        } else if date < now {
            return NSLocalizedString("Overdue", comment: "")
        } else if calendar.isDateInTomorrow(date) {
            return NSLocalizedString("Due tomorrow", comment: "")
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return "Due \(formatter.string(from: date))"
        }
    }
}

// MARK: - Previews

#Preview {
    NavigationStack {
        DeckDetailView(
            deck: PersistenceController.preview.viewContext.registeredObjects
                .compactMap { $0 as? Deck }
                .first!,
            context: PersistenceController.preview.viewContext
        )
    }
    .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
}
