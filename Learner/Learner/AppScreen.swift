import SwiftUI

enum AppScreen:Hashable,Equatable {
    static func == (lhs: AppScreen, rhs: AppScreen) -> Bool {
        switch (lhs, rhs) {
        case (.home, .home),
             (.cardsViewer, .cardsViewer),
             (.settings, .settings),
             (.registration, .registration),
             (.profile, .profile),
             (.list, .list):
            return true
        case (.detail(let lhsCard), .detail(let rhsCard)):
            return lhsCard == rhsCard
        default:
            return false
        }
    }
    
    case home
    case cardsViewer
    case settings
    case registration
    case profile
    case list
    case detail(CategoryModel)
    
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
            case .detail(let c):
                hasher.combine("detail")
                hasher.combine(c)
            }
        }
}
