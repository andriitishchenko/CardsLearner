import SwiftUI

struct QuizIncorrectAnswer: Identifiable, Equatable {
    let id = UUID()
    let question: String
    let selectedAnswer: String
    let correctAnswer: String
}

@MainActor
class CardsQuizViewModelBase: CardsQuizModelInterface {
    @Published var scoreTitle: String? = ""
    @Published var isCompleted = false
    @Published var displayTitle: String?
    @Published var currentCard: ModelCard?
    @Published var progressText = ""
    @Published var options: [String] = []
    @Published var selectedOption: String?
    @Published var incorrectAnswers: [QuizIncorrectAnswer] = []
    @Published var isNextButtonDisabled = false
    @Published var isCorrect = false

    private let questionText: (ModelCard) -> String
    private let correctAnswer: (ModelCard) -> String
    private var isLoading = false
    private var advanceTask: Task<Void, Never>?
    private var invalidAnswers = 0
    private var indexCards = 0
    private var list: [ModelCard]
    private let totalCards: Int

    init(
        category: CategoryModel,
        questionText: @escaping (ModelCard) -> String,
        correctAnswer: @escaping (ModelCard) -> String
    ) {
        self.questionText = questionText
        self.correctAnswer = correctAnswer
        self.totalCards = category.list.count
        self.list = category.list.shuffled()

        guard !list.isEmpty else {
            isCompleted = true
            scoreTitle = "Fails: 0"
            progressText = "0 of 0"
            return
        }
        showCard()
    }

    func showCard() {
        guard list.indices.contains(indexCards) else {
            currentCard = nil
            displayTitle = nil
            options = []
            isCompleted = true
            return
        }

        let card = list[indexCards]
        currentCard = card
        displayTitle = questionText(card)
        progressText = "\(indexCards + 1) of \(totalCards)"
        isNextButtonDisabled = indexCards >= totalCards - 1
        generateOptions(for: card)
    }

    func selectOption(_ option: String) {
        guard !isLoading,
              options.contains(option),
              let currentCard else { return }

        isLoading = true
        selectedOption = option
        isCorrect = option == correctAnswer(currentCard)

        if isCorrect {
            advanceTask = Task { @MainActor [weak self] in
                do {
                    try await Task.sleep(nanoseconds: 2_000_000_000)
                } catch {
                    return
                }
                guard !Task.isCancelled else { return }
                self?.showNextCard()
            }
        } else {
            isLoading = false
            invalidAnswers += 1
            incorrectAnswers.append(QuizIncorrectAnswer(
                question: questionText(currentCard),
                selectedAnswer: option,
                correctAnswer: correctAnswer(currentCard)
            ))
        }
    }

    func showNextCard() {
        guard !list.isEmpty, indexCards < totalCards else { return }

        advanceTask?.cancel()
        advanceTask = nil
        indexCards += 1
        if indexCards < totalCards {
            showCard()
            selectedOption = nil
            isCorrect = false
        } else {
            scoreTitle = "Fails: \(invalidAnswers)"
            isCompleted = true
        }
        isLoading = false
    }

    func showPreviousCard() {
        guard indexCards > 0 else { return }

        advanceTask?.cancel()
        advanceTask = nil
        indexCards -= 1
        isLoading = false
        isCompleted = false
        scoreTitle = nil
        showCard()
        selectedOption = nil
        isCorrect = false
    }

    private func generateOptions(for currentCard: ModelCard) {
        let answer = correctAnswer(currentCard)
        let incorrectOptions = Array(Set(list
            .filter { $0.id != currentCard.id }
            .map(correctAnswer)
            .filter { $0 != answer }))
            .shuffled()
            .prefix(2)

        options = (Array(incorrectOptions) + [answer]).shuffled()
    }
}
