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
}

// MARK: - App Theme

enum AppTheme: String, CaseIterable, Identifiable {
    // Academic Competitions
    case standard
    case scienceOlympiad
    case mathOlympiad
    case spellingBee
    case geographyBee
    case quizBowl
    case debate

    // Test Prep
    case satAct
    case apExams
    case greToefl
    case mcat

    // Subjects
    case languages
    case coding
    case history
    case musicTheory

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
        case .standard, .scienceOlympiad, .mathOlympiad, .spellingBee, .geographyBee, .quizBowl, .debate:
            return .academicCompetitions
        case .satAct, .apExams, .greToefl, .mcat:
            return .testPrep
        case .languages, .coding, .history, .musicTheory:
            return .subjects
        case .midnight, .forest, .ocean, .sunset, .kids, .highContrast:
            return .appearance
        }
    }

    /// All themes that belong to the given category, in display order.
    static func themes(in category: ThemeCategory) -> [AppTheme] {
        allCases.filter { $0.category == category }
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
        case .satAct: return NSLocalizedString("SAT / ACT", comment: "")
        case .apExams: return NSLocalizedString("AP Exams", comment: "")
        case .greToefl: return NSLocalizedString("GRE / TOEFL", comment: "")
        case .mcat: return NSLocalizedString("Medical / MCAT", comment: "")
        case .languages: return NSLocalizedString("Languages", comment: "")
        case .coding: return NSLocalizedString("Coding", comment: "")
        case .history: return NSLocalizedString("History", comment: "")
        case .musicTheory: return NSLocalizedString("Music Theory", comment: "")
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
        case .satAct: return "pencil.and.outline"
        case .apExams: return "graduationcap"
        case .greToefl: return "book.closed"
        case .mcat: return "cross.case"
        case .languages: return "character.bubble"
        case .coding: return "chevron.left.forwardslash.chevron.right"
        case .history: return "clock.arrow.circlepath"
        case .musicTheory: return "music.note"
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
        case .satAct: return Color(red: 0.13, green: 0.27, blue: 0.55)
        case .apExams: return Color(red: 0.55, green: 0.15, blue: 0.27)
        case .greToefl: return Color(red: 0.28, green: 0.36, blue: 0.46)
        case .mcat: return Color(red: 0.00, green: 0.45, blue: 0.55)
        case .languages: return .pink
        case .coding: return Color(red: 0.10, green: 0.50, blue: 0.80)
        case .history: return .brown
        case .musicTheory: return Color(red: 0.55, green: 0.30, blue: 0.75)
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
        case .scienceOlympiad:
            return Self.scienceOlympiadCards
        case .mathOlympiad:
            return Self.mathOlympiadCards
        case .spellingBee:
            return Self.spellingBeeCards
        case .geographyBee:
            return Self.geographyBeeCards
        case .quizBowl:
            return Self.quizBowlCards
        case .debate:
            return Self.debateCards
        case .satAct:
            return Self.satActCards
        case .apExams:
            return Self.apExamsCards
        case .greToefl:
            return Self.greToeflCards
        case .mcat:
            return Self.mcatCards
        case .languages:
            return Self.languagesCards
        case .coding:
            return Self.codingCards
        case .history:
            return Self.historyCards
        case .musicTheory:
            return Self.musicTheoryCards
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
}
