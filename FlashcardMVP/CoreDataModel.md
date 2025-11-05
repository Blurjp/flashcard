# Core Data Model Definition

This document describes the Core Data model for FlashcardMVP. You'll need to create this model in Xcode.

## How to Create the Model in Xcode

1. In Xcode, select `FlashcardMVP` group in the project navigator
2. Go to **File → New → File...**
3. Select **Data Model** under Core Data section
4. Name it: `FlashcardMVP.xcdatamodeld`
5. Save it in the `FlashcardMVP/Persistence/` directory

## Entities and Attributes

### Entity: Deck

**Attributes:**
- `id`: UUID, not optional
- `name`: String, not optional
- `createdAt`: Date, not optional
- `updatedAt`: Date, not optional

**Relationships:**
- `cards`: To-Many relationship to `Card`, inverse: `deck`, Delete Rule: **Cascade**

**Class:** Set to `Deck` (under Data Model Inspector)
**Codegen:** Select "Manual/None"

---

### Entity: Card

**Attributes:**
- `id`: UUID, not optional
- `front`: String, not optional
- `back`: String, not optional
- `imageData`: Binary Data, optional
- `repetition`: Integer 16, not optional, default: 0
- `intervalDays`: Integer 16, not optional, default: 1
- `easeFactor`: Double, not optional, default: 2.5
- `dueDate`: Date, not optional
- `createdAt`: Date, not optional
- `updatedAt`: Date, not optional

**Relationships:**
- `deck`: To-One relationship to `Deck`, inverse: `cards`, Delete Rule: **Nullify**
- `reviewLogs`: To-Many relationship to `ReviewLog`, inverse: `card`, Delete Rule: **Cascade**

**Class:** Set to `Card` (under Data Model Inspector)
**Codegen:** Select "Manual/None"

---

### Entity: ReviewLog

**Attributes:**
- `id`: UUID, not optional
- `rating`: Integer 16, not optional
- `timestamp`: Date, not optional

**Relationships:**
- `card`: To-One relationship to `Card`, inverse: `reviewLogs`, Delete Rule: **Nullify**

**Class:** Set to `ReviewLog` (under Data Model Inspector)
**Codegen:** Select "Manual/None"

---

## Fetch Request Configuration (Optional but Recommended)

You can add fetch request templates in the model editor for common queries:

1. **AllDecks**
   - Entity: Deck
   - Sort: updatedAt, descending

2. **DueCards**
   - Entity: Card
   - Predicate: `dueDate <= $NOW`
   - Sort: dueDate, ascending

---

## Step-by-Step Creation in Xcode

### Creating Deck Entity:

1. Click "Add Entity" button at the bottom of the editor
2. Name it "Deck"
3. In Attributes section, click "+" to add each attribute:
   - Click on attribute, set name, type, and optional/not optional
4. In Relationships section, click "+" to add `cards` relationship:
   - Name: cards
   - Destination: Card (you'll set this after creating Card entity)
   - Type: To Many
   - Delete Rule: Cascade
5. In Data Model Inspector (right panel):
   - Set Class to "Deck"
   - Set Codegen to "Manual/None"

### Creating Card Entity:

Follow similar steps as Deck, with all attributes and relationships as specified above.

### Creating ReviewLog Entity:

Follow similar steps, with all attributes and relationships as specified above.

### Setting Up Inverse Relationships:

After creating all entities:
1. Select Deck entity → cards relationship
2. Set inverse to: Card.deck

3. Select Card entity → deck relationship
4. Set inverse to: Deck.cards

5. Select Card entity → reviewLogs relationship
6. Set inverse to: ReviewLog.card

7. Select ReviewLog entity → card relationship
8. Set inverse to: Card.reviewLogs

---

## Important Notes

1. **NSPersistentCloudKitContainer Compatibility:**
   - All entity names should be simple (no special characters)
   - All attributes should have default values where possible
   - UUID types are required for CloudKit sync

2. **Delete Rules:**
   - Deck → Cards: **Cascade** (deleting a deck deletes all its cards)
   - Card → ReviewLogs: **Cascade** (deleting a card deletes its review logs)
   - Card → Deck: **Nullify** (deleting a card doesn't delete the deck)
   - ReviewLog → Card: **Nullify** (deleting a log doesn't delete the card)

3. **Codegen:**
   - Must be set to "Manual/None" for all entities because we've created custom NSManagedObject subclasses

4. **Migration:**
   - The current setup uses automatic lightweight migration
   - If you need to add attributes later, make them optional or provide default values

---

## Verification Checklist

After creating the model, verify:

- ✓ All three entities (Deck, Card, ReviewLog) are created
- ✓ All attributes have correct types and optional settings
- ✓ All relationships have inverse relationships set
- ✓ Delete rules are set correctly
- ✓ Codegen is set to "Manual/None" for all entities
- ✓ Class names are set correctly for all entities
- ✓ The file is saved in FlashcardMVP/Persistence/ directory

---

## Alternative: Import from Model Definition

If you prefer, you can also create the model using Xcode's import functionality or by manually editing the XML structure of the .xcdatamodeld file. However, using the Xcode GUI is the recommended approach for beginners.
