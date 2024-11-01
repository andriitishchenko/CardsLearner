//
//  CardsViewerViewModel.swift
//  CardsLearner
//
//  Created by Andrii Tishchenko on 2024-09-16.
//

import SwiftUI

class CardsViewerViewModel: ObservableObject {
    @Published var currentCard: ModelCard?
    @Published var progressText: String = ""
    @Published var isTranslationBlurred: Bool = false
    @Published var isBaseTitleBlurred: Bool = false
    @Published var isNextButtonDisabled: Bool = false
    @Published var category: CategoryModel?
    @Published var imageURL: URL?
    
    private var totalCards: Int = 0
    private var indexCards: Int = 0
    private var appIntent: AppIntent
    private var list: [ModelCard]
    
    private var shouldSaySlowly = false
    
    private var voice:Voice
    
    init(appIntent: AppIntent, category:CategoryModel) {
        self.appIntent = appIntent
        self.category = category
        self.totalCards = category.list.count
        voice = Voice(lang: category.list[0].localCode)
        list = category.list.shuffled()
        showCard()
    }
    func showCard(){
        Task{ @MainActor in
            self.currentCard = list[indexCards]
            progressText = "\(indexCards + 1) of \(totalCards)"
            isNextButtonDisabled = indexCards >= totalCards-1
            shouldSaySlowly = false
            
            if let url = currentCard?.picture {
                let resultUrl = await downloadFileDataTask(urlString: url)
                self.imageURL = resultUrl
            }
        }
    }
    
    // Show the next card in the sequence
    func showNextCard() {
        self.imageURL = nil
        indexCards += 1
        if indexCards <= totalCards-1 {
            showCard()
        }
    }
        
    // Toggle the blurred state of the translation
    func toggleTranslationBlur() {
        isTranslationBlurred.toggle()
    }
    
    func toggleBaseTitleBlur() {
        isBaseTitleBlurred.toggle()
    }

    func say(){
        Task{
            if let str = currentCard?.title {
                if !shouldSaySlowly{
                    voice.strToVoice(text: str)
                }
                else {
                    voice.sayAgain()
                }
                shouldSaySlowly = !shouldSaySlowly
            }
        }
    }
}
