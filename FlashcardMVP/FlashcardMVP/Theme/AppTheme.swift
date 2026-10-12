//
//  AppTheme.swift
//  FlashcardMVP
//
//  Selectable app themes (accent color + appearance + themed starter content)
//

import SwiftUI

// MARK: - Theme Categories

enum ThemeCategory: String, CaseIterable, Identifiable {
    case academicCompetitions
    case testPrep
    case subjects
    case appearance

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .academicCompetitions: return NSLocalizedString("Academic Competitions", comment: "")
        case .testPrep: return NSLocalizedString("Test Prep", comment: "")
        case .subjects: return NSLocalizedString("Subjects", comment: "")
        case .appearance: return NSLocalizedString("Appearance", comment: "")
        }
    }

    var iconName: String {
        switch self {
        case .academicCompetitions: return "trophy"
        case .testPrep: return "list.clipboard"
        case .subjects: return "book.pages"
        case .appearance: return "paintpalette"
        }
    }

    /// A distinctive gradient per category, used for icon tiles and headers.
    var gradientColors: [Color] {
        switch self {
        case .academicCompetitions:
            return [Color(red: 1.00, green: 0.75, blue: 0.15), Color(red: 0.92, green: 0.45, blue: 0.05)]
        case .testPrep:
            return [Color(red: 0.30, green: 0.45, blue: 0.95), Color(red: 0.20, green: 0.25, blue: 0.75)]
        case .subjects:
            return [Color(red: 0.10, green: 0.70, blue: 0.55), Color(red: 0.05, green: 0.45, blue: 0.40)]
        case .appearance:
            return [Color(red: 0.75, green: 0.35, blue: 0.85), Color(red: 0.50, green: 0.20, blue: 0.70)]
        }
    }
}

// MARK: - App Theme

enum AppTheme: String, CaseIterable, Identifiable {
    // Academic Competitions — core
    case standard
    case scienceOlympiad
    case mathOlympiad
    case spellingBee
    case geographyBee
    case quizBowl
    case debate

    // Academic Competitions — extended
    case chemistryOlympiad
    case physicsOlympiad
    case biologyOlympiad
    case scienceBowl
    case mathcounts
    case historyBee
    case chessTactics
    case cybersecurity

    // Test Prep — core
    case satAct
    case apExams
    case greToefl
    case mcat

    // Test Prep — extended
    case ielts
    case lsat
    case gmat
    case asvab
    case realEstateExam
    case nclex
    case pilotFAA
    case itCerts

    // Subjects — core
    case languages
    case coding
    case history
    case musicTheory

    // Subjects — extended
    case chemistry
    case physics
    case biology
    case astronomy
    case psychology
    case economics
    case philosophy
    case artHistory
    case literature
    case grammar
    case anatomy
    case finance
    case korean
    case german
    case italian
    case arabic

    // Appearance only
    case midnight
    case forest
    case ocean
    case sunset
    case kids
    case highContrast

    static let storageKey = "appTheme"

    var id: String { rawValue }

    // MARK: Metadata

    var category: ThemeCategory {
        switch self {
        case .standard, .scienceOlympiad, .mathOlympiad, .spellingBee, .geographyBee, .quizBowl, .debate,
             .chemistryOlympiad, .physicsOlympiad, .biologyOlympiad, .scienceBowl, .mathcounts, .historyBee,
             .chessTactics, .cybersecurity:
            return .academicCompetitions
        case .satAct, .apExams, .greToefl, .mcat,
             .ielts, .lsat, .gmat, .asvab, .realEstateExam, .nclex, .pilotFAA, .itCerts:
            return .testPrep
        case .languages, .coding, .history, .musicTheory,
             .chemistry, .physics, .biology, .astronomy, .psychology, .economics, .philosophy, .artHistory,
             .literature, .grammar, .anatomy, .finance, .korean, .german, .italian, .arabic:
            return .subjects
        case .midnight, .forest, .ocean, .sunset, .kids, .highContrast:
            return .appearance
        }
    }

    /// All themes that belong to the given category, in display order.
    static func themes(in category: ThemeCategory) -> [AppTheme] {
        allCases.filter { $0.category == category }
    }

    /// The theme whose starter deck matches the given deck name, if any.
    static func theme(forDeckName name: String) -> AppTheme? {
        allCases.first { $0.hasStarterDeck && $0.starterDeckName == name }
    }

    var displayName: String {
        switch self {
        case .standard: return NSLocalizedString("Standard", comment: "")
        case .scienceOlympiad: return NSLocalizedString("Science Olympiad", comment: "")
        case .mathOlympiad: return NSLocalizedString("Math Olympiad", comment: "")
        case .spellingBee: return NSLocalizedString("Spelling Bee", comment: "")
        case .geographyBee: return NSLocalizedString("Geography Bee", comment: "")
        case .quizBowl: return NSLocalizedString("Quiz Bowl", comment: "")
        case .debate: return NSLocalizedString("Debate", comment: "")
        case .chemistryOlympiad: return NSLocalizedString("Chemistry Olympiad", comment: "")
        case .physicsOlympiad: return NSLocalizedString("Physics Olympiad", comment: "")
        case .biologyOlympiad: return NSLocalizedString("Biology Olympiad", comment: "")
        case .scienceBowl: return NSLocalizedString("Science Bowl", comment: "")
        case .mathcounts: return NSLocalizedString("MATHCOUNTS", comment: "")
        case .historyBee: return NSLocalizedString("History Bee", comment: "")
        case .chessTactics: return NSLocalizedString("Chess Tactics", comment: "")
        case .cybersecurity: return NSLocalizedString("Cybersecurity", comment: "")
        case .satAct: return NSLocalizedString("SAT / ACT", comment: "")
        case .apExams: return NSLocalizedString("AP Exams", comment: "")
        case .greToefl: return NSLocalizedString("GRE / TOEFL", comment: "")
        case .mcat: return NSLocalizedString("Medical / MCAT", comment: "")
        case .ielts: return NSLocalizedString("IELTS", comment: "")
        case .lsat: return NSLocalizedString("LSAT", comment: "")
        case .gmat: return NSLocalizedString("GMAT", comment: "")
        case .asvab: return NSLocalizedString("ASVAB", comment: "")
        case .realEstateExam: return NSLocalizedString("Real Estate Exam", comment: "")
        case .nclex: return NSLocalizedString("NCLEX Nursing", comment: "")
        case .pilotFAA: return NSLocalizedString("Pilot Exam (FAA)", comment: "")
        case .itCerts: return NSLocalizedString("IT Certifications", comment: "")
        case .languages: return NSLocalizedString("Languages", comment: "")
        case .coding: return NSLocalizedString("Coding", comment: "")
        case .history: return NSLocalizedString("History", comment: "")
        case .musicTheory: return NSLocalizedString("Music Theory", comment: "")
        case .chemistry: return NSLocalizedString("Chemistry", comment: "")
        case .physics: return NSLocalizedString("Physics", comment: "")
        case .biology: return NSLocalizedString("Biology", comment: "")
        case .astronomy: return NSLocalizedString("Astronomy", comment: "")
        case .psychology: return NSLocalizedString("Psychology", comment: "")
        case .economics: return NSLocalizedString("Economics", comment: "")
        case .philosophy: return NSLocalizedString("Philosophy", comment: "")
        case .artHistory: return NSLocalizedString("Art History", comment: "")
        case .literature: return NSLocalizedString("Literature", comment: "")
        case .grammar: return NSLocalizedString("Grammar & Style", comment: "")
        case .anatomy: return NSLocalizedString("Anatomy", comment: "")
        case .finance: return NSLocalizedString("Finance & Investing", comment: "")
        case .korean: return NSLocalizedString("Korean", comment: "")
        case .german: return NSLocalizedString("German", comment: "")
        case .italian: return NSLocalizedString("Italian", comment: "")
        case .arabic: return NSLocalizedString("Arabic", comment: "")
        case .midnight: return NSLocalizedString("Midnight", comment: "")
        case .forest: return NSLocalizedString("Forest", comment: "")
        case .ocean: return NSLocalizedString("Ocean", comment: "")
        case .sunset: return NSLocalizedString("Sunset", comment: "")
        case .kids: return NSLocalizedString("Playful", comment: "")
        case .highContrast: return NSLocalizedString("High Contrast", comment: "")
        }
    }

    var iconName: String {
        switch self {
        case .standard: return "paintpalette"
        case .scienceOlympiad: return "atom"
        case .mathOlympiad: return "x.squareroot"
        case .spellingBee: return "textformat.abc"
        case .geographyBee: return "globe.americas"
        case .quizBowl: return "lightbulb"
        case .debate: return "bubble.left.and.bubble.right"
        case .chemistryOlympiad: return "flask"
        case .physicsOlympiad: return "bolt"
        case .biologyOlympiad: return "microbe"
        case .scienceBowl: return "questionmark.bubble"
        case .mathcounts: return "number"
        case .historyBee: return "books.vertical"
        case .chessTactics: return "crown"
        case .cybersecurity: return "lock.shield"
        case .satAct: return "pencil.and.outline"
        case .apExams: return "graduationcap"
        case .greToefl: return "book.closed"
        case .mcat: return "cross.case"
        case .ielts: return "doc.text.magnifyingglass"
        case .lsat: return "scalemass"
        case .gmat: return "chart.bar"
        case .asvab: return "shield"
        case .realEstateExam: return "house"
        case .nclex: return "stethoscope"
        case .pilotFAA: return "airplane"
        case .itCerts: return "checkmark.seal"
        case .languages: return "character.bubble"
        case .coding: return "chevron.left.forwardslash.chevron.right"
        case .history: return "clock.arrow.circlepath"
        case .musicTheory: return "music.note"
        case .chemistry: return "eyedropper"
        case .physics: return "gauge"
        case .biology: return "leaf"
        case .astronomy: return "star.circle"
        case .psychology: return "brain"
        case .economics: return "chart.line.uptrend.xyaxis"
        case .philosophy: return "character.book.closed"
        case .artHistory: return "paintbrush.pointed"
        case .literature: return "text.book.closed"
        case .grammar: return "textformat"
        case .anatomy: return "figure.stand"
        case .finance: return "dollarsign.circle"
        case .korean: return "globe.asia.australia"
        case .german: return "character.phonetic"
        case .italian: return "flag"
        case .arabic: return "circle.hexagongrid"
        case .midnight: return "moon.stars"
        case .forest: return "tree.fill"
        case .ocean: return "water.waves"
        case .sunset: return "sunset"
        case .kids: return "face.smiling"
        case .highContrast: return "circle.lefthalf.filled"
        }
    }

    // MARK: Appearance

    var accentColor: Color {
        switch self {
        case .standard: return .blue
        case .scienceOlympiad: return Color(red: 0.05, green: 0.50, blue: 0.45)
        case .mathOlympiad: return .indigo
        case .spellingBee: return .orange
        case .geographyBee: return .green
        case .quizBowl: return .purple
        case .debate: return .red
        case .chemistryOlympiad: return Color(red: 0.60, green: 0.20, blue: 0.65)
        case .physicsOlympiad: return .cyan
        case .biologyOlympiad: return Color(red: 0.20, green: 0.55, blue: 0.15)
        case .scienceBowl: return Color(red: 0.90, green: 0.55, blue: 0.10)
        case .mathcounts: return Color(red: 0.12, green: 0.65, blue: 0.62)
        case .historyBee: return Color(red: 0.85, green: 0.55, blue: 0.15)
        case .chessTactics: return .gray
        case .cybersecurity: return .blue
        case .satAct: return Color(red: 0.13, green: 0.27, blue: 0.55)
        case .apExams: return Color(red: 0.55, green: 0.15, blue: 0.27)
        case .greToefl: return Color(red: 0.28, green: 0.36, blue: 0.46)
        case .mcat: return Color(red: 0.00, green: 0.45, blue: 0.55)
        case .ielts: return Color(red: 0.90, green: 0.30, blue: 0.35)
        case .lsat: return Color(red: 0.35, green: 0.35, blue: 0.35)
        case .gmat: return .indigo
        case .asvab: return Color(red: 0.30, green: 0.45, blue: 0.20)
        case .realEstateExam: return Color(red: 0.65, green: 0.45, blue: 0.25)
        case .nclex: return Color(red: 0.75, green: 0.15, blue: 0.25)
        case .pilotFAA: return Color(red: 0.25, green: 0.60, blue: 0.85)
        case .itCerts: return Color(red: 0.80, green: 0.55, blue: 0.95)
        case .languages: return .pink
        case .coding: return Color(red: 0.10, green: 0.50, blue: 0.80)
        case .history: return .brown
        case .musicTheory: return Color(red: 0.55, green: 0.30, blue: 0.75)
        case .chemistry: return .teal
        case .physics: return Color(red: 0.40, green: 0.35, blue: 0.90)
        case .biology: return .green
        case .astronomy: return Color(red: 0.25, green: 0.25, blue: 0.65)
        case .psychology: return Color(red: 0.85, green: 0.45, blue: 0.65)
        case .economics: return Color(red: 0.05, green: 0.55, blue: 0.35)
        case .philosophy: return Color(red: 0.50, green: 0.45, blue: 0.55)
        case .artHistory: return Color(red: 0.70, green: 0.25, blue: 0.35)
        case .literature: return Color(red: 0.55, green: 0.35, blue: 0.25)
        case .grammar: return .mint
        case .anatomy: return Color(red: 0.80, green: 0.25, blue: 0.30)
        case .finance: return Color(red: 0.15, green: 0.55, blue: 0.35)
        case .korean: return Color(red: 0.85, green: 0.30, blue: 0.40)
        case .german: return Color(red: 0.80, green: 0.55, blue: 0.20)
        case .italian: return Color(red: 0.55, green: 0.20, blue: 0.50)
        case .arabic: return Color(red: 0.20, green: 0.60, blue: 0.40)
        case .midnight: return Color(red: 0.55, green: 0.60, blue: 1.00)
        case .forest: return Color(red: 0.10, green: 0.42, blue: 0.22)
        case .ocean: return Color(red: 0.00, green: 0.40, blue: 0.65)
        case .sunset: return Color(red: 0.95, green: 0.45, blue: 0.30)
        case .kids: return Color(red: 1.00, green: 0.55, blue: 0.10)
        case .highContrast: return Color(red: 0.00, green: 0.35, blue: 1.00)
        }
    }

    /// Forces a specific color scheme; nil follows the system setting.
    var preferredColorScheme: ColorScheme? {
        switch self {
        case .midnight: return .dark
        default: return nil
        }
    }

    /// Forces a larger type size; nil follows the user's Dynamic Type setting.
    var preferredDynamicTypeSize: DynamicTypeSize? {
        switch self {
        case .kids: return .xxxLarge
        default: return nil
        }
    }

    // MARK: Starter Content

    /// Whether this theme ships a themed starter deck.
    var hasStarterDeck: Bool {
        !starterCards.isEmpty
    }

    /// Localized name used for the theme's starter deck.
    var starterDeckName: String {
        displayName
    }

    /// Themed starter cards, each as (front, back). Empty for appearance-only themes.
    var starterCards: [(String, String)] {
        switch self {
        case .standard,
             .midnight, .forest, .ocean, .sunset, .kids, .highContrast:
            return []
        case .scienceOlympiad: return Self.scienceOlympiadCards
        case .mathOlympiad: return Self.mathOlympiadCards
        case .spellingBee: return Self.spellingBeeCards
        case .geographyBee: return Self.geographyBeeCards
        case .quizBowl: return Self.quizBowlCards
        case .debate: return Self.debateCards
        case .chemistryOlympiad: return Self.chemistryOlympiadCards
        case .physicsOlympiad: return Self.physicsOlympiadCards
        case .biologyOlympiad: return Self.biologyOlympiadCards
        case .scienceBowl: return Self.scienceBowlCards
        case .mathcounts: return Self.mathcountsCards
        case .historyBee: return Self.historyBeeCards
        case .chessTactics: return Self.chessTacticsCards
        case .cybersecurity: return Self.cybersecurityCards
        case .satAct: return Self.satActCards
        case .apExams: return Self.apExamsCards
        case .greToefl: return Self.greToeflCards
        case .mcat: return Self.mcatCards
        case .ielts: return Self.ieltsCards
        case .lsat: return Self.lsatCards
        case .gmat: return Self.gmatCards
        case .asvab: return Self.asvabCards
        case .realEstateExam: return Self.realEstateExamCards
        case .nclex: return Self.nclexCards
        case .pilotFAA: return Self.pilotFAACards
        case .itCerts: return Self.itCertsCards
        case .languages: return Self.languagesCards
        case .coding: return Self.codingCards
        case .history: return Self.historyCards
        case .musicTheory: return Self.musicTheoryCards
        case .chemistry: return Self.chemistryCards
        case .physics: return Self.physicsCards
        case .biology: return Self.biologyCards
        case .astronomy: return Self.astronomyCards
        case .psychology: return Self.psychologyCards
        case .economics: return Self.economicsCards
        case .philosophy: return Self.philosophyCards
        case .artHistory: return Self.artHistoryCards
        case .literature: return Self.literatureCards
        case .grammar: return Self.grammarCards
        case .anatomy: return Self.anatomyCards
        case .finance: return Self.financeCards
        case .korean: return Self.koreanCards
        case .german: return Self.germanCards
        case .italian: return Self.italianCards
        case .arabic: return Self.arabicCards
        }
    }

    // MARK: - Starter Card Content

    /// Science Olympiad: core science facts.
    static var scienceOlympiadCards: [(String, String)] {
        [
            ("What is the SI unit of force?", "Newton (N)"),
            ("What organelle produces most of a cell's ATP?", "Mitochondrion"),
            ("What is the pH of a neutral solution at 25°C?", "7"),
            ("What type of rock is formed from cooled magma or lava?", "Igneous rock"),
            ("State Newton's second law.", "F = ma"),
            ("What is the most abundant gas in Earth's atmosphere?", "Nitrogen (about 78%)"),
            ("What is the overall equation for photosynthesis?", "6CO₂ + 6H₂O + light → C₆H₁₂O₆ + 6O₂"),
            ("What scale measures mineral hardness?", "Mohs scale"),
            ("What is Avogadro's number?", "6.022 × 10²³ per mole"),
            ("What bond forms between water molecules?", "Hydrogen bond")
        ]
    }

    /// Math Olympiad / AMC: formulas, theorems and problem-solving patterns.
    static var mathOlympiadCards: [(String, String)] {
        [
            ("State the quadratic formula.", "x = (−b ± √(b² − 4ac)) / 2a"),
            ("State the Pythagorean theorem.", "a² + b² = c² for the legs a, b and hypotenuse c of a right triangle"),
            ("What is the sum of the interior angles of an n-sided polygon?", "(n − 2) × 180°"),
            ("What does the AM–GM inequality state?", "The arithmetic mean of positive reals is ≥ their geometric mean, with equality iff all terms are equal"),
            ("State Fermat's Little Theorem.", "If p is prime and gcd(a, p) = 1, then aᵖ⁻¹ ≡ 1 (mod p)"),
            ("What is the Pigeonhole Principle?", "If n items are placed into k boxes and n > k, at least one box contains two or more items"),
            ("What is the sum of the roots of ax² + bx + c = 0?", "−b/a (by Vieta's formulas)"),
            ("How many ways can you choose k items from n distinct items?", "C(n, k) = n! / (k!(n − k)!)"),
            ("What is the shoelace formula used for?", "Finding the area of a polygon from the coordinates of its vertices"),
            ("What is a telescoping series?", "A series whose terms cancel in pairs, leaving only the first and last terms")
        ]
    }

    /// Spelling Bee: word lists with definitions and etymology.
    static var spellingBeeCards: [(String, String)] {
        [
            ("Define and spell the art term for strong light-dark contrast.", "chiaroscuro — from Italian chiaro 'clear' + oscuro 'dark'"),
            ("Spell the word meaning 'excessive talkativeness'.", "logorrhea — from Greek logos 'word' + rrhoia 'flow'"),
            ("Which math word comes from Arabic al-jabr, 'reunion of broken parts'?", "algebra"),
            ("Spell the word for a memory aid such as 'Roy G. Biv'.", "mnemonic — the initial m is silent"),
            ("Define and spell a word that imitates a sound, like 'buzz'.", "onomatopoeia — from Greek onoma 'name' + poiein 'to make'"),
            ("Silicon or silicone: which one is in computer chips?", "silicon — the element; silicone is the synthetic polymer"),
            ("Spell both accepted plurals of 'vertex'.", "vertexes and vertices"),
            ("Which language gives us the word 'kindergarten'?", "German — literally 'children's garden'"),
            ("Define and spell the word for skillful sleight of hand.", "prestidigitation — from Latin praesto 'quick' + digitus 'finger'"),
            ("What is the most common vowel sound in unstressed English syllables called?", "the schwa (ə)")
        ]
    }

    /// Geography Bee: countries, capitals, rivers and landmarks.
    static var geographyBeeCards: [(String, String)] {
        [
            ("What is the capital of Australia?", "Canberra"),
            ("What is the longest river in South America?", "The Amazon"),
            ("Which strait separates Asia from North America?", "The Bering Strait"),
            ("What is the largest hot desert in the world?", "The Sahara"),
            ("Where is the deepest known point of the ocean?", "The Mariana Trench in the western Pacific"),
            ("Which mountain range divides Europe from Asia?", "The Urals"),
            ("What is the capital of Canada?", "Ottawa"),
            ("The Great Barrier Reef lies off the coast of which country?", "Australia"),
            ("Which two countries share the longest international border?", "Canada and the United States"),
            ("What is the smallest country in the world by area?", "Vatican City")
        ]
    }

    /// Quiz Bowl / Trivia: history, literature, arts and science.
    static var quizBowlCards: [(String, String)] {
        [
            ("Who wrote the epic poems the Iliad and the Odyssey?", "Homer"),
            ("Which artist painted 'The Persistence of Memory' with its melting clocks?", "Salvador Dalí"),
            ("Which two countries fought the Hundred Years' War?", "England and France"),
            ("What is the chemical symbol for gold?", "Au"),
            ("What poem is the final movement of Beethoven's Ninth Symphony based on?", "Schiller's 'Ode to Joy'"),
            ("Which novel opens with 'Call me Ishmael'?", "Moby-Dick by Herman Melville"),
            ("The Rosetta Stone helped scholars decipher which writing system?", "Egyptian hieroglyphics"),
            ("Which two city-states fought the Peloponnesian War?", "Athens and Sparta"),
            ("Who was the first President of the United States?", "George Washington"),
            ("What does DNA stand for?", "Deoxyribonucleic acid")
        ]
    }

    /// Debate: key arguments, logical fallacies and rhetorical terms.
    static var debateCards: [(String, String)] {
        [
            ("Define: ad hominem", "Attacking the opponent's character instead of their argument"),
            ("Define: straw man", "Misrepresenting an opponent's argument to make it easier to attack"),
            ("What are the three classical rhetorical appeals?", "Ethos (credibility), pathos (emotion), and logos (logic)"),
            ("Define: false dilemma", "Presenting only two options when more possibilities exist"),
            ("Define: slippery slope", "Claiming a small first step will inevitably lead to extreme consequences"),
            ("What is a red herring?", "An irrelevant point introduced to distract from the main issue"),
            ("What are the three parts of a syllogism?", "Major premise, minor premise, and conclusion"),
            ("Who holds the burden of proof in a debate?", "The side making the claim must support it with evidence"),
            ("What are the three parts of the Toulmin model of argument?", "Claim, grounds (evidence), and warrant"),
            ("Define: post hoc ergo propter hoc", "Assuming that because B followed A, A must have caused B")
        ]
    }

    /// Chemistry Olympiad: formulas, reactions and concepts.
    static var chemistryOlympiadCards: [(String, String)] {
        [
            ("State the ideal gas law.", "PV = nRT"),
            ("Define an acid according to Brønsted–Lowry.", "A proton (H⁺) donor"),
            ("What does Avogadro's law state?", "Equal volumes of gas at the same T and P contain equal numbers of molecules"),
            ("Balance: Fe + O₂ → Fe₂O₃", "4Fe + 3O₂ → 2Fe₂O₃"),
            ("What does a negative ΔG tell you about a reaction?", "It is spontaneous"),
            ("What is the pH of a 0.001 M HCl solution?", "3"),
            ("Which periodic table group contains the alkali metals?", "Group 1"),
            ("Compare the electron to the proton.", "Equal but opposite charge; the electron has about 1/1836 the mass"),
            ("Define electronegativity.", "An atom's tendency to attract shared electrons in a bond"),
            ("What is the molarity of 2 mol of solute in 0.5 L of solution?", "4 M")
        ]
    }

    /// Physics Olympiad: mechanics, E&M and problem-solving patterns.
    static var physicsOlympiadCards: [(String, String)] {
        [
            ("At what launch angle is a projectile's range maximized (flat ground)?", "45°"),
            ("State Ohm's law.", "V = IR"),
            ("What is the SI unit of magnetic flux?", "The weber (Wb)"),
            ("Give the kinetic energy formula.", "KE = ½mv²"),
            ("What does conservation of momentum state?", "The total momentum of an isolated system stays constant"),
            ("What speed keeps a satellite in a circular orbit of radius r?", "v = √(GM/r)"),
            ("What does Faraday's law say?", "A changing magnetic flux induces an EMF: ε = −dΦ/dt"),
            ("What is the escape speed from Earth's surface?", "About 11.2 km/s"),
            ("Give the period of a simple pendulum.", "T = 2π√(L/g)"),
            ("State the work-energy theorem.", "Net work done on an object equals its change in kinetic energy")
        ]
    }

    /// Biology Olympiad: cells, genetics and physiology.
    static var biologyOlympiadCards: [(String, String)] {
        [
            ("What are the four bases of DNA?", "Adenine, thymine, guanine, cytosine"),
            ("Which blood type is the universal red-cell donor?", "O negative"),
            ("What is the function of ribosomes?", "Protein synthesis"),
            ("In which phase of mitosis do chromosomes align at the center?", "Metaphase"),
            ("Which molecule carries amino acids to the ribosome?", "tRNA"),
            ("Where do the light reactions of photosynthesis occur?", "The thylakoid membrane"),
            ("What is a keystone species?", "A species whose impact on its ecosystem is disproportionately large"),
            ("In Hardy–Weinberg, what does p² + 2pq + q² equal?", "1"),
            ("What is chemiosmosis?", "ATP synthesis driven by a proton gradient across a membrane"),
            ("Which blood vessels carry oxygenated blood from the lungs?", "The pulmonary veins")
        ]
    }

    /// Science Bowl: rapid-recall science facts.
    static var scienceBowlCards: [(String, String)] {
        [
            ("What is the chemical symbol for iron?", "Fe"),
            ("How many bones are in the adult human body?", "206"),
            ("Which planet has the Great Red Spot?", "Jupiter"),
            ("What gas do plants absorb for photosynthesis?", "Carbon dioxide"),
            ("What is the speed of light in a vacuum?", "About 3.00 × 10⁸ m/s"),
            ("What force keeps planets in orbit?", "Gravity"),
            ("What is H₂O₂ commonly called?", "Hydrogen peroxide"),
            ("Which scientist proposed general relativity?", "Albert Einstein"),
            ("What is the hardest naturally occurring substance?", "Diamond"),
            ("Which blood cells fight infection?", "White blood cells (leukocytes)")
        ]
    }

    /// MATHCOUNTS: middle-school competition math.
    static var mathcountsCards: [(String, String)] {
        [
            ("What is the sum of the interior angles of a triangle?", "180°"),
            ("What is 15% of 80?", "12"),
            ("Simplify (x³)².", "x⁶"),
            ("What is the least common multiple of 12 and 18?", "36"),
            ("A square has diagonal 10. What is its area?", "50"),
            ("What is the mean of 4, 8, 15, 16, 23 and 42?", "18"),
            ("Solve: 3x − 7 = 14", "x = 7"),
            ("What is 2⁻³ written as a fraction?", "1/8"),
            ("Two fair dice: probability of rolling a sum of 7?", "6/36 = 1/6"),
            ("What is the next prime number after 31?", "37")
        ]
    }

    /// History Bee: dates, rulers and turning points.
    static var historyBeeCards: [(String, String)] {
        [
            ("Who was the first Emperor of Rome?", "Augustus"),
            ("In what year did the Battle of Hastings take place?", "1066"),
            ("Who wrote the Ninety-five Theses in 1517?", "Martin Luther"),
            ("Which dynasty built the most famous sections of the Great Wall?", "The Ming dynasty"),
            ("Who founded the Mongol Empire?", "Genghis Khan"),
            ("In what year did the Titanic sink?", "1912"),
            ("Who is Egypt's famous boy-pharaoh?", "Tutankhamun"),
            ("Which empire fell in 1453?", "The Byzantine Empire"),
            ("Which document begins 'We the People'?", "The United States Constitution"),
            ("What was the Silk Road?", "A trade network linking China with the Middle East and Europe")
        ]
    }

    /// Chess Tactics: openings, tactics and rules.
    static var chessTacticsCards: [(String, String)] {
        [
            ("What is a fork?", "One piece attacking two or more enemy pieces at once"),
            ("What does 'en passant' allow?", "Capturing an enemy pawn that advanced two squares as if it had moved one"),
            ("What is a pin?", "A piece that cannot move without exposing a more valuable piece behind it"),
            ("In castling, how many squares does the king move?", "Two, toward the rook"),
            ("A knight is conventionally worth how many pawns?", "Three"),
            ("What is a smothered mate?", "Checkmate by a knight when the king is blocked by its own pieces"),
            ("Which opening starts 1. e4 e5 2. Nf3 Nc6 3. Bb5?", "The Ruy López"),
            ("What is zugzwang?", "A position where any move makes things worse"),
            ("Which piece always stays on squares of one color?", "The bishop"),
            ("What is the shortest possible checkmate called?", "Fool's mate")
        ]
    }

    /// Cybersecurity: threats, defenses and best practices.
    static var cybersecurityCards: [(String, String)] {
        [
            ("What does two-factor authentication add?", "A second, different proof of identity beyond the password"),
            ("What is phishing?", "Fraudulent messages that trick users into revealing data or clicking bad links"),
            ("What is a zero-day vulnerability?", "A flaw with no available patch, exploitable from day one"),
            ("What does TLS provide?", "Encrypted, authenticated communication over a network"),
            ("What is password salting?", "Adding random data to a password before hashing it"),
            ("What is a SQL injection?", "Malicious SQL entered via input fields to manipulate a database"),
            ("Name the CIA triad.", "Confidentiality, Integrity, Availability"),
            ("What is a VPN's core function?", "An encrypted tunnel across an untrusted network"),
            ("State the principle of least privilege.", "Give each user or process only the access it needs"),
            ("What is ransomware?", "Malware that encrypts data and demands payment")
        ]
    }

    /// SAT / ACT: vocabulary and math formulas.
    static var satActCards: [(String, String)] {
        [
            ("SAT vocab: ephemeral", "Lasting for a very short time"),
            ("SAT vocab: ubiquitous", "Present or found everywhere"),
            ("SAT vocab: ambivalent", "Having mixed or contradictory feelings about something"),
            ("SAT vocab: candid", "Truthful and straightforward"),
            ("State the slope-intercept form of a line.", "y = mx + b"),
            ("Factor a² − b².", "(a + b)(a − b) — the difference of squares"),
            ("What is the most common Pythagorean triple?", "3-4-5"),
            ("SAT vocab: superfluous", "Unnecessary; more than what is needed"),
            ("What is the equation of a circle centered at (h, k) with radius r?", "(x − h)² + (y − k)² = r²"),
            ("SAT vocab: meticulous", "Showing great attention to detail")
        ]
    }

    /// AP Exams: AP Biology, AP Chemistry, AP US History.
    static var apExamsCards: [(String, String)] {
        [
            ("AP Bio: What is the main purpose of mitosis?", "Producing two genetically identical daughter cells for growth and repair"),
            ("AP Bio: What does meiosis produce?", "Four genetically unique haploid gametes"),
            ("AP Chem: State the ideal gas law.", "PV = nRT"),
            ("AP Chem: What is a Lewis acid?", "An electron pair acceptor"),
            ("APUSH: What did the Louisiana Purchase accomplish?", "The U.S. bought ~828,000 sq mi from France in 1803, roughly doubling its size"),
            ("APUSH: What principle did Marbury v. Madison (1803) establish?", "Judicial review"),
            ("AP Bio: Which organelle synthesizes proteins?", "The ribosome"),
            ("AP Chem: What does pH measure?", "−log[H⁺] — the acidity of a solution"),
            ("APUSH: What was the Missouri Compromise of 1820?", "Missouri entered as a slave state, Maine as free, and slavery was banned north of 36°30′ in the Louisiana Territory"),
            ("AP Bio: What is the function of the cell membrane?", "A selectively permeable barrier controlling what enters and leaves the cell")
        ]
    }

    /// GRE / TOEFL: advanced vocabulary.
    static var greToeflCards: [(String, String)] {
        [
            ("GRE: esoteric", "Understood by only a small, specialized group"),
            ("GRE: garrulous", "Excessively talkative about trivial matters"),
            ("GRE: reticent", "Reluctant to reveal one's thoughts or feelings"),
            ("GRE: obfuscate", "To deliberately make something unclear or confusing"),
            ("GRE: laconic", "Using very few words"),
            ("GRE: magnanimity", "Generosity or forgiveness, especially toward a rival"),
            ("GRE: pragmatic", "Dealing with things practically rather than theoretically"),
            ("GRE: lucid", "Clear and easy to understand"),
            ("GRE: intransigent", "Refusing to change one's views; stubborn"),
            ("GRE: equivocate", "To use ambiguous language to conceal the truth")
        ]
    }

    /// Medical / MCAT: anatomy, pharmacology and biochemistry.
    static var mcatCards: [(String, String)] {
        [
            ("What is the largest organ of the human body?", "The skin"),
            ("How many chambers does the human heart have?", "Four — two atria and two ventricles"),
            ("What is the longest bone in the human body?", "The femur"),
            ("In which cycle is acetyl-CoA oxidized to CO₂?", "The Krebs (citric acid) cycle"),
            ("What is the role of an enzyme in a reaction?", "Lowering the activation energy to speed up the reaction"),
            ("How does aspirin reduce pain and inflammation?", "By inhibiting cyclooxygenase (COX), reducing prostaglandin synthesis"),
            ("What is exchanged in the alveoli?", "Oxygen and carbon dioxide"),
            ("A reaction is spontaneous when ΔG is...", "Negative"),
            ("Which blood vessels carry blood away from the heart?", "Arteries"),
            ("Which neurotransmitter is deficient in Parkinson's disease?", "Dopamine")
        ]
    }

    /// IELTS: vocabulary, linking words and test basics.
    static var ieltsCards: [(String, String)] {
        [
            ("What is the IELTS band score range?", "0 to 9 (in 0.5 steps)"),
            ("IELTS synonym for 'important'", "crucial / vital"),
            ("IELTS synonym for 'increase'", "rise, surge, climb"),
            ("IELTS synonym for 'decrease'", "decline, drop, fall"),
            ("Linking words for contrast", "however, nevertheless, on the other hand"),
            ("IELTS synonym for 'show'", "demonstrate, illustrate"),
            ("IELTS synonym for 'think'", "believe, consider, maintain"),
            ("IELTS synonym for 'get worse'", "deteriorate, worsen"),
            ("IELTS synonym for 'worldwide'", "global, universal"),
            ("IELTS synonym for 'a lot of'", "a considerable number of, numerous")
        ]
    }

    /// LSAT: logic, assumptions and question types.
    static var lsatCards: [(String, String)] {
        [
            ("What is a necessary assumption?", "Something the argument must accept in order to stand"),
            ("What is a sufficient assumption?", "One that, if true, guarantees the conclusion"),
            ("What is the contrapositive of 'If A then B'?", "If not B, then not A"),
            ("What is the flaw in 'correlation proves causation'?", "Two things occurring together doesn't show that one caused the other"),
            ("In logic games, what is a 'fixed' entity?", "One assigned to a definite position from a clue"),
            ("Why is an argument by analogy vulnerable?", "Relevant differences between the cases may break the comparison"),
            ("What do Main Point questions ask for?", "The conclusion of the argument"),
            ("In LSAT logic, what does 'some' mean?", "At least one"),
            ("Describe the straw man flaw.", "Misrepresenting an opponent's view, then attacking the distortion"),
            ("What do Principle questions ask you to find?", "The rule that justifies the reasoning in the stimulus")
        ]
    }

    /// GMAT: quant, data sufficiency and critical reasoning.
    static var gmatCards: [(String, String)] {
        [
            ("If x > 0, when is x² > x?", "Only when x > 1"),
            ("Data Sufficiency: what are the five fixed answer choices?", "A: (1) alone; B: (2) alone; C: together; D: each alone; E: both insufficient"),
            ("What is 0.2% of 500?", "1"),
            ("GMAT Critical Reasoning: what is an assumption?", "An unstated premise the argument depends on"),
            ("At 60 mph, how long does 90 miles take?", "1.5 hours"),
            ("If 3ˣ = 81, what is x?", "4"),
            ("GMAT vocab: mitigate", "To make less severe"),
            ("A circle has circumference 10π. What is its area?", "25π"),
            ("GMAT vocab: assert", "To state confidently"),
            ("What is the median of 3, 7, 9 and 15?", "8")
        ]
    }

    /// ASVAB: math, mechanical and general science.
    static var asvabCards: [(String, String)] {
        [
            ("What is 25% of 200?", "50"),
            ("Mechanical: where does a lever's advantage come from?", "Torque balance — force × distance from the fulcrum"),
            ("What does Ohm's law state?", "V = IR"),
            ("Which simple machine is a ramp?", "An inclined plane"),
            ("Electrical current is measured in what unit?", "Amperes"),
            ("In a gasoline engine, what ignites the air-fuel mixture?", "The spark plug"),
            ("State Newton's first law.", "An object keeps constant velocity unless acted on by a net force"),
            ("Which way do standard (right-hand) bolts tighten?", "Clockwise"),
            ("Two meshed gears: the second gear turns...", "In the opposite direction"),
            ("Word Knowledge: frugal", "Thrifty; careful with money")
        ]
    }

    /// Real Estate Exam: terms, contracts and practice.
    static var realEstateExamCards: [(String, String)] {
        [
            ("What does 'escrow' mean?", "A neutral third party holds funds/documents until conditions are met"),
            ("Define easement.", "The right to use another person's land for a specific purpose"),
            ("What is a title search?", "Examining public records for ownership history and claims"),
            ("Name the four elements of value.", "Utility, scarcity, demand, transferability"),
            ("What is a lien?", "A legal claim against property as security for a debt"),
            ("What does amortization describe?", "Paying off a loan with scheduled principal-and-interest payments"),
            ("What is a comparative market analysis (CMA)?", "Estimating a home's value from comparable recent sales"),
            ("Fiduciary duty requires acting in whose best interest?", "The client's"),
            ("What is a deed?", "The legal document transferring property ownership"),
            ("What does an 'as-is' sale mean?", "The seller offers no repairs or guarantees about condition")
        ]
    }

    /// NCLEX Nursing: vitals, abbreviations and fundamentals.
    static var nclexCards: [(String, String)] {
        [
            ("Normal adult resting heart rate", "60–100 beats per minute"),
            ("Normal adult respiratory rate", "12–20 breaths per minute"),
            ("What does NPO mean?", "Nothing by mouth"),
            ("What does the acronym RICE stand for?", "Rest, Ice, Compression, Elevation"),
            ("Normal fasting blood glucose", "70–99 mg/dL"),
            ("What is thrombocytopenia?", "A low platelet count"),
            ("Common signs of hypoglycemia", "Shakiness, sweating, confusion, hunger"),
            ("What does PRN mean?", "As needed"),
            ("What is the first step of the nursing process?", "Assessment"),
            ("What is the therapeutic range concept for medications?", "The concentration range between minimum effective and toxic levels")
        ]
    }

    /// Pilot Exam (FAA): regulations, airspace and aerodynamics.
    static var pilotFAACards: [(String, String)] {
        [
            ("Above 3,000 ft AGL, what VFR cruising altitudes fit easterly headings?", "Odd thousands + 500 ft (e.g., 3,500; 5,500)"),
            ("What does VOR stand for?", "VHF Omnirange — a ground navigation aid"),
            ("What does Class B airspace typically require?", "An ATC clearance before entry"),
            ("What is density altitude?", "Pressure altitude corrected for nonstandard temperature"),
            ("How long is a nautical mile in feet?", "About 6,076 ft (≈ 1.15 statute miles)"),
            ("What does the attitude indicator show?", "The aircraft's pitch and bank relative to the horizon"),
            ("What should you do to the mixture as altitude increases?", "Lean it — less air density means less fuel needed"),
            ("What is a squawk code?", "A 4-digit transponder code for ATC identification"),
            ("A stall happens when the aircraft...", "Exceeds the critical angle of attack"),
            ("What causes a magnetic compass to lag in a turn?", "Magnetic dip")
        ]
    }

    /// IT Certifications: networking, hardware and cloud basics.
    static var itCertsCards: [(String, String)] {
        [
            ("What does an address like 192.168.1.5 indicate?", "A private IP address (not routable on the internet)"),
            ("What port does HTTPS use?", "443"),
            ("What does RAM stand for?", "Random Access Memory"),
            ("Which protocol resolves domain names to IP addresses?", "DNS — Domain Name System"),
            ("What is the subnet mask of a /24 network?", "255.255.255.0"),
            ("What does the BIOS do?", "Firmware that initializes hardware during boot"),
            ("AWS: what is EC2?", "Resizable virtual servers in the cloud"),
            ("What is virtualization?", "Running multiple virtual machines on one physical host"),
            ("AWS: what does S3 provide?", "Object storage"),
            ("What is a firewall?", "A device or software that filters network traffic by rules")
        ]
    }

    /// Languages: Spanish, Chinese (HSK), Japanese (JLPT), French.
    static var languagesCards: [(String, String)] {
        [
            ("Spanish: 'Good morning'", "Buenos días"),
            ("Spanish: 'Where is the library?'", "¿Dónde está la biblioteca?"),
            ("Chinese (HSK 1): 你好", "Hello (nǐ hǎo)"),
            ("Chinese (HSK 1): 谢谢", "Thank you (xiè xie)"),
            ("Japanese (JLPT N5): こんにちは", "Hello (konnichiwa)"),
            ("Japanese (JLPT N5): ありがとう", "Thank you (arigatō)"),
            ("French: 'Good evening'", "Bonsoir"),
            ("French: 'How much does this cost?'", "Combien ça coûte ?"),
            ("Spanish: 'I would like a coffee, please.'", "Quisiera un café, por favor."),
            ("Chinese (HSK 1): 我爱你", "I love you (wǒ ài nǐ)")
        ]
    }

    /// Coding: syntax, algorithms and design patterns.
    static var codingCards: [(String, String)] {
        [
            ("What is the time complexity of binary search?", "O(log n) on a sorted array"),
            ("Which data structure is LIFO?", "A stack"),
            ("Which data structure is FIFO?", "A queue"),
            ("Which design pattern ensures a class has only one instance?", "Singleton"),
            ("Which design pattern defines a one-to-many dependency between objects?", "Observer"),
            ("In Big-O, what is the cost of accessing an array element by index?", "O(1)"),
            ("What is recursion?", "A function that calls itself, with a base case to stop"),
            ("What does HTTP status 404 mean?", "Resource not found"),
            ("In Git, how do you create and switch to a new branch?", "git switch -c branch-name (or git checkout -b branch-name)"),
            ("What is the average lookup complexity of a hash table?", "O(1)")
        ]
    }

    /// History: dates, events and figures.
    static var historyCards: [(String, String)] {
        [
            ("In what year did World War I begin?", "1914"),
            ("What event marked the start of the French Revolution in 1789?", "The storming of the Bastille"),
            ("In what year did the Berlin Wall fall?", "1989"),
            ("Who was the first person to walk on the Moon, and in what year?", "Neil Armstrong, 1969"),
            ("What document did King John of England seal in 1215?", "The Magna Carta"),
            ("In what year did Columbus first reach the Americas?", "1492"),
            ("Who developed the printing press in Europe around 1440?", "Johannes Gutenberg"),
            ("Which two ancient powers fought the Punic Wars?", "Rome and Carthage"),
            ("When did the Soviet Union dissolve?", "1991"),
            ("Who was the first female Nobel laureate?", "Marie Curie — Physics, 1903")
        ]
    }

    /// Music Theory: scales, chords and notation.
    static var musicTheoryCards: [(String, String)] {
        [
            ("How many semitones are in an octave?", "12"),
            ("What is the interval from C up to G?", "A perfect fifth"),
            ("What does the dynamic marking 'forte' (f) mean?", "Loud"),
            ("What notes make up a C major triad?", "C – E – G"),
            ("Which major key has no sharps or flats?", "C major"),
            ("What is the relative minor of C major?", "A minor"),
            ("Which clef is also known as the G clef?", "The treble clef"),
            ("What does 'largo' mean as a tempo marking?", "Very slow and broad"),
            ("What is a cadence?", "A chord progression that concludes a phrase or piece"),
            ("In 6/8 time, how many beats per measure and on what note value?", "Two compound beats on dotted-quarter notes")
        ]
    }

    /// Chemistry: elements, bonds and reactions.
    static var chemistryCards: [(String, String)] {
        [
            ("What does the atomic number count?", "The number of protons"),
            ("What type of bond joins H to O in water?", "Polar covalent"),
            ("What is a mole in chemistry?", "6.022 × 10²³ particles of a substance"),
            ("A pH below 7 means the solution is...", "Acidic"),
            ("What is an isotope?", "An atom of the same element with a different number of neutrons"),
            ("What is the chemical symbol for sodium?", "Na"),
            ("What is an ionic bond?", "A transfer of electrons from a metal to a nonmetal"),
            ("How does electronegativity trend on the periodic table?", "It increases up and to the right, toward fluorine"),
            ("What does a catalyst do?", "Speeds up a reaction without being consumed"),
            ("What is dry ice?", "Solid carbon dioxide")
        ]
    }

    /// Physics: units, laws and motion.
    static var physicsCards: [(String, String)] {
        [
            ("What is the SI unit of energy?", "The joule"),
            ("What is g on Earth's surface?", "About 9.8 m/s²"),
            ("State Newton's third law.", "For every action there is an equal and opposite reaction"),
            ("What is the unit of power?", "The watt (joules per second)"),
            ("How is momentum defined?", "p = mv"),
            ("Frequency × wavelength equals what?", "Wave speed: v = fλ"),
            ("What is refraction?", "The bending of a wave as it passes between media"),
            ("What does Coulomb's law describe?", "The force between electric charges"),
            ("What is terminal velocity?", "Constant speed reached when drag equals weight"),
            ("State the first law of thermodynamics.", "Energy is conserved: ΔU = Q − W")
        ]
    }

    /// Biology: cells, genetics and life processes.
    static var biologyCards: [(String, String)] {
        [
            ("According to cell theory, all living things are made of what?", "Cells"),
            ("What is osmosis?", "Water moving across a semipermeable membrane toward higher solute concentration"),
            ("What is an enzyme?", "A protein that catalyzes biological reactions"),
            ("What is the shape of DNA?", "A double helix"),
            ("What is an autotroph?", "An organism that makes its own food, e.g. by photosynthesis"),
            ("What is homeostasis?", "Maintaining stable internal conditions"),
            ("What is an allele?", "A version of a gene"),
            ("What does an ecosystem include?", "A community of organisms plus their environment"),
            ("Which organelle packages and ships proteins?", "The Golgi apparatus"),
            ("What is fermentation?", "Extracting energy without oxygen, producing lactate or alcohol")
        ]
    }

    /// Astronomy: planets, stars and the universe.
    static var astronomyCards: [(String, String)] {
        [
            ("Which planet is closest to the Sun?", "Mercury"),
            ("What is a light-year?", "The distance light travels in one year (≈ 9.46 × 10¹² km)"),
            ("Which planet is famous for its ring system?", "Saturn"),
            ("What is our galaxy called?", "The Milky Way"),
            ("What is a supernova?", "The explosive death of a massive star"),
            ("What powers the Sun?", "Nuclear fusion of hydrogen into helium"),
            ("What is a red giant?", "A late-stage star with an expanded, cooler outer envelope"),
            ("What is the Big Bang?", "The origin event of our expanding universe, ~13.8 billion years ago"),
            ("What is a black hole?", "A region where gravity is so strong light cannot escape"),
            ("What unseen mass shapes galaxy rotation curves?", "Dark matter")
        ]
    }

    /// Psychology: theories, thinkers and terms.
    static var psychologyCards: [(String, String)] {
        [
            ("What is classical conditioning?", "Learning by association — Pavlov's dogs"),
            ("What is operant conditioning?", "Learning from consequences of behavior — Skinner"),
            ("What is confirmation bias?", "Favoring information that confirms existing beliefs"),
            ("What is the DSM-5?", "The standard manual for diagnosing mental disorders"),
            ("What is a neuron?", "An electrically excitable cell that processes information"),
            ("What did Milgram's experiments study?", "Obedience to authority"),
            ("What is neuroplasticity?", "The brain's ability to reorganize and form new connections"),
            ("What is intrinsic motivation?", "Doing something for its own satisfaction, not reward"),
            ("What is the bystander effect?", "People are less likely to help when others are present"),
            ("What did the Stanford prison experiment probe?", "How social roles and situations shape behavior")
        ]
    }

    /// Economics: micro, macro and key concepts.
    static var economicsCards: [(String, String)] {
        [
            ("What is opportunity cost?", "The value of the next-best alternative given up"),
            ("What does GDP measure?", "The total value of goods and services produced in an economy"),
            ("What is inflation?", "A sustained rise in the general price level"),
            ("What is market equilibrium?", "The price where quantity supplied equals quantity demanded"),
            ("What is a monopoly?", "A single seller with no close substitutes"),
            ("What is fiscal policy?", "Government spending and taxation decisions"),
            ("What is monetary policy?", "Central bank control of money supply and interest rates"),
            ("What is comparative advantage?", "Producing at a lower opportunity cost than others"),
            ("What is a common rule-of-thumb definition of a recession?", "Two consecutive quarters of falling GDP"),
            ("What is price elasticity?", "How sensitively quantity demanded responds to price changes")
        ]
    }

    /// Philosophy: thinkers, schools and questions.
    static var philosophyCards: [(String, String)] {
        [
            ("Who said 'I think, therefore I am'?", "René Descartes"),
            ("What is empiricism?", "The view that knowledge comes from sensory experience"),
            ("What is Kant's categorical imperative?", "Act only on maxims you could will to be universal laws"),
            ("Who wrote 'The Republic'?", "Plato"),
            ("What is utilitarianism?", "The view that right actions maximize overall happiness"),
            ("What is Occam's razor?", "Prefer the simpler explanation when rivals fit equally"),
            ("What is existentialism?", "A focus on individual freedom, choice and meaning — e.g. Sartre"),
            ("Who taught by asking probing questions?", "Socrates — the Socratic method"),
            ("What is determinism?", "The view that all events are fixed by prior causes"),
            ("What is Stoicism's core teaching?", "Virtue and calm acceptance of what is beyond our control")
        ]
    }

    /// Art History: artists, works and movements.
    static var artHistoryCards: [(String, String)] {
        [
            ("Who painted the Mona Lisa?", "Leonardo da Vinci"),
            ("What is Impressionism?", "A late-1800s movement capturing light and fleeting moments — Monet"),
            ("Who painted the Sistine Chapel ceiling?", "Michelangelo"),
            ("What is Cubism?", "A style fragmenting subjects into geometric planes — Picasso, Braque"),
            ("Who sculpted the marble 'David' of 1504?", "Michelangelo"),
            ("Which movement did Salvador Dalí belong to?", "Surrealism"),
            ("Who painted 'The Starry Night'?", "Vincent van Gogh"),
            ("What was the Renaissance?", "The revival of classical art and learning in Europe, 14th–17th centuries"),
            ("Which Pop Artist painted Campbell's soup cans?", "Andy Warhol"),
            ("What is chiaroscuro?", "The use of strong contrasts of light and dark")
        ]
    }

    /// Literature: authors, works and devices.
    static var literatureCards: [(String, String)] {
        [
            ("Who wrote '1984'?", "George Orwell"),
            ("Who wrote 'Pride and Prejudice'?", "Jane Austen"),
            ("Who wrote 'The Great Gatsby'?", "F. Scott Fitzgerald"),
            ("Who wrote 'To Kill a Mockingbird'?", "Harper Lee"),
            ("What is an unreliable narrator?", "A narrator whose account the reader cannot trust"),
            ("Who wrote 'One Hundred Years of Solitude'?", "Gabriel García Márquez"),
            ("What is a metaphor?", "A direct comparison without 'like' or 'as'"),
            ("Who created Sherlock Holmes?", "Arthur Conan Doyle"),
            ("What is iambic pentameter?", "A ten-syllable line alternating unstressed and stressed beats"),
            ("Who wrote 'The Tale of Genji'?", "Murasaki Shikibu")
        ]
    }

    /// Grammar & Style: rules and common confusions.
    static var grammarCards: [(String, String)] {
        [
            ("What does 'it's' mean?", "It is or it has"),
            ("What is the Oxford comma?", "The comma before the final 'and' in a list"),
            ("What does 'you're' mean?", "You are"),
            ("What is a dangling modifier?", "A descriptive phrase that attaches to the wrong subject"),
            ("Affect vs effect (usual usage)?", "'Affect' is usually the verb; 'effect' is usually the noun"),
            ("What is the passive voice?", "The subject receives the action — 'The ball was thrown'"),
            ("When should you use 'fewer'?", "For countable items — fewer coins, less water"),
            ("What joins two related independent clauses?", "A semicolon"),
            ("What is a comma splice?", "Two independent clauses joined with only a comma"),
            ("When do you use 'whom'?", "When it acts as the object of a verb or preposition")
        ]
    }

    /// Anatomy: bones, organs and systems.
    static var anatomyCards: [(String, String)] {
        [
            ("How many cervical vertebrae are there?", "Seven (C1–C7)"),
            ("Which circuit sends blood to the lungs?", "The pulmonary circuit"),
            ("What protects the lungs and heart?", "The thoracic cage — ribs and sternum"),
            ("What makes up the central nervous system?", "The brain and spinal cord"),
            ("Which muscle is the primary breathing muscle?", "The diaphragm"),
            ("How many pairs of cranial nerves are there?", "Twelve"),
            ("What is the functional unit of the kidney?", "The nephron"),
            ("Which hormone lowers blood sugar?", "Insulin"),
            ("What connects muscle to bone?", "A tendon"),
            ("What type of joint is the shoulder?", "A ball-and-socket joint")
        ]
    }

    /// Finance & Investing: terms every investor should know.
    static var financeCards: [(String, String)] {
        [
            ("What is compound interest?", "Earning interest on previously earned interest"),
            ("What is a stock?", "A share of ownership in a company"),
            ("What is a bond?", "A loan to a company or government that pays interest"),
            ("What is diversification?", "Spreading investments to reduce risk"),
            ("What does APR stand for?", "Annual Percentage Rate"),
            ("What is an index fund?", "A fund that tracks a market index such as the S&P 500"),
            ("What is a credit score used for?", "Assessing how likely a borrower is to repay"),
            ("What is an ETF?", "An exchange-traded fund — a basket of assets traded like a stock"),
            ("What is the Rule of 72?", "Doubling time ≈ 72 divided by the annual return rate"),
            ("What is a bear market?", "A broad decline, conventionally −20% or more")
        ]
    }

    /// Korean: everyday words and phrases.
    static var koreanCards: [(String, String)] {
        [
            ("Korean: 안녕하세요", "Hello (annyeonghaseyo)"),
            ("Korean: 감사합니다", "Thank you (gamsahamnida)"),
            ("Korean: 하나", "One (hana)"),
            ("Korean: 물", "Water (mul)"),
            ("Korean: 사랑해", "I love you (saranghae)"),
            ("Korean: 학교", "School (hakgyo)"),
            ("Korean: 네 / 아니요", "Yes / No (ne / aniyo)"),
            ("Korean: 얼마예요?", "How much is it? (eolmayeyo)"),
            ("Korean: 친구", "Friend (chingu)"),
            ("Korean: 좋아해요", "I like it (joahaeyo)")
        ]
    }

    /// German: everyday words and phrases.
    static var germanCards: [(String, String)] {
        [
            ("German: Hallo", "Hello"),
            ("German: Danke", "Thank you"),
            ("German: Wo ist der Bahnhof?", "Where is the train station?"),
            ("German: eins, zwei, drei", "One, two, three"),
            ("German: Ich liebe dich", "I love you"),
            ("German: Wasser", "Water"),
            ("German: Schule", "School"),
            ("German: Ja / Nein", "Yes / No"),
            ("German: Wie viel kostet das?", "How much does that cost?"),
            ("German: Guten Morgen", "Good morning")
        ]
    }

    /// Italian: everyday words and phrases.
    static var italianCards: [(String, String)] {
        [
            ("Italian: Ciao", "Hello / Goodbye"),
            ("Italian: Grazie", "Thank you"),
            ("Italian: Dov'è la stazione?", "Where is the station?"),
            ("Italian: uno, due, tre", "One, two, three"),
            ("Italian: Ti amo", "I love you"),
            ("Italian: Acqua", "Water"),
            ("Italian: Scuola", "School"),
            ("Italian: Sì / No", "Yes / No"),
            ("Italian: Quanto costa?", "How much does it cost?"),
            ("Italian: Buongiorno", "Good morning")
        ]
    }

    /// Arabic: everyday words and phrases.
    static var arabicCards: [(String, String)] {
        [
            ("Arabic: مرحبا (marhaban)", "Hello"),
            ("Arabic: شكرا (shukran)", "Thank you"),
            ("Arabic: نعم / لا (naʿam / lā)", "Yes / No"),
            ("Arabic: ماء (māʾ)", "Water"),
            ("Arabic: مدرسة (madrasa)", "School"),
            ("Arabic: أحبك (uḥibbuka)", "I love you"),
            ("Arabic: واحد، اثنان، ثلاثة", "One, two, three (wāḥid, ithnān, thalātha)"),
            ("Arabic: بكم؟ (bikam?)", "How much?"),
            ("Arabic: صديق (ṣadīq)", "Friend"),
            ("Arabic: صباح الخير (ṣabāḥ al-khayr)", "Good morning")
        ]
    }
}
