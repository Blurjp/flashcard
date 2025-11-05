//
//  CardEditorView.swift
//  FlashcardMVP
//
//  Card creation and editing screen
//

import SwiftUI
import PhotosUI

struct CardEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: CardEditorViewModel
    @State private var selectedPhotoItem: PhotosPickerItem?

    init(
        deck: Deck,
        card: Card? = nil,
        context: NSManagedObjectContext = PersistenceController.shared.viewContext
    ) {
        _viewModel = StateObject(wrappedValue: CardEditorViewModel(deck: deck, card: card, context: context))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(NSLocalizedString("Front", comment: ""), text: $viewModel.front, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text(NSLocalizedString("Front Side", comment: ""))
                } footer: {
                    Text(NSLocalizedString("What you'll see first (question/prompt)", comment: ""))
                }

                Section {
                    TextField(NSLocalizedString("Back", comment: ""), text: $viewModel.back, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text(NSLocalizedString("Back Side", comment: ""))
                } footer: {
                    Text(NSLocalizedString("The answer or translation", comment: ""))
                }

                Section {
                    if let image = viewModel.selectedImage {
                        VStack {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                                .cornerRadius(8)

                            Button(role: .destructive) {
                                viewModel.removeImage()
                            } label: {
                                Label(NSLocalizedString("Remove Image", comment: ""), systemImage: "trash")
                            }
                        }
                    } else {
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            Label(NSLocalizedString("Add Image", comment: ""), systemImage: "photo")
                        }
                    }
                } header: {
                    Text(NSLocalizedString("Image (Optional)", comment: ""))
                } footer: {
                    Text(NSLocalizedString("Add a visual aid to help memorization", comment: ""))
                }
            }
            .navigationTitle(viewModel.isEditing ?
                NSLocalizedString("Edit Card", comment: "") :
                NSLocalizedString("New Card", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("Cancel", comment: "")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("Save", comment: "")) {
                        viewModel.save()
                        dismiss()
                    }
                    .disabled(!viewModel.isValid)
                }
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        viewModel.selectedImage = image
                    }
                }
            }
        }
    }
}

// MARK: - Previews

#Preview("New Card") {
    CardEditorView(
        deck: PersistenceController.preview.viewContext.registeredObjects
            .compactMap { $0 as? Deck }
            .first!,
        context: PersistenceController.preview.viewContext
    )
}

#Preview("Edit Card") {
    CardEditorView(
        deck: PersistenceController.preview.viewContext.registeredObjects
            .compactMap { $0 as? Deck }
            .first!,
        card: PersistenceController.preview.viewContext.registeredObjects
            .compactMap { $0 as? Card }
            .first,
        context: PersistenceController.preview.viewContext
    )
}
