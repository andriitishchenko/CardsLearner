//
//  CardsQuizInvertViewModel.swift
//  Learner
//
//  Created by Andrii Tishchenko on 2024-09-27.
//

import SwiftUI

class CardsQuizInvertViewModel: CardsQuizModelInterface {
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
        showCard()
    }
    
    func showCard() {
        Task { @MainActor in
            currentCard = list[indexCards]
            displayTitle = currentCard?.translate
            progressText = "\(indexCards + 1) of \(totalCards)"
            isNextButtonDisabled = indexCards >= totalCards - 1
            generateOptions()
        }
    }
    
    private func generateOptions() {
        guard let currentCard = currentCard else { return }
        
        var allCards = list.filter { $0.id != currentCard.id }
        allCards.shuffle()
        
        // Pick 2 random titles from other cards
        let incorrectOptions = allCards.prefix(2).map { $0.title }
        
        // Add the correct title to the options
        var newOptions = incorrectOptions
        newOptions.append(currentCard.title)
        newOptions.shuffle() // Shuffle the order of options
        
        options = newOptions
    }
    
    func selectOption(_ option: String) {
        if isLoading {
            return
        }
        isLoading = true
        selectedOption = option
        isCorrect = (option == currentCard?.title)
        if isCorrect {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.showNextCard()
            }
        }else{
            isLoading = false
            invalidAnswers += 1
        }
        
    }
    
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
