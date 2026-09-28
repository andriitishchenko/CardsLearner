import SwiftUI

@MainActor
final class CardsQuizViewModel: CardsQuizViewModelBase {
    init(category: CategoryModel) {
        super.init(category: category, questionText: \.title, correctAnswer: \.translate)
    }
}
