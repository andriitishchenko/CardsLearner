//
//  CardsQuizInvertViewModel.swift
//  Learner
//
//  Created by Andrii Tishchenko on 2024-09-27.
//

import SwiftUI

class CardsQuizInvertViewModel: CardsQuizModelInterface {
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
    
    init(appIntent: AppIntent, category: CategoryModel) {
        self.appIntent = appIntent
        self.category = category
        self.totalCards = category.list.count
        showCard()
    }
    
    func showCard() {
        Task { @MainActor in
            currentCard = category.list[indexCards]
            displayTitle = currentCard?.translate
            progressText = "\(indexCards + 1) of \(totalCards)"
            isNextButtonDisabled = indexCards >= totalCards - 1
            generateOptions()
        }
    }
    
    private func generateOptions() {
        guard let currentCard = currentCard else { return }
        
        var allCards = category.list.filter { $0.id != currentCard.id }
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
        selectedOption = option
        isCorrect = (option == currentCard?.title)
    }
    
    func showNextCard() {
        indexCards += 1
        if indexCards <= totalCards - 1 {
            showCard()
            selectedOption = nil
            isCorrect = false
        }
    }
}
