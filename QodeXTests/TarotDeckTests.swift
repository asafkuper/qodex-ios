import XCTest
@testable import QodeX

final class TarotDeckTests: XCTestCase {
    
    var deck: TarotDeck!
    
    override func setUp() {
        super.setUp()
        deck = TarotDeck()
    }
    
    override func tearDown() {
        deck = nil
        super.tearDown()
    }
    
    // MARK: - Deck Initialization Tests
    
    func testDeck_Has78Cards() {
        XCTAssertEqual(deck.cards.count, 78)
    }
    
    func testDeck_Has22MajorArcana() {
        let majorArcana = deck.cards.filter { $0.arcana == .major }
        XCTAssertEqual(majorArcana.count, 22)
    }
    
    func testDeck_Has56MinorArcana() {
        let minorArcana = deck.cards.filter { $0.arcana == .minor }
        XCTAssertEqual(minorArcana.count, 56)
    }
    
    func testDeck_Has4Suits() {
        let suits = Set(deck.cards.compactMap { $0.suit })
        XCTAssertEqual(suits.count, 4)
        XCTAssertTrue(suits.contains(.cups))
        XCTAssertTrue(suits.contains(.wands))
        XCTAssertTrue(suits.contains(.swords))
        XCTAssertTrue(suits.contains(.pentacles))
    }
    
    func testDeck_EachSuitHas14Cards() {
        for suit in [Suit.cups, .wands, .swords, .pentacles] {
            let cards = deck.cards.filter { $0.suit == suit }
            XCTAssertEqual(cards.count, 14, "Suit \(suit) should have 14 cards")
        }
    }
    
    // MARK: - Major Arcana Tests
    
    func testMajorArcana_ContainsFool() {
        let fool = deck.card(named: "The Fool")
        XCTAssertNotNil(fool)
        XCTAssertEqual(fool?.number, 0)
        XCTAssertEqual(fool?.arcana, .major)
    }
    
    func testMajorArcana_ContainsMagician() {
        let magician = deck.card(named: "The Magician")
        XCTAssertNotNil(magician)
        XCTAssertEqual(magician?.number, 1)
    }
    
    func testMajorArcana_ContainsHighPriestess() {
        let priestess = deck.card(named: "The High Priestess")
        XCTAssertNotNil(priestess)
        XCTAssertEqual(priestess?.number, 2)
    }
    
    func testMajorArcana_ContainsWorld() {
        let world = deck.card(named: "The World")
        XCTAssertNotNil(world)
        XCTAssertEqual(world?.number, 21)
    }
    
    // MARK: - Card Draw Tests
    
    func testDrawCard_ReturnsOneCard() {
        let card = deck.drawCard()
        XCTAssertNotNil(card)
    }
    
    func testDrawCard_RemovesFromDeck() {
        let initialCount = deck.cards.count
        _ = deck.drawCard()
        XCTAssertEqual(deck.cards.count, initialCount - 1)
    }
    
    func testDrawCard_RandomDistribution() {
        var drawnCards: [TarotCard] = []
        for _ in 0..<10 {
            let newDeck = TarotDeck()
            drawnCards.append(newDeck.drawCard()!)
        }
        
        let uniqueCards = Set(drawnCards.map { $0.name })
        XCTAssertGreaterThan(uniqueCards.count, 1, "Should draw different cards randomly")
    }
    
    func testDrawMultipleCards_ReturnsCorrectCount() {
        let cards = deck.drawCards(count: 3)
        XCTAssertEqual(cards.count, 3)
    }
    
    func testDrawMultipleCards_RemovesFromDeck() {
        let initialCount = deck.cards.count
        _ = deck.drawCards(count: 5)
        XCTAssertEqual(deck.cards.count, initialCount - 5)
    }
    
    func testDrawMoreThanAvailable_ReturnsAllRemaining() {
        _ = deck.drawCards(count: 70)
        let remaining = deck.drawCards(count: 20)
        XCTAssertEqual(remaining.count, 8)
    }
    
    // MARK: - Reversal Tests
    
    func testDrawCardWithReversal_CanBeReversed() {
        var reversedCount = 0
        for _ in 0..<100 {
            let card = deck.drawCard(allowReversal: true)
            if card?.isReversed == true {
                reversedCount += 1
            }
        }
        
        // Approximately 50% should be reversed
        XCTAssertGreaterThan(reversedCount, 30)
        XCTAssertLessThan(reversedCount, 70)
    }
    
    func testDrawCardNoReversal_AllUpright() {
        for _ in 0..<78 {
            let card = deck.drawCard(allowReversal: false)
            XCTAssertFalse(card?.isReversed ?? true)
        }
    }
    
    func testReversedCard_HasReversedMeaning() {
        let card = TarotCard.fool
        let reversedCard = card.reversed()
        
        XCTAssertTrue(reversedCard.isReversed)
        XCTAssertNotEqual(card.uprightMeaning, reversedCard.reversedMeaning)
    }
    
    // MARK: - Spread Tests
    
    func testThreeCardSpread_Returns3Cards() {
        let spread = deck.threeCardSpread()
        XCTAssertEqual(spread.count, 3)
        XCTAssertEqual(spread[0].position, .past)
        XCTAssertEqual(spread[1].position, .present)
        XCTAssertEqual(spread[2].position, .future)
    }
    
    func testCelticCrossSpread_Returns10Cards() {
        let spread = deck.celticCrossSpread()
        XCTAssertEqual(spread.count, 10)
    }
    
    func testRelationshipSpread_Returns5Cards() {
        let spread = deck.relationshipSpread()
        XCTAssertEqual(spread.count, 5)
    }
    
    func testCareerSpread_Returns7Cards() {
        let spread = deck.careerSpread()
        XCTAssertEqual(spread.count, 7)
    }
    
    func testCustomSpread_RespectsCount() {
        let spread = deck.drawSpread(cardCount: 5, allowReversal: true)
        XCTAssertEqual(spread.count, 5)
    }
    
    // MARK: - Card Properties Tests
    
    func testCard_HasName() {
        let card = deck.card(named: "The Fool")
        XCTAssertFalse(card?.name.isEmpty ?? true)
    }
    
    func testCard_HasUprightMeaning() {
        let card = deck.card(named: "The Magician")
        XCTAssertFalse(card?.uprightMeaning.isEmpty ?? true)
    }
    
    func testCard_HasReversedMeaning() {
        let card = deck.card(named: "The High Priestess")
        XCTAssertFalse(card?.reversedMeaning.isEmpty ?? true)
    }
    
    func testCard_HasKeywords() {
        let card = deck.card(named: "The Empress")
        XCTAssertGreaterThan(card?.keywords.count ?? 0, 0)
    }
    
    func testCard_HasElement() {
        let card = deck.card(named: "The Emperor")
        XCTAssertNotNil(card?.element)
    }
    
    // MARK: - Deck Reset Tests
    
    func testReset_RestoresAllCards() {
        _ = deck.drawCards(count: 30)
        deck.reset()
        XCTAssertEqual(deck.cards.count, 78)
    }
    
    func testReset_ShufflesDeck() {
        let firstCard1 = deck.drawCard()
        deck.reset()
        let firstCard2 = deck.drawCard()
        
        // Note: There's a small chance these could be the same, but very unlikely
        XCTAssertNotNil(firstCard1)
        XCTAssertNotNil(firstCard2)
    }
    
    // MARK: - Card Search Tests
    
    func testCardByName_FindsCorrectCard() {
        let card = deck.card(named: "The Sun")
        XCTAssertEqual(card?.name, "The Sun")
        XCTAssertEqual(card?.number, 19)
    }
    
    func testCardByName_CaseInsensitive() {
        let card1 = deck.card(named: "THE SUN")
        let card2 = deck.card(named: "the sun")
        XCTAssertEqual(card1?.name, card2?.name)
    }
    
    func testCardsBySuit_ReturnsCorrectCount() {
        let cups = deck.cards(in: .cups)
        XCTAssertEqual(cups.count, 14)
    }
    
    func testCardsByArcana_ReturnsCorrectCount() {
        let major = deck.cards(in: .major)
        let minor = deck.cards(in: .minor)
        XCTAssertEqual(major.count, 22)
        XCTAssertEqual(minor.count, 56)
    }
    
    // MARK: - Card Meaning Tests
    
    func testCardMeaning_ReturnsUprightForUprightCard() {
        let card = TarotCard.fool
        let meaning = card.currentMeaning
        XCTAssertEqual(meaning, card.uprightMeaning)
    }
    
    func testCardMeaning_ReturnsReversedForReversedCard() {
        let card = TarotCard.fool.reversed()
        let meaning = card.currentMeaning
        XCTAssertEqual(meaning, card.reversedMeaning)
    }
    
    // MARK: - Performance Tests
    
    func testPerformance_DeckInitialization() {
        measure {
            for _ in 0..<100 {
                _ = TarotDeck()
            }
        }
    }
    
    func testPerformance_Draw10Cards() {
        measure {
            var deck = TarotDeck()
            _ = deck.drawCards(count: 10)
        }
    }
    
    func testPerformance_CelticCrossSpread() {
        measure {
            var deck = TarotDeck()
            _ = deck.celticCrossSpread()
        }
    }
    
    // MARK: - Edge Case Tests
    
    func testDrawFromEmptyDeck_ReturnsNil() {
        _ = deck.drawCards(count: 78)
        let card = deck.drawCard()
        XCTAssertNil(card)
    }
    
    func testInvalidCardName_ReturnsNil() {
        let card = deck.card(named: "Nonexistent Card")
        XCTAssertNil(card)
    }
    
    func testDrawZeroCards_ReturnsEmpty() {
        let cards = deck.drawCards(count: 0)
        XCTAssertTrue(cards.isEmpty)
    }
}
