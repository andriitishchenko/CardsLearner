//
//  CardsQuizViewModel.swift
//  Learner
//
//  Created by Andrii Tishchenko on 2024-09-27.
//

import SwiftUI

class CardsQuizViewModel :CardsQuizModelInterface {
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
    
    private var appIntent: AppIntent
    
    init(appIntent: AppIntent, category: CategoryModel) {
        self.appIntent = appIntent
        self.category = category
        self.totalCards = category.list.count
        showCard()
    }
    
    func showCard() {
        Task { @MainActor in
            currentCard = category.list[indexCards]
            displayTitle = currentCard?.title
            progressText = "\(indexCards + 1) of \(totalCards)"
            isNextButtonDisabled = indexCards >= totalCards - 1
            generateOptions()
        }
    }
    
    // Generate random translation options
    private func generateOptions() {
        guard let currentCard = currentCard else { return }
        
        var allCards = category.list.filter { $0.id != currentCard.id }
        allCards.shuffle()
        
        // Pick 2 random translations from other cards
        let incorrectOptions = allCards.prefix(2).map { $0.translate }
        
        // Add the correct translation to the options
        var newOptions = incorrectOptions
        newOptions.append(currentCard.translate)
        newOptions.shuffle() // Shuffle the order of options
        
        options = newOptions
    }
    
    // Select the option
    func selectOption(_ option: String) {
        if isLoading {
            return
        }
        isLoading = true
        selectedOption = option
        if option == currentCard?.translate {
            isCorrect = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.showNextCard()
            }
        } else {
            isCorrect = false
            isLoading = false
            invalidAnswers += 1
        }
    }
    
    // Show the next card
    func showNextCard() {
        indexCards += 1
        if indexCards <= totalCards - 1 {
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
