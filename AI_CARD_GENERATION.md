# AI-Powered Flashcard Generation

FlashcardMVP includes an innovative feature that uses AI to automatically generate flashcards from photos of your study materials.

## Overview

Take a photo of textbooks, lecture notes, or any study material, and the app will:
1. **Extract text** using iOS Vision framework (on-device OCR)
2. **Generate flashcards** using AI (OpenAI GPT models)
3. **Review and edit** generated cards before saving
4. **Save to your deck** for immediate study

## How It Works

### Architecture

```
┌──────────────┐
│  Take Photo  │
│  or Select   │
└──────┬───────┘
       │
       ▼
┌──────────────────┐
│ Vision Framework │  ← On-device OCR
│ Text Recognition │
└──────┬───────────┘
       │
       ▼ Extracted Text
       │
┌──────────────────┐
│  AI Service      │  ← OpenAI API or Mock
│  (GPT-3.5/4)     │
└──────┬───────────┘
       │
       ▼ Generated Cards (JSON)
       │
┌──────────────────┐
│ Review & Edit    │  ← User approves
│   Interface      │
└──────┬───────────┘
       │
       ▼
┌──────────────────┐
│  Save to Deck    │  ← Core Data
└──────────────────┘
```

### Components

#### 1. TextRecognitionService
- **File**: `Services/TextRecognitionService.swift`
- **Framework**: Vision (built-in iOS)
- **Function**: Extract text from UIImage
- **Privacy**: All processing happens on-device

**Key Features**:
- High accuracy OCR
- Supports multiple languages
- No network required
- No external API costs

#### 2. AIService
- **File**: `Services/AIService.swift`
- **Protocol**: `AIServiceProtocol`
- **Implementations**:
  - `OpenAIFlashcardService`: Production AI generation
  - `MockAIFlashcardService`: Demo mode without API key

**AI Prompt Engineering**:
The service uses a carefully crafted prompt to ensure high-quality flashcards:
- Clear, concise questions
- Complete, accurate answers
- Focus on key concepts
- Appropriate difficulty level
- JSON format for parsing

#### 3. CardGeneratorViewModel
- **File**: `ViewModels/CardGeneratorViewModel.swift`
- **Pattern**: MVVM
- **Responsibilities**:
  - Orchestrate the generation flow
  - Handle errors gracefully
  - Manage editing state
  - Batch save to Core Data

#### 4. CardGeneratorView
- **File**: `Views/CardGeneratorView.swift`
- **Type**: SwiftUI View
- **Flow**:
  1. Image selection (camera/library)
  2. Processing indicator
  3. Card review list
  4. Bulk selection/editing
  5. Save confirmation

## Setup Guide

### Option 1: Using OpenAI API (Production)

#### Step 1: Get API Key

1. Go to [OpenAI Platform](https://platform.openai.com/)
2. Create an account or sign in
3. Navigate to API Keys section
4. Create a new secret key
5. **Important**: Copy and save it immediately (won't be shown again)

#### Step 2: Configure in App

1. Open FlashcardMVP app
2. Go to **Settings** (gear icon)
3. Scroll to **AI Configuration** section
4. Paste your API key
5. The key is stored securely in UserDefaults

#### Step 3: Cost Considerations

**GPT-3.5-Turbo** (Default):
- ~$0.001 per 1K tokens
- Typical photo: ~$0.01-0.05 per generation
- Fast and cost-effective

**GPT-4** (Premium):
- ~$0.03 per 1K tokens
- Typical photo: ~$0.30-1.00 per generation
- Higher quality, better reasoning

To switch models, edit `AIService.swift`:
```swift
private let model = "gpt-4" // Change from "gpt-3.5-turbo"
```

### Option 2: Demo Mode (Free)

If no API key is configured, the app automatically uses Mock Mode:

- **No API required**
- **Free to use**
- **Instant results**
- Generates placeholder cards based on text length
- Perfect for testing the UI flow

To explicitly use demo mode:
```swift
let mockService = MockAIFlashcardService()
```

## Usage Instructions

### From Deck Detail Screen

1. **Open a deck**
2. **Tap the "+" button** in top right
3. **Select "Generate from Photo"**

### Select Image Source

**Option A: Take Photo** (requires camera permission)
- Point camera at study material
- Ensure good lighting and focus
- Tap to capture

**Option B: Choose from Library**
- Select existing photo
- Works with screenshots, scanned documents, etc.

### Tips for Best Results

#### Photography Guidelines

✅ **Good Photos**:
- Well-lit, even lighting
- High contrast text
- Flat, straight angle
- Clear focus
- Minimal glare or shadows

❌ **Avoid**:
- Blurry images
- Low lighting
- Extreme angles
- Handwritten notes (limited OCR support)
- Colored/patterned backgrounds

#### Text Content Tips

**Best Content Types**:
- Textbook definitions
- Vocabulary lists
- Lecture slide bullet points
- Q&A sections
- Terminology glossaries
- Formula explanations

**Optimal Length**:
- 50-500 words per photo
- Multiple smaller photos > one large photo
- Clear section breaks help

### Review Generated Cards

After processing (10-30 seconds):

1. **Review the list** of generated cards
2. **Select/deselect** cards to save (checkboxes)
3. **Edit any card** (tap menu ••• → Edit)
4. **Delete unwanted** cards (tap menu ••• → Delete)
5. **Tap "Save Selected"** when satisfied

## Error Handling

### Common Errors

#### "No text found in the image"
**Cause**: OCR couldn't detect readable text
**Solution**:
- Retake with better lighting
- Ensure text is in focus
- Try zooming in on specific sections

#### "Rate limit exceeded"
**Cause**: Too many API requests in short time
**Solution**:
- Wait 60 seconds
- Reduce request frequency
- Check OpenAI account limits

#### "Invalid API key"
**Cause**: Incorrect or expired key
**Solution**:
- Verify key in Settings
- Generate new key from OpenAI dashboard
- Check for typos (no extra spaces)

#### "Network error"
**Cause**: No internet connection
**Solution**:
- Check WiFi/cellular connection
- Try again in a few moments
- Use demo mode offline

## Privacy & Security

### On-Device Processing
- **OCR**: 100% on-device via Vision framework
- **No text sent** until you choose to generate cards
- **Image never uploaded** to servers

### Data Transmission
When using OpenAI API:
- Only extracted **text** is sent (not the image)
- Transmitted over **HTTPS**
- **Not stored** by OpenAI (per API policy)
- **No personal information** included

### API Key Storage
- Stored in iOS **UserDefaults** (sandboxed)
- **Not synced** via iCloud
- **Device-local** only
- Can be deleted anytime

## Customization

### Using Different AI Providers

The app uses a protocol-based design, making it easy to swap AI providers:

#### Example: Using Claude API

```swift
class ClaudeFlashcardService: AIServiceProtocol {
    private let apiKey: String
    private let endpoint = "https://api.anthropic.com/v1/messages"
    private let model = "claude-3-sonnet-20240229"

    func generateFlashcards(from text: String) async throws -> [GeneratedCard] {
        // Implement Claude API call
        // Similar structure to OpenAIFlashcardService
    }
}
```

#### Example: Using Local LLM (Ollama)

```swift
class LocalLLMFlashcardService: AIServiceProtocol {
    private let endpoint = "http://localhost:11434/api/generate"
    private let model = "llama2"

    func generateFlashcards(from text: String) async throws -> [GeneratedCard] {
        // Implement local LLM call
    }
}
```

Then update `AIServiceConfiguration`:
```swift
func createService() -> AIServiceProtocol {
    return ClaudeFlashcardService(apiKey: apiKey)
    // or return LocalLLMFlashcardService()
}
```

### Customizing Generation Prompt

Edit the prompt in `AIService.swift` to change behavior:

```swift
let prompt = """
You are an expert educational assistant for [SUBJECT].

Create flashcards that:
- Target [DIFFICULTY LEVEL] students
- Focus on [SPECIFIC TOPICS]
- Use [FORMATTING STYLE]
- Generate exactly [NUMBER] cards

Text to analyze:
\(text)
"""
```

### Adjusting Card Count

By default, AI generates 5-15 cards. To change:

```swift
// In the prompt
- Generate 5-15 cards depending on content length

// Change to:
- Generate exactly 10 cards
// or
- Generate as many cards as needed (no limit)
```

## Performance Optimization

### Speed Improvements

**OCR Phase** (~2-5 seconds):
- Happens on-device
- Uses hardware acceleration
- Already optimized by Apple

**AI Generation** (~5-20 seconds):
- Depends on API response time
- GPT-3.5: faster (~5-10s)
- GPT-4: slower but better (~15-30s)

### Caching Strategy

Currently not implemented, but you could add:

```swift
class CachedAIService: AIServiceProtocol {
    private var cache: [String: [GeneratedCard]] = [:]

    func generateFlashcards(from text: String) async throws -> [GeneratedCard] {
        let hash = text.sha256() // Hash the text

        if let cached = cache[hash] {
            return cached // Return cached result
        }

        let cards = try await realService.generateFlashcards(from: text)
        cache[hash] = cards
        return cards
    }
}
```

## Accessibility

### VoiceOver Support
- All buttons have labels
- Progress updates announced
- Card content readable

### Dynamic Type
- All text scales with user preferences
- Maintains readability at large sizes

### Keyboard Navigation
- Tab through selections
- Space to toggle checkboxes
- Enter to save

## Testing

### Unit Tests

Currently implemented:
- Text recognition service (mock)
- AI service protocol conformance

Recommended additions:
```swift
func testTextRecognitionSuccess() async throws {
    let image = UIImage(named: "test_textbook_page")!
    let text = try await TextRecognitionService.recognizeText(from: image)
    XCTAssertFalse(text.isEmpty)
}

func testMockAIServiceGeneratesCards() async throws {
    let service = MockAIFlashcardService()
    let cards = try await service.generateFlashcards(from: "Sample text")
    XCTAssertGreaterThan(cards.count, 0)
}
```

### UI Tests

Recommended scenarios:
1. Full flow: camera → OCR → generation → save
2. Edit generated card
3. Partial selection save
4. Error handling (no text found)
5. Cancel at each stage

## Troubleshooting

### Vision Framework Issues

**Problem**: OCR fails on device
**Solution**: Requires iOS 13+, check deployment target

**Problem**: Poor accuracy
**Solution**: Use `.accurate` recognition level (default)

### OpenAI API Issues

**Problem**: 401 Unauthorized
**Solution**: Check API key is valid and has credits

**Problem**: 429 Rate Limit
**Solution**: Implement exponential backoff:
```swift
var retryCount = 0
while retryCount < 3 {
    do {
        return try await makeRequest()
    } catch AIServiceError.rateLimitExceeded {
        try await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(retryCount)) * 1_000_000_000))
        retryCount += 1
    }
}
```

**Problem**: Malformed JSON response
**Solution**: The prompt includes strict JSON formatting instructions. If issues persist:
- Add JSON validation before parsing
- Log raw response for debugging
- Fallback to regex extraction

## Future Enhancements

### Planned Features
- [ ] Batch photo processing (multiple photos at once)
- [ ] OCR language selection
- [ ] Custom AI prompt templates
- [ ] Save failed extractions for debugging
- [ ] Card quality scoring
- [ ] Image cropping before OCR
- [ ] Support for handwritten notes (advanced OCR)

### Advanced Ideas
- [ ] On-device ML model (Core ML)
- [ ] Collaborative generation (share extracts)
- [ ] Integration with document scanner
- [ ] Auto-tag cards by subject
- [ ] Suggested improvements to existing cards

## FAQ

**Q: Does this work offline?**
A: OCR works offline, but AI generation requires internet (unless using local LLM).

**Q: What languages are supported?**
A: Vision framework supports 30+ languages. OpenAI GPT supports 50+ languages.

**Q: Can I use my own AI model?**
A: Yes! Implement the `AIServiceProtocol` and plug it in.

**Q: Is my data private?**
A: OCR is 100% on-device. AI generation sends only text (not images) to OpenAI.

**Q: How accurate is the OCR?**
A: Very accurate for printed text (95%+). Handwriting support is limited.

**Q: Can I generate cards from PDFs?**
A: Not directly, but take screenshots of PDF pages and process those.

**Q: What's the cost per photo?**
A: With GPT-3.5-Turbo: typically $0.01-0.05 per photo.

---

**This feature transforms studying by automating the tedious process of creating flashcards, letting you focus on learning!**
