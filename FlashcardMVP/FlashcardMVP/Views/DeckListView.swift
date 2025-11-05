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
        }
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

// MARK: - Deck Row View

struct DeckRowView: View {
    @ObservedObject var deck: Deck

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(deck.name)
                    .font(.headline)

                Text("\(deck.totalCardsCount) cards")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if deck.dueCardsCount > 0 {
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(deck.dueCardsCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.accentColor)

                    Text(NSLocalizedString("Due today", comment: ""))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Previews

#Preview {
    DeckListView(context: PersistenceController.preview.viewContext)
        .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
}
