//
//  Scheduler.swift
//  FlashcardMVP
//
//  Spaced Repetition System (SM-2 inspired algorithm)
//

import Foundation

enum Rating: Int, CaseIterable {
    case again = 0
    case hard = 1
    case good = 2
    case easy = 3

    var title: String {
        switch self {
        case .again: return NSLocalizedString("Again", comment: "Rating button")
        case .hard: return NSLocalizedString("Hard", comment: "Rating button")
        case .good: return NSLocalizedString("Good", comment: "Rating button")
        case .easy: return NSLocalizedString("Easy", comment: "Rating button")
        }
    }

    var color: String {
        switch self {
        case .again: return "red"
        case .hard: return "orange"
        case .good: return "green"
        case .easy: return "blue"
        }
    }
}

struct SRSResult {
    let newEaseFactor: Double
    let newIntervalDays: Int
    let newRepetition: Int
    let newDueDate: Date
}

struct Scheduler {

    /// Calculate the next review schedule based on SM-2 algorithm
    /// - Parameters:
    ///   - now: Current timestamp
    ///   - repetition: Current repetition count
    ///   - intervalDays: Current interval in days
    ///   - easeFactor: Current ease factor (default starts at 2.5)
    ///   - rating: User's rating (Again/Hard/Good/Easy)
    /// - Returns: SRSResult with updated scheduling parameters
    static func schedule(
        now: Date = Date(),
        repetition: Int,
        intervalDays: Int,
        easeFactor: Double,
        rating: Rating
    ) -> SRSResult {

        var newRepetition = repetition
        var newIntervalDays = intervalDays
        var newEaseFactor = easeFactor

        // If rating is Again or Hard, reset repetition
        if rating.rawValue < 2 {
            newRepetition = 0
            newIntervalDays = 1
        } else {
            // Increment repetition
            newRepetition = repetition + 1

            // Calculate new interval
            switch newRepetition {
            case 1:
                newIntervalDays = 1
            case 2:
                newIntervalDays = 3
            default:
                newIntervalDays = Int(round(Double(intervalDays) * easeFactor))
            }
        }

        // Update ease factor based on SM-2 formula
        // EF' = EF + (0.1 - (3 - q) * (0.08 + (3 - q) * 0.02))
        // where q is the rating (0-3)
        let q = Double(rating.rawValue)
        let delta = 0.1 - (3.0 - q) * (0.08 + (3.0 - q) * 0.02)
        newEaseFactor = max(1.3, easeFactor + delta)

        // Calculate new due date
        let newDueDate = Calendar.current.date(
            byAdding: .day,
            value: newIntervalDays,
            to: now
        ) ?? now.addingTimeInterval(Double(newIntervalDays) * 86400)

        return SRSResult(
            newEaseFactor: newEaseFactor,
            newIntervalDays: newIntervalDays,
            newRepetition: newRepetition,
            newDueDate: newDueDate
        )
    }

    /// Calculate the projected next review date for a given rating (for preview)
    static func previewNextDueDate(
        from now: Date = Date(),
        repetition: Int,
        intervalDays: Int,
        easeFactor: Double,
        rating: Rating
    ) -> Date {
        let result = schedule(
            now: now,
            repetition: repetition,
            intervalDays: intervalDays,
            easeFactor: easeFactor,
            rating: rating
        )
        return result.newDueDate
    }
}
