import SwiftUI
import Combine

// MARK: - Data Models

/// Represents one of the 10 Sephirot (divine emanations) on the Tree of Life
struct Sephira: Identifiable, Hashable {
    let id = UUID()
    let number: Int
    let name: String
    let hebrewName: String
    let hebrewLetters: String
    let meaning: String
    let divineName: String
    let archangel: String
    let angelicOrder: String
    let virtue: String
    let vice: String
    let colorKingScale: Color
    let colorQueenScale: Color
    let planet: String?
    let zodiac: String?
    let element: String?
    let position: CGPoint // Position on the Tree diagram
    let description: String
    let meditation: String
    let keywords: [String]
}

/// Hebrew letter with mystical properties
struct HebrewLetter: Identifiable, Hashable {
    let id = UUID()
    let letter: String
    let name: String
    let value: Int // Gematria value
    let meaning: String
    let pathNumber: Int
    let connects: (Int, Int)? // Connects which Sephirot (1-10)
    let element: String?
    let planet: String?
    let zodiac: String?
    let tarot: String
    let color: Color
}

/// Astrological correspondence
struct AstrologyCorrespondence: Identifiable {
    let id = UUID()
    let symbol: String
    let name: String
    let rulingSephira: Int
    let hebrewLetter: String
    let description: String
}

/// Study lesson
struct KabbalahLesson: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let content: String
    let sephiraFocus: Int?
    let difficulty: LessonDifficulty
    let estimatedMinutes: Int
    let isCompleted: Bool
}

enum LessonDifficulty: String, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    
    var color: Color {
        switch self {
        case .beginner: return .green
        case .intermediate: return .orange
        case .advanced: return .red
        }
    }
}

// MARK: - Data Store

class KabbalahDataStore: ObservableObject {
    static let shared = KabbalahDataStore()
    
    @Published var dailySephira: Sephira
    @Published var completedLessons: Set<UUID> = []
    
    let sephirot: [Sephira]
    let hebrewLetters: [HebrewLetter]
    let lessons: [KabbalahLesson]
    let astrology: [AstrologyCorrespondence]
    
    private init() {
        // Initialize Sephirot with positions on Tree of Life
        self.sephirot = [
            Sephira(
                number: 1,
                name: "Kether",
                hebrewName: "כתר",
                hebrewLetters: "כתר",
                meaning: "Crown",
                divineName: "Eheieh",
                archangel: "Metatron",
                angelicOrder: "Holy Living Creatures",
                virtue: "Attainment",
                vice: "None",
                colorKingScale: .white,
                colorQueenScale: .white,
                planet: nil,
                zodiac: nil,
                element: nil,
                position: CGPoint(x: 0.5, y: 0.05),
                description: "The first emanation, the Crown of creation. Kether represents pure existence, the point beyond which no human thought can penetrate. It is the divine will, the source of all blessing, the primal impulse of creation.",
                meditation: "Visualize a brilliant white light above your head, a crown of pure divine consciousness. Breathe in this light and feel it connecting you to the infinite source of all being.",
                keywords: ["Unity", "Pure Being", "Divine Will", "Infinite Light"]
            ),
            Sephira(
                number: 2,
                name: "Chokmah",
                hebrewName: "חכמה",
                hebrewLetters: "חכמה",
                meaning: "Wisdom",
                divineName: "Yah",
                archangel: "Ratziel",
                angelicOrder: "Auphanim",
                virtue: "Devotion",
                vice: "None",
                colorKingScale: Color(hex: "E5C158"), // Gold
                colorQueenScale: .gray,
                planet: nil,
                zodiac: nil,
                element: nil,
                position: CGPoint(x: 0.75, y: 0.15),
                description: "The second emanation, Wisdom. Chokmah is the primal masculine force, the active principle of creation. It contains all potential, all possibility, the flash of inspiration before form.",
                meditation: "See a golden sphere of light to your right. Feel the masculine, active energy of creation flowing through you. Embrace the flash of insight and intuitive knowing.",
                keywords: ["Wisdom", "Masculine", "Active", "Potential"]
            ),
            Sephira(
                number: 11,
                name: "Da'at",
                hebrewName: "דעת",
                hebrewLetters: "דעת",
                meaning: "Knowledge",
                divineName: "YHVH Elohim",
                archangel: "Uriel",
                angelicOrder: "Cherubim",
                virtue: "Knowledge",
                vice: "Ignorance",
                colorKingScale: Color(hex: "9B7CB6"), // Lavender/Grey
                colorQueenScale: Color(hex: "6B5B95"),
                planet: nil,
                zodiac: nil,
                element: nil,
                position: CGPoint(x: 0.5, y: 0.18),
                description: "The hidden eleventh Sephira, Knowledge. Da'at represents the synthesis of Wisdom (Chokmah) and Understanding (Binah). It is the threshold of consciousness, the point where intellect meets intuition. Unlike other Sephirot, Da'at is not a vessel but an opening—a dynamic space where divine knowledge becomes accessible to human awareness. It represents the Abyss, the gap between the Supernal Triad and the lower Sephirot.",
                meditation: "Visualize a luminous grey-lavender sphere suspended in the void between above and below. This is the Abyss of Knowledge. Feel the meeting of Wisdom and Understanding within you. As you breathe, sense the doorway opening—direct knowing without thought, the flash of gnosis that transforms. Da'at is not learned; it is remembered.",
                keywords: ["Knowledge", "Consciousness", "Gnosis", "The Abyss", "Synthesis"]
            ),
            Sephira(
                number: 3,
                name: "Binah",
                hebrewName: "בינה",
                hebrewLetters: "בינה",
                meaning: "Understanding",
                divineName: "YHVH Elohim",
                archangel: "Tzaphkiel",
                angelicOrder: "Aralim",
                virtue: "Silence",
                vice: "Pride",
                colorKingScale: Color(hex: "1a1a2e"), // Dark blue-black
                colorQueenScale: Color(hex: "2d2d44"),
                planet: nil,
                zodiac: nil,
                element: nil,
                position: CGPoint(x: 0.25, y: 0.15),
                description: "The third emanation, Understanding. Binah is the primal feminine force, the receptive principle that gives form to the wisdom of Chokmah. It is the womb of creation, where possibilities become structured.",
                meditation: "Visualize a deep indigo-black sphere to your left. Feel the feminine, receptive energy that gives form to all things. Embrace silence and the depth of understanding.",
                keywords: ["Understanding", "Feminine", "Receptive", "Form"]
            ),
            Sephira(
                number: 4,
                name: "Chesed",
                hebrewName: "חסד",
                hebrewLetters: "חסד",
                meaning: "Mercy",
                divineName: "El",
                archangel: "Tzadkiel",
                angelicOrder: "Chasmalim",
                virtue: "Obedience",
                vice: "Bigotry",
                colorKingScale: Color(hex: "4169E1"), // Royal Blue
                colorQueenScale: Color(hex: "6495ED"),
                planet: "Jupiter",
                zodiac: nil,
                element: nil,
                position: CGPoint(x: 0.75, y: 0.35),
                description: "The fourth emanation, Mercy or Loving-kindness. Chesed represents the expansive, generous force of the divine. It is the love that builds, the grace that sustains, the foundation of all spiritual growth.",
                meditation: "See a brilliant blue sphere on your right side. Feel the expansive, loving energy of Jupiter filling you with generosity, kindness, and the desire to build and create.",
                keywords: ["Mercy", "Loving-kindness", "Expansion", "Grace"]
            ),
            Sephira(
                number: 5,
                name: "Geburah",
                hebrewName: "גבורה",
                hebrewLetters: "גבורה",
                meaning: "Severity",
                divineName: "Elohim Gibor",
                archangel: "Khamael",
                angelicOrder: "Seraphim",
                virtue: "Courage",
                vice: "Cruelty",
                colorKingScale: Color(hex: "DC143C"), // Crimson
                colorQueenScale: Color(hex: "B22222"),
                planet: "Mars",
                zodiac: nil,
                element: nil,
                position: CGPoint(x: 0.25, y: 0.35),
                description: "The fifth emanation, Severity or Strength. Geburah represents the restrictive, disciplining force necessary for balance. It is the warrior's courage, the strength to destroy what no longer serves, the fire that purifies.",
                meditation: "Visualize a fierce red sphere on your left. Feel the martial energy that gives you strength to face challenges, destroy obstacles, and stand firm in your truth.",
                keywords: ["Severity", "Strength", "Discipline", "Courage"]
            ),
            Sephira(
                number: 6,
                name: "Tiphareth",
                hebrewName: "תפארת",
                hebrewLetters: "תפארת",
                meaning: "Beauty",
                divineName: "YHVH Eloah Va-Daath",
                archangel: "Raphael",
                angelicOrder: "Malachim",
                virtue: "Devotion",
                vice: "Pride",
                colorKingScale: Color(hex: "E5C158"), // Gold/Rose
                colorQueenScale: Color(hex: "FFB6C1"),
                planet: "Sun",
                zodiac: nil,
                element: nil,
                position: CGPoint(x: 0.5, y: 0.45),
                description: "The sixth emanation, Beauty. Tiphareth is the heart of the Tree, where all forces find harmony and balance. It represents the Christ consciousness, the Buddha nature, the point of divine-human union. The Sun shines here.",
                meditation: "See a golden-rose sphere at your heart center. Feel the radiant sun energy bringing all aspects of yourself into perfect harmony. This is the center of your being.",
                keywords: ["Beauty", "Harmony", "Balance", "Christ Consciousness"]
            ),
            Sephira(
                number: 7,
                name: "Netzach",
                hebrewName: "נצח",
                hebrewLetters: "נצח",
                meaning: "Victory",
                divineName: "YHVH Tzabaoth",
                archangel: "Haniel",
                angelicOrder: "Elohim",
                virtue: "Unselfishness",
                vice: "Lust",
                colorKingScale: Color(hex: "228B22"), // Forest Green
                colorQueenScale: Color(hex: "90EE90"),
                planet: "Venus",
                zodiac: nil,
                element: nil,
                position: CGPoint(x: 0.75, y: 0.65),
                description: "The seventh emanation, Victory or Eternity. Netzach represents the emotional force of nature, the drive toward beauty, art, and love. It is the victory of persistence, the triumph of feeling over reason.",
                meditation: "Visualize an emerald green sphere at your right hip. Feel the Venusian energy of love, art, beauty, and the eternal nature of true feeling. Embrace the victory of the heart.",
                keywords: ["Victory", "Love", "Art", "Emotion"]
            ),
            Sephira(
                number: 8,
                name: "Hod",
                hebrewName: "הוד",
                hebrewLetters: "הוד",
                meaning: "Splendor",
                divineName: "Elohim Tzabaoth",
                archangel: "Michael",
                angelicOrder: "Beni Elohim",
                virtue: "Truth",
                vice: "Falsehood",
                colorKingScale: Color(hex: "FFA500"), // Orange
                colorQueenScale: Color(hex: "FFD700"),
                planet: "Mercury",
                zodiac: nil,
                element: nil,
                position: CGPoint(x: 0.25, y: 0.65),
                description: "The eighth emanation, Splendor. Hod represents the intellectual force, communication, and the rational mind. It is the sphere of magic, science, and all systems of knowledge. The splendor of the mind's creations.",
                meditation: "See an orange-gold sphere at your left hip. Feel the Mercurial energy of intellect, communication, and magical power. Your mind is a vessel of divine splendor.",
                keywords: ["Splendor", "Intellect", "Communication", "Magic"]
            ),
            Sephira(
                number: 9,
                name: "Yesod",
                hebrewName: "יסוד",
                hebrewLetters: "יסוד",
                meaning: "Foundation",
                divineName: "Shaddai El Chai",
                archangel: "Gabriel",
                angelicOrder: "Cherubim",
                virtue: "Independence",
                vice: "Idleness",
                colorKingScale: Color(hex: "800080"), // Purple
                colorQueenScale: Color(hex: "DA70D6"),
                planet: "Moon",
                zodiac: nil,
                element: nil,
                position: CGPoint(x: 0.5, y: 0.75),
                description: "The ninth emanation, Foundation. Yesod is the astral plane, the repository of all images and forms before they manifest. It is the storehouse of the unconscious, the foundation upon which the physical world is built.",
                meditation: "Visualize a purple sphere at your lower abdomen. Feel the lunar energy of dreams, intuition, and the astral realm. This is the foundation of your manifested reality.",
                keywords: ["Foundation", "Astral", "Dreams", "Subconscious"]
            ),
            Sephira(
                number: 10,
                name: "Malkuth",
                hebrewName: "מלכות",
                hebrewLetters: "מלכות",
                meaning: "Kingdom",
                divineName: "Adonai Ha-Aretz",
                archangel: "Sandalphon",
                angelicOrder: "Ashim",
                virtue: "Discrimination",
                vice: "Greed",
                colorKingScale: Color(hex: "8B4513"), // Saddle Brown
                colorQueenScale: Color(hex: "D2691E"),
                planet: nil,
                zodiac: nil,
                element: "Earth",
                position: CGPoint(x: 0.5, y: 0.92),
                description: "The tenth emanation, Kingdom. Malkuth represents the physical world, the completion of the Tree, the divine presence in matter. It is the Shekinah, the indwelling glory of God in creation.",
                meditation: "See a sphere of earth tones at your feet. Feel the grounded, manifest energy of the physical world. Divinity is fully present here and now, in every atom of creation.",
                keywords: ["Kingdom", "Physical World", "Manifestation", "Presence"]
            )
        ]
        
        // Hebrew Letters (22 letters of the Hebrew alphabet with paths)
        self.hebrewLetters = [
            HebrewLetter(letter: "א", name: "Aleph", value: 1, meaning: "Ox, Leader, Beginning", pathNumber: 11, connects: (1, 2), element: "Air", planet: nil, zodiac: nil, tarot: "The Fool", color: .yellow),
            HebrewLetter(letter: "ב", name: "Bet", value: 2, meaning: "House, Within, Container", pathNumber: 12, connects: (1, 3), element: nil, planet: nil, zodiac: nil, tarot: "The Magician", color: .yellow),
            HebrewLetter(letter: "ג", name: "Gimel", value: 3, meaning: "Camel, To Lift Up", pathNumber: 13, connects: (1, 6), element: nil, planet: nil, zodiac: nil, tarot: "The High Priestess", color: .blue),
            HebrewLetter(letter: "ד", name: "Dalet", value: 4, meaning: "Door, Entrance", pathNumber: 14, connects: (1, 4), element: nil, planet: nil, zodiac: nil, tarot: "The Empress", color: .green),
            HebrewLetter(letter: "ה", name: "He", value: 5, meaning: "Window, Behold", pathNumber: 15, connects: (2, 6), element: nil, planet: nil, zodiac: nil, tarot: "The Emperor", color: .red),
            HebrewLetter(letter: "ו", name: "Vav", value: 6, meaning: "Nail, Hook, And", pathNumber: 16, connects: (2, 4), element: nil, planet: nil, zodiac: nil, tarot: "The Hierophant", color: .orange),
            HebrewLetter(letter: "ז", name: "Zayin", value: 7, meaning: "Sword, Weapon, Armor", pathNumber: 17, connects: (3, 6), element: nil, planet: nil, zodiac: nil, tarot: "The Lovers", color: .orange),
            HebrewLetter(letter: "ח", name: "Het", value: 8, meaning: "Fence, Enclosure, Field", pathNumber: 18, connects: (3, 5), element: nil, planet: nil, zodiac: nil, tarot: "The Chariot", color: .orange),
            HebrewLetter(letter: "ט", name: "Tet", value: 9, meaning: "Serpent, Surround", pathNumber: 19, connects: (4, 6), element: nil, planet: nil, zodiac: nil, tarot: "Strength", color: .yellow),
            HebrewLetter(letter: "י", name: "Yod", value: 10, meaning: "Hand, Deed, Work", pathNumber: 20, connects: (4, 5), element: nil, planet: nil, zodiac: nil, tarot: "The Hermit", color: .green),
            HebrewLetter(letter: "כ", name: "Kaf", value: 20, meaning: "Palm, To Cover", pathNumber: 21, connects: (5, 6), element: nil, planet: nil, zodiac: nil, tarot: "Wheel of Fortune", color: .purple),
            HebrewLetter(letter: "ל", name: "Lamed", value: 30, meaning: "Ox Goad, Teach, Learn", pathNumber: 22, connects: (2, 3), element: nil, planet: nil, zodiac: nil, tarot: "Justice", color: .green),
            HebrewLetter(letter: "מ", name: "Mem", value: 40, meaning: "Water, Mass, Chaos", pathNumber: 23, connects: (3, 4), element: "Water", planet: nil, zodiac: nil, tarot: "The Hanged Man", color: .blue),
            HebrewLetter(letter: "נ", name: "Nun", value: 50, meaning: "Fish, Activity, Life", pathNumber: 24, connects: (5, 7), element: nil, planet: nil, zodiac: nil, tarot: "Death", color: .green),
            HebrewLetter(letter: "ס", name: "Samekh", value: 60, meaning: "Prop, Support", pathNumber: 25, connects: (6, 7), element: nil, planet: nil, zodiac: nil, tarot: "Temperance", color: .blue),
            HebrewLetter(letter: "ע", name: "Ayin", value: 70, meaning: "Eye, Fountain, Know", pathNumber: 26, connects: (6, 8), element: nil, planet: nil, zodiac: nil, tarot: "The Devil", color: .red),
            HebrewLetter(letter: "פ", name: "Pe", value: 80, meaning: "Mouth, Speak", pathNumber: 27, connects: (5, 8), element: nil, planet: nil, zodiac: nil, tarot: "The Tower", color: .red),
            HebrewLetter(letter: "צ", name: "Tsade", value: 90, meaning: "Fish Hook, Hunt", pathNumber: 28, connects: (7, 9), element: nil, planet: nil, zodiac: nil, tarot: "The Star", color: .red),
            HebrewLetter(letter: "ק", name: "Qof", value: 100, meaning: "Back of Head, Monkey", pathNumber: 29, connects: (8, 9), element: nil, planet: nil, zodiac: nil, tarot: "The Moon", color: .red),
            HebrewLetter(letter: "ר", name: "Resh", value: 200, meaning: "Head, Beginning", pathNumber: 30, connects: (6, 9), element: nil, planet: nil, zodiac: nil, tarot: "The Sun", color: .orange),
            HebrewLetter(letter: "ש", name: "Shin", value: 300, meaning: "Tooth, Fire, Consume", pathNumber: 31, connects: (7, 8), element: "Fire", planet: nil, zodiac: nil, tarot: "Judgement", color: .red),
            HebrewLetter(letter: "ת", name: "Tav", value: 400, meaning: "Cross, Mark, Seal", pathNumber: 32, connects: (9, 10), element: nil, planet: nil, zodiac: nil, tarot: "The World", color: .blue),
            // Hidden paths to Da'at (11th Sephira)
            HebrewLetter(letter: "ך", name: "Kaf Sofit", value: 20, meaning: "The Hidden Door to Knowledge", pathNumber: 33, connects: (1, 11), element: nil, planet: nil, zodiac: nil, tarot: "The Abyss", color: .purple),
            HebrewLetter(letter: "ם", name: "Mem Sofit", value: 40, meaning: "Waters of the Abyss", pathNumber: 34, connects: (6, 11), element: "Water", planet: nil, zodiac: nil, tarot: "The Deep", color: .blue),
            HebrewLetter(letter: "ן", name: "Nun Sofit", value: 50, meaning: "Death and Rebirth in Knowledge", pathNumber: 35, connects: (2, 11), element: nil, planet: nil, zodiac: nil, tarot: "Transformation", color: .green),
            HebrewLetter(letter: "ף", name: "Pe Sofit", value: 80, meaning: "The Silent Speech of Gnosis", pathNumber: 36, connects: (3, 11), element: nil, planet: nil, zodiac: nil, tarot: "Silent Voice", color: .red)
        ]
        
        // Astrological correspondences
        self.astrology = [
            AstrologyCorrespondence(symbol: "☉", name: "Sun", rulingSephira: 6, hebrewLetter: "ר", description: "The Sun rules Tiphareth, the heart center. Solar energy brings vitality, consciousness, and the integration of all opposites."),
            AstrologyCorrespondence(symbol: "☽", name: "Moon", rulingSephira: 9, hebrewLetter: "ת", description: "The Moon rules Yesod, the astral foundation. Lunar energy governs dreams, intuition, and the subconscious mind."),
            AstrologyCorrespondence(symbol: "☿", name: "Mercury", rulingSephira: 8, hebrewLetter: "ב", description: "Mercury rules Hod, the sphere of intellect. Mercurial energy governs communication, learning, and magical systems."),
            AstrologyCorrespondence(symbol: "♀", name: "Venus", rulingSephira: 7, hebrewLetter: "ד", description: "Venus rules Netzach, the sphere of love and art. Venusian energy brings beauty, emotion, and creative inspiration."),
            AstrologyCorrespondence(symbol: "♂", name: "Mars", rulingSephira: 5, hebrewLetter: "פ", description: "Mars rules Geburah, the sphere of strength. Martial energy provides courage, discipline, and the power to overcome obstacles."),
            AstrologyCorrespondence(symbol: "♃", name: "Jupiter", rulingSephira: 4, hebrewLetter: "כ", description: "Jupiter rules Chesed, the sphere of mercy. Jovian energy expands, blesses, and brings wisdom and good fortune."),
            AstrologyCorrespondence(symbol: "♄", name: "Saturn", rulingSephira: 3, hebrewLetter: "ת", description: "Saturn has affinity with Binah, the Great Mother. Saturnine energy brings structure, limitation, and deep understanding."),
            AstrologyCorrespondence(symbol: "♈", name: "Aries", rulingSephira: 5, hebrewLetter: "ה", description: "Aries connects to Geburah through the Hebrew letter He. Cardinal fire brings initiatory energy and the spark of action."),
            AstrologyCorrespondence(symbol: "♉", name: "Taurus", rulingSephira: 5, hebrewLetter: "ו", description: "Taurus connects to Geburah through Vav. Fixed earth brings persistence and the power to manifest desires."),
            AstrologyCorrespondence(symbol: "♊", name: "Gemini", rulingSephira: 3, hebrewLetter: "ז", description: "Gemini connects to Binah through Zayin. Mutable air brings adaptability and the duality of perception."),
            AstrologyCorrespondence(symbol: "♋", name: "Cancer", rulingSephira: 3, hebrewLetter: "ח", description: "Cancer connects to Binah through Het. Cardinal water brings nurturing energy and emotional depth."),
            AstrologyCorrespondence(symbol: "♌", name: "Leo", rulingSephira: 6, hebrewLetter: "ט", description: "Leo connects to Tiphareth through Tet. Fixed fire brings creative expression and the radiance of the heart."),
            AstrologyCorrespondence(symbol: "♍", name: "Virgo", rulingSephira: 3, hebrewLetter: "י", description: "Virgo connects to Binah through Yod. Mutable earth brings discernment and the wisdom of service."),
            AstrologyCorrespondence(symbol: "♎", name: "Libra", rulingSephira: 4, hebrewLetter: "ל", description: "Libra connects to Chesed through Lamed. Cardinal air brings balance, justice, and harmonious relationships."),
            AstrologyCorrespondence(symbol: "♏", name: "Scorpio", rulingSephira: 5, hebrewLetter: "נ", description: "Scorpio connects to Geburah through Nun. Fixed water brings transformation and the courage to face the shadow."),
            AstrologyCorrespondence(symbol: "♐", name: "Sagittarius", rulingSephira: 5, hebrewLetter: "ס", description: "Sagittarius connects to Geburah through Samekh. Mutable fire brings expansion of consciousness and spiritual aspiration."),
            AstrologyCorrespondence(symbol: "♑", name: "Capricorn", rulingSephira: 3, hebrewLetter: "ע", description: "Capricorn connects to Binah through Ayin. Cardinal earth brings mastery through discipline and the wisdom of time."),
            AstrologyCorrespondence(symbol: "♒", name: "Aquarius", rulingSephira: 5, hebrewLetter: "צ", description: "Aquarius connects to Geburah through Tsade. Fixed air brings innovative thinking and service to humanity."),
            AstrologyCorrespondence(symbol: "♓", name: "Pisces", rulingSephira: 9, hebrewLetter: "ק", description: "Pisces connects to Yesod through Qof. Mutable water brings mystical sensitivity and connection to the collective unconscious."),
            // Da'at - Hidden Sephira
            AstrologyCorrespondence(symbol: "⛢", name: "Uranus", rulingSephira: 11, hebrewLetter: "ך", description: "Uranus corresponds to Da'at, the hidden Sephira of Knowledge. Uranian energy brings sudden illumination, breakthrough insights, and the lightning flash of gnosis that transcends ordinary understanding.")
        ]
        
        // Study lessons
        self.lessons = [
            KabbalahLesson(
                title: "Introduction to Kabbalah",
                subtitle: "The Tree of Life",
                content: """
                Kabbalah (meaning "to receive") is the mystical tradition of Judaism. At its heart lies the Tree of Life (Etz Chaim), a diagram of ten divine emanations called Sephirot, plus a hidden eleventh called Da'at (Knowledge).
                
                The Tree represents how the infinite divine (Ein Sof) manifests in creation. Each Sephira is a vessel of divine light, a stage in the process of manifestation from spirit to matter.
                
                The ten primary Sephirot are arranged in three columns:
                - The Pillar of Mercy (right): Expansion, giving, masculine
                - The Pillar of Severity (left): Contraction, receiving, feminine  
                - The Middle Pillar: Balance, integration, consciousness
                
                Da'at, the hidden Sephira, sits in the Abyss—the threshold between the Supernal Triad and the manifest world. It represents the direct knowing that emerges when Wisdom and Understanding unite.
                
                As you study, remember: Kabbalah is not merely intellectual. It is meant to transform the soul and connect the practitioner to the divine.
                """,
                sephiraFocus: nil,
                difficulty: .beginner,
                estimatedMinutes: 15,
                isCompleted: false
            ),
            KabbalahLesson(
                title: "Kether: The Crown",
                subtitle: "The First Emanation",
                content: """
                Kether means "Crown." It is the first manifestation from the unknowable Ein Sof (Infinite). Here, the divine will first expresses itself.
                
                Attributes of Kether:
                - Divine Name: Eheieh (I AM, I WILL BE)
                - Archangel: Metatron, the Prince of the Presence
                - Experience: Union with God
                
                Meditation: Sit in silence. Imagine a point of brilliant white light above your head. This is the Crown of creation, the source of all blessing. As you breathe, feel this light descending, connecting you to the infinite source.
                
                Kether cannot be truly known by the intellect. It must be experienced through contemplation and surrender.
                """,
                sephiraFocus: 1,
                difficulty: .intermediate,
                estimatedMinutes: 20,
                isCompleted: false
            ),
            KabbalahLesson(
                title: "Chokmah & Binah: Wisdom and Understanding",
                subtitle: "The Supernal Father and Mother",
                content: """
                Chokmah (Wisdom) and Binah (Understanding) form the next level of the Tree. They are the archetypal masculine and feminine principles.
                
                Chokmah (2nd Sephira):
                - The Supernal Father
                - Contains all potential, all possibility
                - The flash of intuition, the seed of creation
                - Unformed wisdom, the point before extension
                
                Binah (3rd Sephira):
                - The Supernal Mother
                - Gives form to the potential of Chokmah
                - The womb of creation, the understanding that structures
                - Where the abstract becomes concrete
                
                Together, they are the creative polarity from which all subsequent manifestation flows. Their union produces the six central Sephirot.
                """,
                sephiraFocus: 2,
                difficulty: .intermediate,
                estimatedMinutes: 25,
                isCompleted: false
            ),
            KabbalahLesson(
                title: "The Ethical Triad",
                subtitle: "Chesed, Geburah, and Tiphareth",
                content: """
                The fourth, fifth, and sixth Sephirot form the ethical triad, concerned with how we relate to others and balance opposing forces within ourselves.
                
                Chesed (Mercy):
                - Unconditional love and giving
                - The expansive force that says "yes"
                - Associated with Jupiter, the great benefic
                - Virtue: Obedience to the higher will
                
                Geburah (Severity):
                - Discipline and necessary boundaries
                - The contractive force that says "no"
                - Associated with Mars, strength and courage
                - Virtue: Courage to do what is right
                
                Tiphareth (Beauty):
                - The balance point, the heart center
                - Where mercy and severity harmonize
                - Associated with the Sun, consciousness itself
                - The Christ/Buddha consciousness within
                
                Spiritual growth requires both expansion (Chesed) and limitation (Geburah), finding the golden mean in Tiphareth.
                """,
                sephiraFocus: 6,
                difficulty: .intermediate,
                estimatedMinutes: 30,
                isCompleted: false
            ),
            KabbalahLesson(
                title: "The Astral Triangle",
                subtitle: "Netzach, Hod, and Yesod",
                content: """
                The seventh, eighth, and ninth Sephirot form the astral or magical triangle. This is the realm of dreams, emotions, thoughts, and subtle energies.
                
                Netzach (Victory):
                - The emotional nature, feelings, drives
                - Love, art, beauty, nature
                - Venusian energy, the triumph of persistence
                - Where we work with desire and inspiration
                
                Hod (Splendor):
                - The rational mind, intellect, communication
                - Magic, science, systems of knowledge
                - Mercurial energy, the splendor of mind
                - Where we work with information and symbols
                
                Yesod (Foundation):
                - The astral plane, the world of images
                - Dreams, the unconscious, subtle energies
                - Lunar energy, the foundation of manifestation
                - The filter through which divine energy flows into Malkuth
                
                Together, these three process the higher energies and prepare them for physical manifestation.
                """,
                sephiraFocus: 9,
                difficulty: .advanced,
                estimatedMinutes: 35,
                isCompleted: false
            ),
            KabbalahLesson(
                title: "Malkuth: The Kingdom",
                subtitle: "Divinity in Matter",
                content: """
                Malkuth is the tenth and final Sephira. It represents the physical world, the completion of the Tree, and the descent of spirit into matter.
                
                Attributes of Malkuth:
                - Divine Name: Adonai Ha-Aretz (Lord of the Earth)
                - Archangel: Sandalphon, the Prince of the Presence
                - Element: Earth (the material plane)
                - Experience: The presence of God in all things
                
                Malkuth is often misunderstood as "lowest" or least spiritual. In truth, it is the culmination of the entire creative process. Without Malkuth, the Tree would be incomplete. The divine purpose is to be fully present in creation.
                
                The Shekinah (divine presence) dwells in Malkuth. Every physical object, every experience, every breath contains this holy presence.
                
                Practice: Walk in nature with the awareness that every stone, tree, and creature is a manifestation of the divine. This is the essence of Malkuth consciousness.
                """,
                sephiraFocus: 10,
                difficulty: .beginner,
                estimatedMinutes: 20,
                isCompleted: false
            ),
            KabbalahLesson(
                title: "The 22 Paths",
                subtitle: "Hebrew Letters on the Tree",
                content: """
                The Tree of Life contains not only the ten Sephirot but also 22 paths connecting them. Each path is associated with a Hebrew letter and a Tarot card.
                
                The paths represent:
                - The journey between different states of consciousness
                - The energies that flow between the Sephirot
                - Stages of spiritual development
                
                The 22 paths correspond to:
                - The 22 letters of the Hebrew alphabet
                - The 22 Major Arcana of the Tarot
                - The 22 chromosomes (in some modern interpretations)
                
                Three Mother Letters (Aleph, Mem, Shin) connect the three highest Sephirot to Tiphareth, representing Air, Water, and Fire.
                
                Seven Double Letters (Bet, Gimel, Dalet, Kaf, Pe, Resh, Tav) connect to the seven planets and represent dualities like life/death, peace/war, wisdom/folly.
                
                Twelve Simple Letters represent the zodiac signs and the twelve tribes of Israel.
                
                Pathworking meditation involves visualizing journeying along these paths, encountering the corresponding letter energies, and integrating their wisdom.
                """,
                sephiraFocus: nil,
                difficulty: .advanced,
                estimatedMinutes: 40,
                isCompleted: false
            ),
            KabbalahLesson(
                title: "Gematria: Hebrew Numerology",
                subtitle: "The Mathematics of Creation",
                content: """
                Gematria is the system of assigning numerical values to Hebrew letters, revealing hidden connections between words and concepts.
                
                Basic principles:
                - Each letter has a numerical value (1-400)
                - Words with the same numerical value are mystically connected
                - This reveals deeper layers of meaning in sacred texts
                
                Important values:
                - 1 = Aleph = God = Unity = Beginnings
                - 3 = Gimel = Abundant flow
                - 4 = Dalet = Door, the four worlds
                - 10 = Yod = The hand of God, completion of the decimal
                - 26 = YHVH = The Tetragrammaton, the divine name
                - 72 = Chesed = Mercy, the 72 names of God
                
                Example: The word "light" (אור) has a value of 207. The word "secret" (רז) has a value of 207. This suggests light is the secret of creation.
                
                Gematria is not mere numerology but a way of perceiving the mathematical structure underlying all reality—the code of creation itself.
                """,
                sephiraFocus: nil,
                difficulty: .intermediate,
                estimatedMinutes: 25,
                isCompleted: false
            ),
            KabbalahLesson(
                title: "Da'at: The Hidden Sephira",
                subtitle: "Knowledge and the Abyss",
                content: """
                Da'at (Knowledge) is the hidden eleventh Sephira, positioned in the Abyss between the Supernal Triad and the rest of the Tree. Unlike other Sephirot, Da'at is not a vessel but an opening—a dynamic space where divine knowledge becomes accessible to human consciousness.
                
                The Nature of Da'at:
                - Hebrew: דעת (Da'at) - from the root meaning "to know"
                - Position: The Abyss, between Chokmah and Binah
                - Divine Name: YHVH Elohim (same as Binah)
                - Archangel: Uriel (Light of God)
                - Angelic Order: Cherubim
                
                Da'at represents the synthesis of Wisdom (Chokmah) and Understanding (Binah). While Chokmah is the flash of insight and Binah is the structuring of that insight, Da'at is the actual knowing—the moment when knowledge crystallizes into consciousness.
                
                The Abyss (Tehom) separates the Supernal Triad (the divine realm beyond ordinary consciousness) from the lower seven Sephirot (the realm of manifest reality). Da'at is the bridge across this Abyss, the point where the infinite touches the finite.
                
                In the human soul, Da'at corresponds to the faculty of direct knowing or gnosis—not knowledge about something, but the intimate knowledge that transforms the knower. It is the threshold where the seeker becomes the mystic.
                
                Da'at is sometimes called the "invisible Sephira" because it is not always present on the Tree. It emerges only when the soul is ready to cross the Abyss, when Wisdom and Understanding have been sufficiently integrated to give birth to true Knowledge.
                
                Meditation: Visualize yourself standing at the edge of an infinite abyss. Above you are the radiant lights of Wisdom and Understanding. Feel the space between them—that is Da'at. Breathe into this space and let it open within you. This is the doorway to direct knowing.
                """,
                sephiraFocus: 11,
                difficulty: .advanced,
                estimatedMinutes: 30,
                isCompleted: false
            )
        ]
        
        // Set daily Sephira based on current date
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let sephiraIndex = (dayOfYear - 1) % 11
        self.dailySephira = sephirot[sephiraIndex]
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Gematria Calculator

class GematriaCalculator {
    static let shared = GematriaCalculator()
    
    private let letterValues: [Character: Int] = [
        "א": 1, "ב": 2, "ג": 3, "ד": 4, "ה": 5, "ו": 6, "ז": 7, "ח": 8, "ט": 9,
        "י": 10, "כ": 20, "ל": 30, "מ": 40, "נ": 50, "ס": 60, "ע": 70, "פ": 80, "צ": 90,
        "ק": 100, "ר": 200, "ש": 300, "ת": 400,
        "ך": 20, "ם": 40, "ן": 50, "ף": 80, "ץ": 90
    ]
    
    func calculate(_ text: String) -> Int {
        return text.reduce(0) { sum, char in
            sum + (letterValues[char] ?? 0)
        }
    }
    
    func toHebrew(_ text: String) -> String {
        // Simple mapping - in a real app, this would use proper transliteration
        let mapping: [Character: String] = [
            "a": "א", "b": "ב", "c": "כ", "d": "ד", "e": "ע", "f": "פ",
            "g": "ג", "h": "ה", "i": "י", "j": "י", "k": "כ", "l": "ל",
            "m": "מ", "n": "נ", "o": "ו", "p": "פ", "q": "ק", "r": "ר",
            "s": "ס", "t": "ת", "u": "ו", "v": "ב", "w": "ו", "x": "כס",
            "y": "י", "z": "ז"
        ]
        return text.lowercased().compactMap { mapping[$0] }.joined()
    }
}

// MARK: - Main View

struct KabbalahView: View {
    @StateObject private var dataStore = KabbalahDataStore.shared
    @State private var selectedTab = 0
    @State private var selectedSephira: Sephira?
    @State private var showSephiraDetail = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        Color(hex: "0a0a0f"),
                        Color(hex: "1a1a2e"),
                        Color(hex: "16213e")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    KabbalahHeader()
                    
                    // Tab Selection
                    Picker("View", selection: $selectedTab) {
                        Text("Tree").tag(0)
                        Text("Sephirot").tag(1)
                        Text("Letters").tag(2)
                        Text("Gematria").tag(3)
                        Text("Study").tag(4)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    .colorMultiply(Color(hex: "E5C158"))
                    .accessibilityLabel("Kabbalah section selector")
                    .accessibilityHint("Swipe up or down to select between Tree of Life, Sephirot, Hebrew Letters, Gematria, or Study sections")
                    
                    // Content
                    TabView(selection: $selectedTab) {
                        TreeOfLifeView(selectedSephira: $selectedSephira, showDetail: $showSephiraDetail)
                            .tag(0)
                        
                        SephirotListView()
                            .tag(1)
                        
                        HebrewLettersView()
                            .tag(2)
                        
                        GematriaView()
                            .tag(3)
                        
                        StudyView()
                            .tag(4)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(item: $selectedSephira) { sephira in
            SephiraDetailView(sephira: sephira)
        }
    }
}

// MARK: - Header

struct KabbalahHeader: View {
    @StateObject private var dataStore = KabbalahDataStore.shared
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("QodeX")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "E5C158").opacity(0.7))
                    
                    Text("Kabbalah")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Daily Sephira Indicator
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Daily Focus")
                        .font(.caption)
                        .foregroundColor(Color(hex: "E5C158").opacity(0.7))
                    
                    HStack(spacing: 8) {
                        Circle()
                            .fill(dataStore.dailySephira.colorKingScale)
                            .frame(width: 12, height: 12)
                            .shadow(color: dataStore.dailySephira.colorKingScale, radius: 4)
                        
                        Text(dataStore.dailySephira.name)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
            }
            
            Divider()
                .background(Color(hex: "E5C158").opacity(0.3))
        }
        .padding()
        .background(
            GlassmorphicCard(opacity: 0.1)
        )
    }
}

// MARK: - Tree of Life View

struct TreeOfLifeView: View {
    @Binding var selectedSephira: Sephira?
    @Binding var showDetail: Bool
    @StateObject private var dataStore = KabbalahDataStore.shared
    @State private var showPaths = true
    @State private var showLetters = false
    @State private var pulseSephira: Int? = nil
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Controls
                HStack(spacing: 16) {
                    Toggle("Paths", isOn: $showPaths)
                        .toggleStyle(SwitchToggleStyle(tint: Color(hex: "E5C158")))
                        .foregroundColor(.white)
                        .accessibilityLabel("Show connecting paths")
                        .accessibilityHint("Toggle to show or hide the connecting paths between Sephirot")
                    
                    Toggle("Letters", isOn: $showLetters)
                        .toggleStyle(SwitchToggleStyle(tint: Color(hex: "E5C158")))
                        .foregroundColor(.white)
                        .accessibilityLabel("Show Hebrew letters")
                        .accessibilityHint("Toggle to show or hide Hebrew letters on the paths")
                }
                .font(.caption)
                .padding(.horizontal)
                
                // Tree Diagram
                GeometryReader { geometry in
                    ZStack {
                        // Draw paths
                        if showPaths {
                            TreePathsView(sephirot: dataStore.sephirot, letters: showLetters ? dataStore.hebrewLetters : [])
                        }
                        
                        // Draw Sephirot
                        ForEach(dataStore.sephirot) { sephira in
                            SephiraNode(
                                sephira: sephira,
                                isPulsing: pulseSephira == sephira.number,
                                onTap: {
                                    withAnimation(.spring()) {
                                        selectedSephira = sephira
                                    }
                                }
                            )
                            .position(
                                x: sephira.position.x * geometry.size.width,
                                y: sephira.position.y * 500
                            )
                        }
                    }
                    .frame(height: 520)
                }
                .frame(height: 520)
                
                // Daily Focus Card
                DailyFocusCard()
                    .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
}

struct SephiraNode: View {
    let sephira: Sephira
    let isPulsing: Bool
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Outer glow
                Circle()
                    .fill(sephira.colorKingScale.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .blur(radius: isPulsing ? 15 : 8)
                    .scaleEffect(isPulsing ? 1.3 : 1.0)
                    .animation(isPulsing ? .easeInOut(duration: 1.5).repeatForever(autoreverses: true) : .default, value: isPulsing)
                
                // Main sphere with glass effect
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                sephira.colorKingScale,
                                sephira.colorKingScale.opacity(0.6),
                                sephira.colorQueenScale.opacity(0.3)
                            ],
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: 30
                        )
                    )
                    .frame(width: 50, height: 50)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: sephira.colorKingScale.opacity(0.5), radius: 10)
                
                // Number
                Text("\(sephira.number)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 2)
            }
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("\(sephira.name), Sephira number \(sephira.number)")
        .accessibilityHint("Meaning: \(sephira.meaning). Double tap to view details about \(sephira.name)")
        .pressEvents {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
        } onRelease: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = false
            }
        }
    }
}

struct TreePathsView: View {
    let sephirot: [Sephira]
    let letters: [HebrewLetter]
    
    private let pathConnections: [(Int, Int)] = [
        (1, 2), (1, 3), (1, 4), (1, 6),
        (2, 11), (3, 11), // Da'at connections
        (2, 3), (2, 4), (2, 6),
        (3, 5), (3, 6),
        (4, 5), (4, 6),
        (5, 6), (5, 7), (5, 8),
        (6, 7), (6, 8), (6, 9), (6, 11), // Tiphareth to Da'at
        (7, 8), (7, 9),
        (8, 9),
        (9, 10)
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(pathConnections, id: \.self) { connection in
                    if let from = sephirot.first(where: { $0.number == connection.0 }),
                       let to = sephirot.first(where: { $0.number == connection.1 }) {
                        
                        Path { path in
                            let start = CGPoint(
                                x: from.position.x * geometry.size.width,
                                y: from.position.y * 500
                            )
                            let end = CGPoint(
                                x: to.position.x * geometry.size.width,
                                y: to.position.y * 500
                            )
                            path.move(to: start)
                            path.addLine(to: end)
                        }
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(hex: "E5C158").opacity(0.4),
                                    Color(hex: "E5C158").opacity(0.2)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 2
                        )
                        
                        // Hebrew letter on path
                        if !letters.isEmpty {
                            if let letter = letters.first(where: { 
                                ($0.connects?.0 == connection.0 && $0.connects?.1 == connection.1) ||
                                ($0.connects?.0 == connection.1 && $0.connects?.1 == connection.0)
                            }) {
                                Text(letter.letter)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(Color(hex: "E5C158"))
                                    .position(
                                        x: (from.position.x + to.position.x) / 2 * geometry.size.width,
                                        y: (from.position.y + to.position.y) / 2 * 500
                                    )
                                    .background(
                                        Circle()
                                            .fill(Color(hex: "0a0a0f").opacity(0.8))
                                            .frame(width: 24, height: 24)
                                    )
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Daily Focus Card

struct DailyFocusCard: View {
    @StateObject private var dataStore = KabbalahDataStore.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .foregroundColor(Color(hex: "E5C158"))
                    
                    Text("Today's Sephira Focus")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Circle()
                    .fill(dataStore.dailySephira.colorKingScale)
                    .frame(width: 20, height: 20)
                    .shadow(color: dataStore.dailySephira.colorKingScale, radius: 6)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(dataStore.dailySephira.hebrewName)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(hex: "E5C158"))
                    
                    Text(dataStore.dailySephira.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                
                Text(dataStore.dailySephira.meaning)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text(dataStore.dailySephira.description.prefix(150) + "...")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(3)
            }
            
            Divider()
                .background(Color.white.opacity(0.1))
            
            HStack {
                Image(systemName: "moon.stars.fill")
                    .foregroundColor(Color(hex: "E5C158"))
                
                Text("Evening Meditation")
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {}) {
                    Text("Begin")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Color(hex: "E5C158"))
                        .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(GlassmorphicCard())
    }
}

// MARK: - Sephirot List View

struct SephirotListView: View {
    @StateObject private var dataStore = KabbalahDataStore.shared
    @State private var selectedSephira: Sephira?
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(dataStore.sephirot) { sephira in
                    SephiraRow(sephira: sephira)
                        .onTapGesture {
                            selectedSephira = sephira
                        }
                }
            }
            .padding()
        }
        .sheet(item: $selectedSephira) { sephira in
            SephiraDetailView(sephira: sephira)
        }
    }
}

struct SephiraRow: View {
    let sephira: Sephira
    
    var body: some View {
        HStack(spacing: 16) {
            // Number circle
            ZStack {
                Circle()
                    .fill(sephira.colorKingScale.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Circle()
                    .fill(sephira.colorKingScale)
                    .frame(width: 36, height: 36)
                    .shadow(color: sephira.colorKingScale.opacity(0.5), radius: 6)
                
                Text("\(sephira.number)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(sephira.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(sephira.hebrewName)
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "E5C158"))
                }
                
                Text(sephira.meaning)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                HStack(spacing: 12) {
                    if let planet = sephira.planet {
                        Label(planet, systemImage: "circle.fill")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    
                    if let element = sephira.element {
                        Label(element, systemImage: "triangle.fill")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(Color(hex: "E5C158").opacity(0.6))
        }
        .padding()
        .background(GlassmorphicCard())
    }
}

// MARK: - Sephira Detail View

struct SephiraDetailView: View {
    let sephira: Sephira
    @State private var selectedSection = 0
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        Color(hex: "0a0a0f"),
                        sephira.colorKingScale.opacity(0.3),
                        Color(hex: "0a0a0f")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        SephiraHeader(sephira: sephira)
                        
                        // Section picker
                        Picker("Section", selection: $selectedSection) {
                            Text("Overview").tag(0)
                            Text("Correspondences").tag(1)
                            Text("Meditation").tag(2)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        .colorMultiply(Color(hex: "E5C158"))
                        
                        // Content
                        Group {
                            switch selectedSection {
                            case 0:
                                SephiraOverview(sephira: sephira)
                            case 1:
                                SephiraCorrespondences(sephira: sephira)
                            case 2:
                                SephiraMeditation(sephira: sephira)
                            default:
                                EmptyView()
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "E5C158"))
                }
            }
        }
    }
}

struct SephiraHeader: View {
    let sephira: Sephira
    
    var body: some View {
        VStack(spacing: 16) {
            // Large Sephira symbol
            ZStack {
                Circle()
                    .fill(sephira.colorKingScale.opacity(0.2))
                    .frame(width: 140, height: 140)
                    .blur(radius: 20)
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                sephira.colorKingScale,
                                sephira.colorKingScale.opacity(0.7),
                                sephira.colorQueenScale
                            ],
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: 60
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: sephira.colorKingScale.opacity(0.6), radius: 20)
                
                Text(sephira.hebrewName)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 4)
            }
            
            VStack(spacing: 8) {
                Text(sephira.name)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                Text(sephira.meaning)
                    .font(.title3)
                    .foregroundColor(Color(hex: "E5C158"))
                
                Text("Sephira #\(sephira.number)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }
}

struct SephiraOverview: View {
    let sephira: Sephira
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionCard(title: "Description", icon: "text.alignleft") {
                Text(sephira.description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9))
                    .lineSpacing(4)
            }
            
            SectionCard(title: "Keywords", icon: "tag.fill") {
                FlowLayout(spacing: 8) {
                    ForEach(sephira.keywords, id: \.self) { keyword in
                        Text(keyword)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(Color(hex: "E5C158"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color(hex: "E5C158").opacity(0.15))
                            )
                    }
                }
            }
            
            SectionCard(title: "Divine Attributes", icon: "sparkles") {
                VStack(alignment: .leading, spacing: 8) {
                    AttributeRow(label: "Divine Name", value: sephira.divineName)
                    AttributeRow(label: "Archangel", value: sephira.archangel)
                    AttributeRow(label: "Angelic Order", value: sephira.angelicOrder)
                }
            }
            
            SectionCard(title: "Moral Qualities", icon: "scale.3d") {
                HStack(spacing: 16) {
                    QualityCard(title: "Virtue", value: sephira.virtue, color: .green)
                    QualityCard(title: "Vice", value: sephira.vice, color: .red)
                }
            }
        }
    }
}

struct SephiraCorrespondences: View {
    let sephira: Sephira
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionCard(title: "Planetary & Elemental", icon: "globe") {
                VStack(spacing: 12) {
                    if let planet = sephira.planet {
                        CorrespondenceRow(
                            icon: "circle.fill",
                            label: "Planet",
                            value: planet
                        )
                    }
                    
                    if let element = sephira.element {
                        CorrespondenceRow(
                            icon: "triangle.fill",
                            label: "Element",
                            value: element
                        )
                    }
                    
                    if sephira.planet == nil && sephira.element == nil {
                        CorrespondenceRow(
                            icon: "star.fill",
                            label: "Nature",
                            value: "Beyond planetary influence"
                        )
                    }
                }
            }
            
            SectionCard(title: "Colors", icon: "paintpalette.fill") {
                HStack(spacing: 16) {
                    ColorCard(
                        title: "King Scale",
                        color: sephira.colorKingScale
                    )
                    ColorCard(
                        title: "Queen Scale",
                        color: sephira.colorQueenScale
                    )
                }
            }
            
            SectionCard(title: "Gematria", icon: "number") {
                let hebrewValue = GematriaCalculator.shared.calculate(sephira.hebrewLetters)
                VStack(spacing: 8) {
                    Text("\(sephira.hebrewLetters) = \(hebrewValue)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(hex: "E5C158"))
                    
                    Text("Numerical value of the Hebrew name")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "E5C158").opacity(0.1))
                )
            }
        }
    }
}

struct SephiraMeditation: View {
    let sephira: Sephira
    @State private var isMeditating = false
    @State private var breathPhase = 0
    @State private var timer: Timer? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            if !isMeditating {
                SectionCard(title: "Guided Meditation", icon: "moon.stars.fill") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(sephira.meditation)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                            .lineSpacing(6)
                        
                        Divider()
                            .background(Color.white.opacity(0.1))
                        
                        Text("Practice this meditation for 10-15 minutes to connect with the energy of \(sephira.name).")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .italic()
                    }
                }
                
                Button(action: startMeditation) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Begin Meditation")
                    }
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "E5C158"))
                    .cornerRadius(16)
                }
                .padding(.horizontal)
            } else {
                // Active meditation view
                MeditationActiveView(
                    sephira: sephira,
                    breathPhase: $breathPhase,
                    onStop: stopMeditation
                )
            }
        }
    }
    
    private func startMeditation() {
        isMeditating = true
        timer = Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 2)) {
                breathPhase = (breathPhase + 1) % 3
            }
        }
    }
    
    private func stopMeditation() {
        isMeditating = false
        timer?.invalidate()
        timer = nil
    }
}

struct MeditationActiveView: View {
    let sephira: Sephira
    @Binding var breathPhase: Int
    let onStop: () -> Void
    
    private var breathText: String {
        switch breathPhase {
        case 0: return "Breathe In"
        case 1: return "Hold"
        default: return "Breathe Out"
        }
    }
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Animated sphere
            ZStack {
                ForEach(0..<3) { i in
                    Circle()
                        .stroke(sephira.colorKingScale.opacity(0.3 - Double(i) * 0.1), lineWidth: 2)
                        .frame(width: 120 + CGFloat(i * 40), height: 120 + CGFloat(i * 40))
                        .scaleEffect(breathPhase == 0 ? 1.3 : (breathPhase == 1 ? 1.3 : 1.0))
                        .animation(.easeInOut(duration: 4), value: breathPhase)
                }
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                sephira.colorKingScale,
                                sephira.colorKingScale.opacity(0.5)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 60
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: sephira.colorKingScale, radius: 30)
                    .scaleEffect(breathPhase == 0 ? 1.2 : (breathPhase == 1 ? 1.2 : 1.0))
                    .animation(.easeInOut(duration: 4), value: breathPhase)
                
                Text(sephira.hebrewName)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 16) {
                Text(breathText)
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(.white)
                
                Text("Focus on the energy of \(sephira.name)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: onStop) {
                Text("End Meditation")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.8))
                    .cornerRadius(16)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

// MARK: - Hebrew Letters View

struct HebrewLettersView: View {
    @StateObject private var dataStore = KabbalahDataStore.shared
    @State private var selectedLetter: HebrewLetter?
    @State private var filter = LetterFilter.all
    
    enum LetterFilter: String, CaseIterable {
        case all = "All"
        case mothers = "Mothers"
        case doubles = "Doubles"
        case simples = "Simples"
    }
    
    var filteredLetters: [HebrewLetter] {
        switch filter {
        case .all:
            return dataStore.hebrewLetters
        case .mothers:
            return dataStore.hebrewLetters.filter { ["א", "מ", "ש"].contains($0.letter) }
        case .doubles:
            return dataStore.hebrewLetters.filter { ["ב", "ג", "ד", "כ", "פ", "ר", "ת"].contains($0.letter) }
        case .simples:
            return dataStore.hebrewLetters.filter { !["א", "מ", "ש", "ב", "ג", "ד", "כ", "פ", "ר", "ת"].contains($0.letter) }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Filter picker
            Picker("Filter", selection: $filter) {
                ForEach(LetterFilter.allCases, id: \.self) { filter in
                    Text(filter.rawValue).tag(filter)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .colorMultiply(Color(hex: "E5C158"))
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(filteredLetters) { letter in
                        LetterRow(letter: letter)
                            .onTapGesture {
                                selectedLetter = letter
                            }
                    }
                }
                .padding()
            }
        }
        .sheet(item: $selectedLetter) { letter in
            LetterDetailView(letter: letter)
        }
    }
}

struct LetterRow: View {
    let letter: HebrewLetter
    
    var body: some View {
        HStack(spacing: 16) {
            // Letter
            Text(letter.letter)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(letter.color)
                .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(letter.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(letter.meaning)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                
                HStack(spacing: 12) {
                    Text("Value: \(letter.value)")
                        .font(.caption)
                        .foregroundColor(Color(hex: "E5C158"))
                    
                    if let connects = letter.connects {
                        Text("Path: \(connects.0)-\(connects.1)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(Color(hex: "E5C158").opacity(0.6))
        }
        .padding()
        .background(GlassmorphicCard())
    }
}

struct LetterDetailView: View {
    let letter: HebrewLetter
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "0a0a0f"), letter.color.opacity(0.2), Color(hex: "0a0a0f")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Large letter
                        Text(letter.letter)
                            .font(.system(size: 120, weight: .bold))
                            .foregroundColor(letter.color)
                            .shadow(color: letter.color.opacity(0.5), radius: 20)
                        
                        VStack(spacing: 8) {
                            Text(letter.name)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(letter.meaning)
                                .font(.title3)
                                .foregroundColor(Color(hex: "E5C158"))
                        }
                        
                        // Gematria
                        VStack(spacing: 8) {
                            Text("\(letter.value)")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(Color(hex: "E5C158"))
                            
                            Text("Gematria Value")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(hex: "E5C158").opacity(0.1))
                        )
                        
                        // Correspondences
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Correspondences")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            VStack(spacing: 8) {
                                if let element = letter.element {
                                    CorrespondenceRow(icon: "triangle.fill", label: "Element", value: element)
                                }
                                
                                if let planet = letter.planet {
                                    CorrespondenceRow(icon: "circle.fill", label: "Planet", value: planet)
                                }
                                
                                if let zodiac = letter.zodiac {
                                    CorrespondenceRow(icon: "star.fill", label: "Zodiac", value: zodiac)
                                }
                                
                                CorrespondenceRow(icon: "suit.spade.fill", label: "Tarot", value: letter.tarot)
                                
                                if let connects = letter.connects {
                                    CorrespondenceRow(
                                        icon: "arrow.left.and.right",
                                        label: "Connects",
                                        value: "Sephira \(connects.0) ↔ \(connects.1)"
                                    )
                                }
                            }
                            .padding()
                            .background(GlassmorphicCard())
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "E5C158"))
                }
            }
        }
    }
}

// MARK: - Gematria View

struct GematriaView: View {
    @State private var inputText = ""
    @State private var hebrewText = ""
    @State private var calculatedValue = 0
    @State private var history: [(text: String, hebrew: String, value: Int)] = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Calculator Card
                VStack(spacing: 16) {
                    Text("Hebrew Gematria Calculator")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    TextField("Enter name or word", text: $inputText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: inputText) { _ in
                            calculate()
                        }
                    
                    if !hebrewText.isEmpty {
                        VStack(spacing: 12) {
                            Text(hebrewText)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(Color(hex: "E5C158"))
                            
                            Text("= \(calculatedValue)")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(hex: "E5C158").opacity(0.1))
                        )
                    }
                    
                    Button(action: addToHistory) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Save Calculation")
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "E5C158"))
                        .cornerRadius(12)
                    }
                    .disabled(inputText.isEmpty)
                    .opacity(inputText.isEmpty ? 0.5 : 1)
                }
                .padding()
                .background(GlassmorphicCard())
                
                // Common Values Reference
                VStack(alignment: .leading, spacing: 12) {
                    Text("Common Values")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    VStack(spacing: 8) {
                        GematriaReferenceRow(hebrew: "אל", name: "El (God)", value: 31)
                        GematriaReferenceRow(hebrew: "יהוה", name: "YHVH", value: 26)
                        GematriaReferenceRow(hebrew: "אהיה", name: "Eheieh", value: 21)
                        GematriaReferenceRow(hebrew: "אדני", name: "Adonai", value: 65)
                        GematriaReferenceRow(hebrew: "אהבה", name: "Ahavah (Love)", value: 13)
                        GematriaReferenceRow(hebrew: "אמת", name: "Emet (Truth)", value: 441)
                    }
                }
                .padding()
                .background(GlassmorphicCard())
                
                // History
                if !history.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("History")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button(action: { history.removeAll() }) {
                                Text("Clear")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        
                        ForEach(history, id: \.text) { item in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.text)
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                    Text(item.hebrew)
                                        .font(.caption)
                                        .foregroundColor(Color(hex: "E5C158"))
                                }
                                
                                Spacer()
                                
                                Text("\(item.value)")
                                    .font(.headline)
                                    .foregroundColor(Color(hex: "E5C158"))
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding()
                    .background(GlassmorphicCard())
                }
            }
            .padding()
        }
    }
    
    private func calculate() {
        hebrewText = GematriaCalculator.shared.toHebrew(inputText)
        calculatedValue = GematriaCalculator.shared.calculate(hebrewText)
    }
    
    private func addToHistory() {
        guard !inputText.isEmpty else { return }
        history.insert((inputText, hebrewText, calculatedValue), at: 0)
        inputText = ""
        hebrewText = ""
        calculatedValue = 0
    }
}

struct GematriaReferenceRow: View {
    let hebrew: String
    let name: String
    let value: Int
    
    var body: some View {
        HStack {
            Text(hebrew)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(Color(hex: "E5C158"))
                .frame(width: 60, alignment: .leading)
            
            Text(name)
                .font(.subheadline)
                .foregroundColor(.white)
            
            Spacer()
            
            Text("\(value)")
                .font(.system(.subheadline, design: .monospaced))
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Study View

struct StudyView: View {
    @StateObject private var dataStore = KabbalahDataStore.shared
    @State private var selectedLesson: KabbalahLesson?
    @State private var showCompletedOnly = false
    
    var filteredLessons: [KabbalahLesson] {
        let lessons = dataStore.lessons
        if showCompletedOnly {
            return lessons.filter { dataStore.completedLessons.contains($0.id) }
        }
        return lessons
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Progress Card
                StudyProgressCard()
                
                // Filter toggle
                Toggle("Show Completed Only", isOn: $showCompletedOnly)
                    .toggleStyle(SwitchToggleStyle(tint: Color(hex: "E5C158")))
                    .foregroundColor(.white)
                    .padding(.horizontal)
                
                // Lessons list
                LazyVStack(spacing: 12) {
                    ForEach(filteredLessons) { lesson in
                        LessonRow(
                            lesson: lesson,
                            isCompleted: dataStore.completedLessons.contains(lesson.id)
                        )
                        .onTapGesture {
                            selectedLesson = lesson
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .sheet(item: $selectedLesson) { lesson in
            LessonDetailView(lesson: lesson)
        }
    }
}

struct StudyProgressCard: View {
    @StateObject private var dataStore = KabbalahDataStore.shared
    
    var progress: Double {
        Double(dataStore.completedLessons.count) / Double(dataStore.lessons.count)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Study Progress")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("\(dataStore.completedLessons.count) of \(dataStore.lessons.count) lessons completed")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(hex: "E5C158"))
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "E5C158"), Color(hex: "FFD700")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(progress), height: 8)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(GlassmorphicCard())
        .padding(.horizontal)
    }
}

struct LessonRow: View {
    let lesson: KabbalahLesson
    let isCompleted: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Completion indicator
            ZStack {
                Circle()
                    .fill(isCompleted ? Color.green.opacity(0.2) : Color.white.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: isCompleted ? "checkmark" : "book.fill")
                    .foregroundColor(isCompleted ? .green : Color(hex: "E5C158"))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(lesson.title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    if isCompleted {
                        Text("Done")
                            .font(.caption)
                            .foregroundColor(.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(Color.green.opacity(0.2))
                            )
                    }
                }
                
                Text(lesson.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack(spacing: 12) {
                    Text(lesson.difficulty.rawValue)
                        .font(.caption)
                        .foregroundColor(lesson.difficulty.color)
                    
                    Text("\(lesson.estimatedMinutes) min")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(Color(hex: "E5C158").opacity(0.6))
        }
        .padding()
        .background(GlassmorphicCard())
    }
}

struct LessonDetailView: View {
    let lesson: KabbalahLesson
    @Environment(\.dismiss) private var dismiss
    @StateObject private var dataStore = KabbalahDataStore.shared
    @State private var isCompleted: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "0a0a0f"), Color(hex: "1a1a2e")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 12) {
                            HStack {
                                Text(lesson.difficulty.rawValue)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(lesson.difficulty.color)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(lesson.difficulty.color.opacity(0.2))
                                    )
                                
                                Spacer()
                                
                                HStack(spacing: 4) {
                                    Image(systemName: "clock")
                                    Text("\(lesson.estimatedMinutes) min")
                                }
                                .font(.caption)
                                .foregroundColor(.gray)
                            }
                            
                            Text(lesson.title)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            Text(lesson.subtitle)
                                .font(.title3)
                                .foregroundColor(Color(hex: "E5C158"))
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.1))
                        
                        // Content
                        Text(lesson.content)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                            .lineSpacing(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        if let sephiraFocus = lesson.sephiraFocus,
                           let sephira = dataStore.sephirot.first(where: { $0.number == sephiraFocus }) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Related Sephira")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                HStack {
                                    Circle()
                                        .fill(sephira.colorKingScale)
                                        .frame(width: 16, height: 16)
                                    
                                    Text(sephira.name)
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                    
                                    Text(sephira.hebrewName)
                                        .font(.caption)
                                        .foregroundColor(Color(hex: "E5C158"))
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(GlassmorphicCard())
                        }
                        
                        // Complete button
                        Button(action: toggleCompletion) {
                            HStack {
                                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                                Text(isCompleted ? "Completed" : "Mark as Complete")
                            }
                            .font(.headline)
                            .foregroundColor(isCompleted ? .green : .black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isCompleted ? Color.green.opacity(0.2) : Color(hex: "E5C158"))
                            .cornerRadius(16)
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "E5C158"))
                }
            }
            .onAppear {
                isCompleted = dataStore.completedLessons.contains(lesson.id)
            }
        }
    }
    
    private func toggleCompletion() {
        if isCompleted {
            dataStore.completedLessons.remove(lesson.id)
        } else {
            dataStore.completedLessons.insert(lesson.id)
        }
        isCompleted.toggle()
    }
}

// MARK: - Helper Views

struct GlassmorphicCard: View {
    var opacity: Double = 0.15
    
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.white.opacity(opacity))
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.2), radius: 10)
    }
}

struct SectionCard<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Color(hex: "E5C158"))
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            content
        }
        .padding()
        .background(GlassmorphicCard())
    }
}

struct AttributeRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
    }
}

struct QualityCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

struct CorrespondenceRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "E5C158"))
                .frame(width: 24)
            
            Text(label)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
    }
}

struct ColorCard: View {
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 40, height: 40)
                .shadow(color: color.opacity(0.5), radius: 8)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                      y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
                
                self.size.width = max(self.size.width, x)
            }
            
            self.size.height = y + rowHeight
        }
    }
}

// MARK: - Press Events Modifier

struct PressEventsModifier: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in onPress() }
                    .onEnded { _ in onRelease() }
            )
    }
}

extension View {
    func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        modifier(PressEventsModifier(onPress: onPress, onRelease: onRelease))
    }
}

// MARK: - Preview

struct KabbalahView_Previews: PreviewProvider {
    static var previews: some View {
        KabbalahView()
            .preferredColorScheme(.dark)
    }
}
