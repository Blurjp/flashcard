//
//  CardGeneratorView.swift
//  FlashcardMVP
//
//  AI-powered flashcard generation from photos
//

import SwiftUI

struct CardGeneratorView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: CardGeneratorViewModel

    @State private var showingCamera = false
    @State private var showingPhotoLibrary = false
    @State private var showingImagePicker = false
    @State private var selectedCards = Set<UUID>()
    @State private var showingAPIKeyAlert = false

    init(deck: Deck, context: NSManagedObjectContext = PersistenceController.shared.viewContext) {
        _viewModel = StateObject(wrappedValue: CardGeneratorViewModel(deck: deck, context: context))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                switch viewModel.currentStep {
                case .selectImage:
                    selectImageView
                case .recognizingText, .generatingCards:
                    processingView
                case .reviewingCards:
                    reviewCardsView
                case .complete:
                    completeView
                }
            }
            .navigationTitle(NSLocalizedString("Generate Cards", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("Cancel", comment: "")) {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingCamera) {
                CameraView(sourceType: .camera) { image in
                    Task {
                        await viewModel.processImage(image)
                    }
                }
            }
            .sheet(isPresented: $showingPhotoLibrary) {
                CameraView(sourceType: .photoLibrary) { image in
                    Task {
                        await viewModel.processImage(image)
                    }
                }
            }
            .alert(NSLocalizedString("API Key Required", comment: ""), isPresented: $showingAPIKeyAlert) {
                Button(NSLocalizedString("Go to Settings", comment: ""), role: .none) {
                    // Navigate to settings
                }
                Button(NSLocalizedString("Use Demo Mode", comment: ""), role: .cancel) {}
            } message: {
                Text(NSLocalizedString("Configure your OpenAI API key in Settings to use AI generation, or continue with demo mode.", comment: ""))
            }
        }
    }

    // MARK: - Select Image View

    private var selectImageView: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "doc.text.image")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)

            VStack(spacing: 12) {
                Text(NSLocalizedString("Generate Flashcards", comment: ""))
                    .font(.title)
                    .fontWeight(.bold)

                Text(NSLocalizedString("Take a photo of your study material and AI will create flashcards automatically", comment: ""))
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Spacer()

            VStack(spacing: 16) {
                if CameraPermissionHelper.isCameraAvailable() {
                    Button {
                        Task {
                            let hasPermission = await CameraPermissionHelper.checkCameraPermission()
                            if hasPermission {
                                showingCamera = true
                            }
                        }
                    } label: {
                        Label(NSLocalizedString("Take Photo", comment: ""), systemImage: "camera.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }

                Button {
                    showingPhotoLibrary = true
                } label: {
                    Label(NSLocalizedString("Choose from Library", comment: ""), systemImage: "photo.on.rectangle")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 32)

            if viewModel.errorMessage != nil {
                errorBanner
            }
        }
    }

    // MARK: - Processing View

    private var processingView: some View {
        VStack(spacing: 32) {
            if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200)
                    .cornerRadius(12)
                    .shadow(radius: 4)
            }

            VStack(spacing: 16) {
                ProgressView(value: viewModel.progress)
                    .progressViewStyle(.linear)
                    .tint(.accentColor)

                Text(statusText)
                    .font(.headline)
                    .foregroundColor(.secondary)

                if viewModel.currentStep == .recognizingText {
                    Text(NSLocalizedString("Extracting text from image...", comment: ""))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    Text(NSLocalizedString("Generating flashcards with AI...", comment: ""))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
        .padding()
    }

    private var statusText: String {
        switch viewModel.currentStep {
        case .recognizingText:
            return NSLocalizedString("Reading text...", comment: "")
        case .generatingCards:
            return NSLocalizedString("Creating flashcards...", comment: "")
        default:
            return ""
        }
    }

    // MARK: - Review Cards View

    private var reviewCardsView: some View {
        VStack(spacing: 0) {
            // Header with select all
            HStack {
                Text("\(viewModel.generatedCards.count) cards generated")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()

                Button {
                    if selectedCards.count == viewModel.generatedCards.count {
                        selectedCards.removeAll()
                    } else {
                        selectedCards = Set(viewModel.generatedCards.map { $0.id })
                    }
                } label: {
                    Text(selectedCards.count == viewModel.generatedCards.count ?
                         NSLocalizedString("Deselect All", comment: "") :
                         NSLocalizedString("Select All", comment: ""))
                        .font(.subheadline)
                }
            }
            .padding()
            .background(Color(.systemBackground))

            // Cards list
            List {
                ForEach(viewModel.generatedCards) { card in
                    GeneratedCardRow(
                        card: card,
                        isSelected: selectedCards.contains(card.id),
                        onToggle: { toggleCardSelection(card) },
                        onEdit: { viewModel.selectedCardForEdit = card },
                        onDelete: { viewModel.deleteCard(card) }
                    )
                }
            }
            .listStyle(.insetGrouped)

            // Action buttons
            VStack(spacing: 12) {
                Button {
                    if selectedCards.isEmpty {
                        viewModel.saveAllCards()
                    } else {
                        viewModel.saveSelectedCards(selectedCards)
                    }
                } label: {
                    Text(selectedCards.isEmpty ?
                         NSLocalizedString("Save All Cards", comment: "") :
                         NSLocalizedString("Save Selected (\(selectedCards.count))", comment: ""))
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(selectedCards.isEmpty && viewModel.generatedCards.isEmpty)

                Button {
                    viewModel.reset()
                } label: {
                    Text(NSLocalizedString("Start Over", comment: ""))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .shadow(radius: 4)
        }
        .sheet(item: $viewModel.selectedCardForEdit) { card in
            EditGeneratedCardView(
                card: card,
                onSave: { front, back in
                    viewModel.updateCard(card, front: front, back: back)
                }
            )
        }
        .onAppear {
            // Select all cards by default
            selectedCards = Set(viewModel.generatedCards.map { $0.id })
        }
    }

    // MARK: - Complete View

    private var completeView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)

            Text(NSLocalizedString("Cards Saved!", comment: ""))
                .font(.title)
                .fontWeight(.bold)

            Text(NSLocalizedString("Your flashcards have been added to the deck", comment: ""))
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button {
                dismiss()
            } label: {
                Text(NSLocalizedString("Done", comment: ""))
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.top)
        }
        .padding()
    }

    // MARK: - Error Banner

    private var errorBanner: some View {
        Group {
            if let error = viewModel.errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text(error)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Helpers

    private func toggleCardSelection(_ card: GeneratedCard) {
        if selectedCards.contains(card.id) {
            selectedCards.remove(card.id)
        } else {
            selectedCards.insert(card.id)
        }
    }
}

// MARK: - Generated Card Row

struct GeneratedCardRow: View {
    let card: GeneratedCard
    let isSelected: Bool
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isSelected ? .accentColor : .gray)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 8) {
                Text(card.front)
                    .font(.headline)
                    .lineLimit(2)

                Divider()

                Text(card.back)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)

                if let confidence = card.confidence {
                    HStack {
                        Image(systemName: "sparkles")
                            .font(.caption2)
                        Text(String(format: "%.0f%% confidence", confidence * 100))
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
            }

            Spacer()

            Menu {
                Button {
                    onEdit()
                } label: {
                    Label(NSLocalizedString("Edit", comment: ""), systemImage: "pencil")
                }

                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label(NSLocalizedString("Delete", comment: ""), systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Edit Generated Card View

struct EditGeneratedCardView: View {
    @Environment(\.dismiss) private var dismiss

    let card: GeneratedCard
    let onSave: (String, String) -> Void

    @State private var front: String
    @State private var back: String

    init(card: GeneratedCard, onSave: @escaping (String, String) -> Void) {
        self.card = card
        self.onSave = onSave
        _front = State(initialValue: card.front)
        _back = State(initialValue: card.back)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(NSLocalizedString("Front", comment: "")) {
                    TextField(NSLocalizedString("Question", comment: ""), text: $front, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section(NSLocalizedString("Back", comment: "")) {
                    TextField(NSLocalizedString("Answer", comment: ""), text: $back, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(NSLocalizedString("Edit Card", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("Cancel", comment: "")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("Save", comment: "")) {
                        onSave(front, back)
                        dismiss()
                    }
                    .disabled(front.isEmpty || back.isEmpty)
                }
            }
        }
    }
}

// MARK: - Previews

#Preview("Select Image") {
    CardGeneratorView(
        deck: PersistenceController.preview.viewContext.registeredObjects
            .compactMap { $0 as? Deck }
            .first!,
        context: PersistenceController.preview.viewContext
    )
}
