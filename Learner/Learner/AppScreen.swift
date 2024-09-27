import SwiftUI

enum InteractionType {
    case viewer
    case quiz
    case quizInvert
}

enum AppScreen: Hashable, Equatable {
    
    case home
    case cardsViewer
    case settings
    case registration
    case profile
    case list
    case detail(category: CategoryModel, selectedInteraction: InteractionType)
    case categoryOption(category: CategoryModel)
    
    // Equatable conformance
    static func == (lhs: AppScreen, rhs: AppScreen) -> Bool {
        switch (lhs, rhs) {
        case (.home, .home),
             (.cardsViewer, .cardsViewer),
             (.settings, .settings),
             (.registration, .registration),
             (.profile, .profile),
             (.list, .list):
            return true
        case (.detail(let lhsCategory, let lhsInteraction), .detail(let rhsCategory, let rhsInteraction)):
            return lhsCategory == rhsCategory && lhsInteraction == rhsInteraction
        case (.categoryOption(let lhsCategory), .categoryOption(let rhsCategory)):
            return lhsCategory == rhsCategory
        default:
            return false
        }
    }
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        switch self {
        case .home:
            hasher.combine("home")
        case .cardsViewer:
            hasher.combine("cardsViewer")
        case .settings:
            hasher.combine("settings")
        case .registration:
            hasher.combine("registration")
        case .profile:
            hasher.combine("profile")
        case .list:
            hasher.combine("list")
        case .detail(let category, let selectedInteraction):
            hasher.combine("detail")
            hasher.combine(category)
            hasher.combine(selectedInteraction)
        case .categoryOption(let category):
            hasher.combine("categoryOption")
            hasher.combine(category)
        }
    }
}
