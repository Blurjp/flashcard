//
//  SettingsView.swift
//  FlashcardMVP
//
//  Settings screen with iCloud status and data export
//

import SwiftUI
import CoreData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    @State private var showingExportSheet = false
    @State private var exportedDataURL: URL?
    @State private var showingExportSuccess = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Label(NSLocalizedString("iCloud Sync", comment: ""), systemImage: "icloud")
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                } header: {
                    Text(NSLocalizedString("Sync Status", comment: ""))
                } footer: {
                    Text(NSLocalizedString("Your decks and cards sync automatically across your devices via iCloud", comment: ""))
                }

                Section {
                    Button {
                        exportData()
                    } label: {
                        Label(NSLocalizedString("Export All Decks", comment: ""), systemImage: "square.and.arrow.up")
                    }
                } header: {
                    Text(NSLocalizedString("Data", comment: ""))
                } footer: {
                    Text(NSLocalizedString("Export your decks as JSON for backup or sharing", comment: ""))
                }

                Section {
                    HStack {
                        Text(NSLocalizedString("Version", comment: ""))
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text(NSLocalizedString("Build", comment: ""))
                        Spacer()
                        Text("1")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text(NSLocalizedString("About", comment: ""))
                }
            }
            .navigationTitle(NSLocalizedString("Settings", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("Done", comment: "")) {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingExportSheet) {
                if let url = exportedDataURL {
                    ShareSheet(activityItems: [url])
                }
            }
            .alert(NSLocalizedString("Export Complete", comment: ""), isPresented: $showingExportSuccess) {
                Button(NSLocalizedString("OK", comment: ""), role: .cancel) { }
            } message: {
                Text(NSLocalizedString("Your decks have been exported successfully", comment: ""))
            }
        }
    }

    // MARK: - Data Export

    private func exportData() {
        let fetchRequest: NSFetchRequest<Deck> = Deck.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Deck.name, ascending: true)]

        do {
            let decks = try viewContext.fetch(fetchRequest)
            let exportData = decks.map { deck in
                [
                    "name": deck.name,
                    "cards": deck.cardsArray.map { card in
                        [
                            "front": card.front,
                            "back": card.back,
                            "repetition": card.repetition,
                            "intervalDays": card.intervalDays,
                            "easeFactor": card.easeFactor,
                            "dueDate": ISO8601DateFormatter().string(from: card.dueDate)
                        ] as [String : Any]
                    }
                ] as [String : Any]
            }

            let jsonData = try JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)

            let tempDirectory = FileManager.default.temporaryDirectory
            let fileName = "FlashcardMVP_Export_\(DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)).json"
            let fileURL = tempDirectory.appendingPathComponent(fileName)

            try jsonData.write(to: fileURL)

            exportedDataURL = fileURL
            showingExportSheet = true

        } catch {
            print("Error exporting data: \(error)")
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Previews

#Preview {
    SettingsView()
        .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
}
