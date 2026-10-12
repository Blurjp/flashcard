//
//  DeckListView.swift
//  FlashcardMVP
//
//  Home screen showing all decks
//

import SwiftUI
import CoreData

struct DeckListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Deck.updatedAt, ascending: false)],
        animation: .default)
    private var decks: FetchedResults<Deck>

    @StateObject private var viewModel: DeckListViewModel
    @State private var showingAddDeck = false
    @State private var showingSettings = false
    @State private var newDeckName = ""

    init(context: NSManagedObjectContext = PersistenceController.shared.viewContext) {
        _viewModel = StateObject(wrappedValue: DeckListViewModel(context: context))
    }

    var body: some View {
        NavigationStack {
            Group {
                if decks.isEmpty {
                    emptyStateView
                } else {
                    deckListView
                }
            }
            .navigationTitle(NSLocalizedString("Decks", comment: ""))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddDeck = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddDeck) {
                addDeckSheet
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }

    // MARK: - Views

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "square.stack.3d.up.slash")
                .font(.system(size: 64))
                .foregroundColor(.secondary)

            Text(NSLocalizedString("No Decks Yet", comment: ""))
                .font(.title2)
                .fontWeight(.semibold)

            Text(NSLocalizedString("Create your first deck to start learning", comment: ""))
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button {
                showingAddDeck = true
            } label: {
                Label(NSLocalizedString("Create Deck", comment: ""), systemImage: "plus.circle.fill")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)
        }
        .padding()
    }

    private var deckListView: some View {
        List {
            ForEach(decks) { deck in
                NavigationLink(destination: DeckDetailView(deck: deck)) {
                    DeckRowView(deck: deck)
                }
            }
            .onDelete(perform: deleteDeck)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
        }
        .listStyle(.insetGrouped)
    }

    private var addDeckSheet: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(NSLocalizedString("Deck Name", comment: ""), text: $newDeckName)
                        .textInputAutocapitalization(.words)
                } footer: {
                    Text(NSLocalizedString("Give your deck a memorable name", comment: ""))
                }
            }
            .navigationTitle(NSLocalizedString("New Deck", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("Cancel", comment: "")) {
                        newDeckName = ""
                        showingAddDeck = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("Create", comment: "")) {
                        createDeck()
                    }
                    .disabled(newDeckName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    // MARK: - Actions

    private func createDeck() {
        let trimmedName = newDeckName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        viewModel.createDeck(name: trimmedName)
        newDeckName = ""
        showingAddDeck = false
    }

    private func deleteDeck(offsets: IndexSet) {
        offsets.map { decks[$0] }.forEach(viewModel.deleteDeck)
    }
}

// MARK: - Deck Icon Tile

struct DeckIconTile: View {
    let deck: Deck
    var size: CGFloat = 46

    private var theme: AppTheme? {
        AppTheme.theme(forDeckName: deck.name)
    }

    private var tileGradient: LinearGradient {
        let colors = theme?.category.gradientColors
            ?? [Color.accentColor.opacity(0.75), Color.accentColor]
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                .fill(tileGradient)
            if let theme {
                Image(systemName: theme.iconName)
                    .font(.system(size: size * 0.43, weight: .semibold))
                    .foregroundColor(.white)
            } else {
                Text(String(deck.name.prefix(1)).uppercased())
                    .font(.system(size: size * 0.36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Deck Row View

struct DeckRowView: View {
    @ObservedObject var deck: Deck

    var body: some View {
        HStack(spacing: 14) {
            DeckIconTile(deck: deck)

            VStack(alignment: .leading, spacing: 3) {
                Text(deck.name)
                    .font(.headline)

                Text("\(deck.totalCardsCount) cards")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if deck.dueCardsCount > 0 {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 6, height: 6)
                    Text("\(deck.dueCardsCount) \(NSLocalizedString("Due today", comment: ""))")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.accentColor)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.accentColor.opacity(0.12), in: Capsule())
            } else {
                Text("✓")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.green)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.green.opacity(0.12), in: Capsule())
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

// MARK: - Previews

#Preview {
    DeckListView(context: PersistenceController.preview.viewContext)
        .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
}
