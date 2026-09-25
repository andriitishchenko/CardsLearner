//
//  CardsQuizViewModel.swift
//  Learner
//
//  Created by Andrii Tishchenko on 2024-09-27.
//

import SwiftUI

final class CardsQuizViewModel: CardsQuizModelInterface {
    @Published var scoreTitle: String? = ""
    @Published var isCompleted: Bool = false
    @Published var displayTitle: String?
    @Published var currentCard: ModelCard?
    @Published var progressText: String = ""
    @Published var options: [String] = [] // Translation options
    @Published var selectedOption: String? = nil
    @Published var isNextButtonDisabled: Bool = false
    @Published var isCorrect: Bool = false
    
    private var isLoading: Bool = false
    
    private var totalCards: Int = 0
    private var indexCards: Int = 0
    private var category: CategoryModel
    private var invalidAnswers: Int = 0
    private var list: [ModelCard]
    
    private var appIntent: AppIntent
    
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
        displayTitle = currentCard?.title
        progressText = "\(indexCards + 1) of \(totalCards)"
        isNextButtonDisabled = indexCards >= totalCards - 1
        generateOptions()
    }
    
    // Generate random translation options
    private func generateOptions() {
        guard let currentCard = currentCard else { return }
        
        var allCards = list.filter { $0.id != currentCard.id }
        allCards.shuffle()
        
        // Pick 2 random translations from other cards
        let incorrectOptions = Array(Set(allCards.map(\.translate).filter { $0 != currentCard.translate }))
            .shuffled()
            .prefix(2)
        
        // Add the correct translation to the options
        var newOptions = Array(incorrectOptions)
        newOptions.append(currentCard.translate)
        newOptions.shuffle() // Shuffle the order of options
        
        options = newOptions
    }
    
    // Select the option
    func selectOption(_ option: String) {
        guard !isLoading, options.contains(option), let currentCard else { return }
        isLoading = true
        selectedOption = option
        if option == currentCard.translate {
            isCorrect = true
            Task { @MainActor [weak self] in
                do {
                    try await Task.sleep(for: .seconds(2))
                } catch {
                    return
                }
                self?.showNextCard()
            }
        } else {
            isCorrect = false
            isLoading = false
            invalidAnswers += 1
        }
    }
    
    // Show the next card
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
