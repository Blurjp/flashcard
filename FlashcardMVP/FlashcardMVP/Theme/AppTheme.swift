//
//  AppTheme.swift
//  FlashcardMVP
//
//  Selectable app themes (accent color + themed starter content)
//

import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case standard
    case scienceOlympiad

    static let storageKey = "appTheme"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .standard: return NSLocalizedString("Standard", comment: "")
        case .scienceOlympiad: return NSLocalizedString("Science Olympiad", comment: "")
        }
    }

    var iconName: String {
        switch self {
        case .standard: return "paintpalette"
        case .scienceOlympiad: return "atom"
        }
    }

    var accentColor: Color {
        switch self {
        case .standard: return .blue
        case .scienceOlympiad: return Color(red: 0.05, green: 0.50, blue: 0.45)
        }
    }

    /// Topics used for the Science Olympiad starter deck, each as (front, back).
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
}
