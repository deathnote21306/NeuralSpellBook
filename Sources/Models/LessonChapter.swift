import Foundation

public enum LessonChapter: Int, CaseIterable, Identifiable {
    case awakening
    case firstSpell
    case instability
    case backprop
    case manaControls
    case inspect
    case evolution

    public var id: Int { rawValue }

    public var title: String {
        switch self {
        case .awakening: return "The Awakening"
        case .firstSpell: return "The First Spell"
        case .instability: return "Instability"
        case .backprop: return "Backprop Ritual"
        case .manaControls: return "Mana Controls"
        case .inspect: return "Pause & Inspect"
        case .evolution: return "Evolution"
        }
    }

    public var subtitle: String {
        switch self {
        case .awakening: return "Intelligence is not born. It is trained."
        case .firstSpell: return "Forward pass"
        case .instability: return "Loss"
        case .backprop: return "Gradients and correction"
        case .manaControls: return "Hyperparameters"
        case .inspect: return "Glass-box insight"
        case .evolution: return "Closing chapter"
        }
    }

    public var objective: String {
        switch self {
        case .awakening:
            return "A network is constructed and trained, not summoned instantly."
        case .firstSpell:
            return "Predictions come from signals flowing forward through layers."
        case .instability:
            return "Loss measures how wrong the spell is."
        case .backprop:
            return "Gradients show how to correct each weight."
        case .manaControls:
            return "Learning rate, batch size, and regularization shape behavior."
        case .inspect:
            return "You can inspect internal values and reason about model behavior."
        case .evolution:
            return "Improvement comes from repetition guided by correction."
        }
    }

    public var actionTitle: String {
        switch self {
        case .awakening: return "Awaken the Network"
        case .firstSpell: return "Cast Prediction"
        case .instability: return "Why did it fail?"
        case .backprop: return "Perform Backprop Ritual"
        case .manaControls: return "Run Mana Experiment"
        case .inspect: return "Open Rune Inspector"
        case .evolution: return "Seal the Spellbook"
        }
    }

    public var indexDisplay: String {
        let chapterNumber = rawValue
        return chapterNumber == 0 ? "Prologue" : "Chapter \(chapterNumber)"
    }

    public var progress: Float {
        Float(rawValue) / Float(LessonChapter.allCases.count - 1)
    }

    public var next: LessonChapter? {
        LessonChapter(rawValue: rawValue + 1)
    }
}
