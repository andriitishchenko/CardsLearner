//
//  CardsQuizInvertViewModel.swift
//  Learner
//
//  Created by Andrii Tishchenko on 2024-09-27.
//

import SwiftUI

final class CardsQuizInvertViewModel: CardsQuizModelInterface {
    @Published var scoreTitle: String? = ""
    @Published var isCompleted: Bool = false
    @Published var displayTitle: String?
    @Published var currentCard: ModelCard?
    @Published var progressText: String = ""
    @Published var options: [String] = []
    @Published var selectedOption: String? = nil
    @Published var isNextButtonDisabled: Bool = false
    @Published var isCorrect: Bool = false
    
    private var totalCards: Int = 0
    private var indexCards: Int = 0
    private var category: CategoryModel
    private var appIntent: AppIntent
    private var isLoading: Bool = false
    private var list: [ModelCard]
    
    private var invalidAnswers: Int = 0
    
    init(appIntent: AppIntent, category: CategoryModel) {
        self.appIntent = appIntent
        self.category = category
        self.totalCards = category.list.count
        list = category.list.shuffled()
        if list.isEmpty {
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
        currentCard = list[indexCards]
        displayTitle = currentCard?.translate
        progressText = "\(indexCards + 1) of \(totalCards)"
        isNextButtonDisabled = indexCards >= totalCards - 1
        generateOptions()
    }
    
    private func generateOptions() {
        guard let currentCard = currentCard else { return }
        
        var allCards = list.filter { $0.id != currentCard.id }
        allCards.shuffle()
        
        // Pick 2 random titles from other cards
        let incorrectOptions = Array(Set(allCards.map(\.title).filter { $0 != currentCard.title }))
            .shuffled()
            .prefix(2)
        
        // Add the correct title to the options
        var newOptions = Array(incorrectOptions)
        newOptions.append(currentCard.title)
        newOptions.shuffle() // Shuffle the order of options
        
        options = newOptions
    }
    
    func selectOption(_ option: String) {
        guard !isLoading, options.contains(option), let currentCard else { return }
        isLoading = true
        selectedOption = option
        isCorrect = option == currentCard.title
        if isCorrect {
            Task { @MainActor [weak self] in
                do {
                    try await Task.sleep(for: .seconds(2))
                } catch {
                    return
                }
                self?.showNextCard()
            }
        }else{
            isLoading = false
            invalidAnswers += 1
        }
        
    }
    
    func showNextCard() {
        guard !list.isEmpty, indexCards < totalCards else { return }
        indexCards += 1
        if indexCards < totalCards {
            showCard()
            selectedOption = nil
            isCorrect = false
        }
        else{
            scoreTitle = "Fails: \(invalidAnswers)"
            isCompleted = true
        }
        
        isLoading = false
    }
}
