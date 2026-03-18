# QodeX Tarot Minor Arcana Expansion

## Overview
This expansion adds comprehensive meanings for all 56 Minor Arcana cards to the QodeX iOS app, complementing the existing Major Arcana (22 cards) for a complete 78-card tarot system.

## Files Created/Modified

### 1. TarotMinorArcana.json
**Location:** `QodeX/Features/Esoteric/Tarot/TarotMinorArcana.json`

Contains detailed data for all 56 Minor Arcana cards including:
- **Suit Information:**
  - Wands (Fire) - Creativity, Passion, Action
  - Cups (Water) - Emotions, Relationships, Intuition
  - Swords (Air) - Thoughts, Conflicts, Clarity
  - Pentacles (Earth) - Material, Work, Physical

- **For Each Card:**
  - Card name and number (Ace through King)
  - Keywords (upright and reversed)
  - Detailed meanings (upright and reversed)
  - Numerology connection
  - Astrology association
  - Kabbalah path and Sephirah
  - Daily affirmation
  - Career guidance
  - Relationship guidance
  - Spiritual guidance

### 2. TarotMinorArcanaIntegration.swift
**Location:** `QodeX/Features/Esoteric/Tarot/TarotMinorArcanaIntegration.swift`

Swift code providing:
- Data models for parsing JSON
- MinorArcanaManager singleton for loading and accessing data
- EnhancedCardDetailView for displaying comprehensive card information
- MinorArcanaExplorerView for browsing all 56 cards
- UI components for:
  - Card display with esoteric details
  - Numerology section
  - Astrology section
  - Kabbalah section
  - Guidance sections (Career, Relationships, Spirituality)
  - Affirmation display

### 3. TarotView.swift (Updated)
**Location:** `QodeX/Features/Tarot/TarotView.swift`

Modifications:
- Updated CardLibraryView to include "Explore Minor Arcana" button
- Integrated EnhancedCardDetailView for Minor Arcana cards
- Added tap-to-view details in DailyCardView
- Enhanced spread reading card details

## Card Structure

### Wands (Fire) 🔥
| Number | Card | Element | Astrology |
|--------|------|---------|-----------|
| 1 | Ace of Wands | Fire | All Fire Signs |
| 2 | Two of Wands | Fire | Mars in Aries |
| 3 | Three of Wands | Fire | Sun in Aries |
| 4 | Four of Wands | Fire | Venus in Aries |
| 5 | Five of Wands | Fire | Saturn in Leo |
| 6 | Six of Wands | Fire | Jupiter in Leo |
| 7 | Seven of Wands | Fire | Mars in Leo |
| 8 | Eight of Swords | Air | Mercury in Sagittarius |
| 9 | Nine of Wands | Fire | Moon in Sagittarius |
| 10 | Ten of Wands | Fire | Saturn in Sagittarius |
| 11 | Page of Wands | Fire | All Fire Signs |
| 12 | Knight of Wands | Fire | Scorpio |
| 13 | Queen of Wands | Fire | Aries |
| 14 | King of Wands | Fire | Leo |

### Cups (Water) 🌊
| Number | Card | Element | Astrology |
|--------|------|---------|-----------|
| 1 | Ace of Cups | Water | All Water Signs |
| 2 | Two of Cups | Water | Venus in Cancer |
| 3 | Three of Cups | Water | Mercury in Cancer |
| 4 | Four of Cups | Water | Moon in Cancer |
| 5 | Five of Cups | Water | Mars in Scorpio |
| 6 | Six of Cups | Water | Sun in Scorpio |
| 7 | Seven of Cups | Water | Venus in Scorpio |
| 8 | Eight of Cups | Water | Saturn in Pisces |
| 9 | Nine of Cups | Water | Jupiter in Pisces |
| 10 | Ten of Cups | Water | Mars in Pisces |
| 11 | Page of Cups | Water | All Water Signs |
| 12 | Knight of Cups | Water | Aquarius |
| 13 | Queen of Cups | Water | Gemini |
| 14 | King of Cups | Water | Pisces |

### Swords (Air) 💨
| Number | Card | Element | Astrology |
|--------|------|---------|-----------|
| 1 | Ace of Swords | Air | All Air Signs |
| 2 | Two of Swords | Air | Moon in Libra |
| 3 | Three of Swords | Air | Saturn in Libra |
| 4 | Four of Swords | Air | Jupiter in Libra |
| 5 | Five of Swords | Air | Venus in Aquarius |
| 6 | Six of Swords | Air | Mercury in Aquarius |
| 7 | Seven of Swords | Air | Moon in Aquarius |
| 8 | Eight of Swords | Air | Jupiter in Gemini |
| 9 | Nine of Swords | Air | Mars in Gemini |
| 10 | Ten of Swords | Air | Sun in Gemini |
| 11 | Page of Swords | Air | All Air Signs |
| 12 | Knight of Swords | Air | Taurus |
| 13 | Queen of Swords | Air | Virgo |
| 14 | King of Swords | Air | Libra |

### Pentacles (Earth) 🌍
| Number | Card | Element | Astrology |
|--------|------|---------|-----------|
| 1 | Ace of Pentacles | Earth | All Earth Signs |
| 2 | Two of Pentacles | Earth | Jupiter in Capricorn |
| 3 | Three of Pentacles | Earth | Mars in Capricorn |
| 4 | Four of Pentacles | Earth | Sun in Capricorn |
| 5 | Five of Pentacles | Earth | Mercury in Taurus |
| 6 | Six of Pentacles | Earth | Moon in Taurus |
| 7 | Seven of Pentacles | Earth | Saturn in Taurus |
| 8 | Eight of Pentacles | Earth | Sun in Virgo |
| 9 | Nine of Pentacles | Earth | Venus in Virgo |
| 10 | Ten of Pentacles | Earth | Mercury in Virgo |
| 11 | Page of Pentacles | Earth | All Earth Signs |
| 12 | Knight of Pentacles | Earth | Leo |
| 13 | Queen of Pentacles | Earth | Sagittarius |
| 14 | King of Pentacles | Earth | Virgo |

## Kabbalah Correspondences

Each Minor Arcana card corresponds to:
- A Sephirah on the Tree of Life
- A path between Sephiroth
- An elemental combination (for court cards)

Example: Ace of Wands
- Sephirah: Kether (Crown)
- Path: 11 - The path of the Primum Mobile
- Meaning: The pure, undifferentiated divine will manifesting as creative impulse

## Usage Instructions

### For Users
1. Navigate to the "Library" tab in the Tarot section
2. Tap "Explore Minor Arcana" to browse all 56 cards
3. Select a suit (Wands, Cups, Swords, Pentacles)
4. Tap any card to view detailed meanings
5. During readings, tap Minor Arcana cards for enhanced details

### For Developers

#### Loading Minor Arcana Data
```swift
let manager = MinorArcanaManager.shared
let enhancedCard = manager.getEnhancedCard(tarotCard)
```

#### Accessing Card Details
```swift
// Keywords
let keywords = enhancedCard.enhancedKeywords

// Meanings
let meaning = enhancedCard.enhancedMeaning

// Esoteric info
let numerology = enhancedCard.numerologyInfo
let astrology = enhancedCard.astrologyInfo
let kabbalah = enhancedCard.kabbalahInfo

// Guidance
let career = enhancedCard.careerGuidance
let relationships = enhancedCard.relationshipGuidance
let spirituality = enhancedCard.spiritualGuidance

// Affirmation
let affirmation = enhancedCard.affirmation
```

#### Displaying Enhanced Card Detail
```swift
// For Minor Arcana cards
EnhancedCardDetailView(card: minorArcanaCard)

// For Major Arcana cards (original view)
CardDetailView(card: majorArcanaCard)
```

## Integration Notes

1. **Backward Compatibility:** Major Arcana cards continue to use the original CardDetailView
2. **Progressive Enhancement:** If JSON fails to load, the system falls back to basic card data
3. **Memory Efficiency:** JSON data is loaded once and shared via singleton pattern
4. **Type Safety:** Strong typing with Codable ensures data integrity

## Future Enhancements

Potential additions for future versions:
- [ ] Rider-Waite-Smith card imagery descriptions
- [ ] Reversed card reversal techniques
- [ ] Card combinations and pairings
- [ ] Elemental dignities
- [ ] Card spreads specific to Minor Arcana
- [ ] Tarot journal integration with Minor Arcana insights
- [ ] Audio readings for each card
- [ ] Daily Minor Arcana card push notifications

## Credits

Created for QodeX iOS app - A comprehensive esoteric insights platform combining Tarot, Numerology, and Astrology.

## License

Copyright © 2025 QodeX. All rights reserved.
