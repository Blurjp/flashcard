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
    @State private var showingStarterPicker = false
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
            .sheet(isPresented: $showingStarterPicker) {
                StarterDeckPickerView()
            }
        }
    }

    // MARK: - Views

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.08))
                    .frame(width: 132, height: 132)
                Image(systemName: "square.stack.3d.up.slash")
                    .font(.system(size: 56))
                    .foregroundColor(.accentColor)
            }

            Text(NSLocalizedString("No Decks Yet", comment: ""))
                .font(.system(.title2, design: .rounded).weight(.semibold))

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
            .clipShape(Capsule())

            Button {
                showingStarterPicker = true
            } label: {
                Label(NSLocalizedString("Browse Starter Decks", comment: ""), systemImage: "sparkles")
                    .font(.headline)
            }
            .buttonStyle(.bordered)
            .clipShape(Capsule())
            .padding(.top, -8)
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
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
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

                Section {
                    Button {
                        showingAddDeck = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            showingStarterPicker = true
                        }
                    } label: {
                        Label(NSLocalizedString("Browse Starter Decks", comment: ""), systemImage: "sparkles")
                    }
                } footer: {
                    Text(NSLocalizedString("Add a ready-made deck: 46 topics from Math Olympiad to Korean", comment: ""))
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
                    .font(.system(.headline, design: .rounded))

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
                        .font(.caption.weight(.semibold).monospacedDigit())
                        .foregroundColor(.accentColor)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.accentColor.opacity(0.12), in: Capsule())
            } else {
                Image(systemName: "checkmark")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.green)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 6)
                    .background(Color.green.opacity(0.12), in: Capsule())
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
        )
        .contentShape(Rectangle())
    }
}

// MARK: - Previews

#Preview {
    DeckListView(context: PersistenceController.preview.viewContext)
        .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
}
