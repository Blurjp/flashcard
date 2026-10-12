//
//  StarterDeckPickerView.swift
//  FlashcardMVP
//
//  Browse and add themed starter decks, grouped by category
//

import SwiftUI
import CoreData

struct StarterDeckPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Deck.updatedAt, ascending: false)],
        animation: .default)
    private var decks: FetchedResults<Deck>

    var body: some View {
        NavigationStack {
            List {
                ForEach(contentCategories) { category in
                    Section {
                        ForEach(AppTheme.themes(in: category).filter(\.hasStarterDeck)) { theme in
                            StarterDeckRow(theme: theme, isAdded: isAdded(theme)) {
                                DeckListViewModel(context: viewContext).createStarterDeck(for: theme)
                            }
                        }
                    } header: {
                        HStack(spacing: 6) {
                            Image(systemName: category.iconName)
                                .font(.caption.weight(.semibold))
                            Text(category.displayName)
                        }
                        .foregroundColor(.primary.opacity(0.6))
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(NSLocalizedString("Starter Decks", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("Done", comment: "")) {
                        dismiss()
                    }
                }
            }
        }
    }

    private var contentCategories: [ThemeCategory] {
        ThemeCategory.allCases.filter { $0 != .appearance }
    }

    private func isAdded(_ theme: AppTheme) -> Bool {
        decks.contains { $0.name == theme.starterDeckName }
    }
}

// MARK: - Starter Deck Row

private struct StarterDeckRow: View {
    let theme: AppTheme
    let isAdded: Bool
    let onAdd: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: theme.category.gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Image(systemName: theme.iconName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(width: 34, height: 34)

            VStack(alignment: .leading, spacing: 2) {
                Text(theme.displayName)
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))

                Text("\(theme.starterCards.count) cards")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if isAdded {
                Label(NSLocalizedString("Added", comment: ""), systemImage: "checkmark.circle.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.green)
                    .labelStyle(.titleAndIcon)
            } else {
                Button {
                    onAdd()
                } label: {
                    Text(NSLocalizedString("Add", comment: ""))
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.accentColor.opacity(0.12), in: Capsule())
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.borderless)
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Previews

#Preview {
    StarterDeckPickerView()
        .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
}
