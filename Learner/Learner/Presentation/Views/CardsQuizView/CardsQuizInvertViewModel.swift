import SwiftUI

@MainActor
final class CardsQuizInvertViewModel: CardsQuizViewModelBase {
    init(category: CategoryModel) {
        super.init(category: category, questionText: \.translate, correctAnswer: \.title)
    }
}
