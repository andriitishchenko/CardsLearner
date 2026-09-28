//
//  CardsViewerViewModel.swift
//  CardsLearner
//
//  Created by Andrii Tishchenko on 2024-09-16.
//

import SwiftUI

@MainActor
final class CardsViewerViewModel: ObservableObject {
    @Published var currentCard: ModelCard?
    @Published var progressText: String = ""
    @Published var isTranslationBlurred: Bool = false
    @Published var isBaseTitleBlurred: Bool = false
    @Published var imageURL: URL?
    
    private var totalCards: Int = 0
    private var indexCards: Int = 0
    private var list: [ModelCard]
    
    private var shouldSaySlowly = false
    
    private var voice:Voice
    
    init(category: CategoryModel) {
        self.totalCards = category.list.count
        voice = Voice(lang: category.list.first?.localCode ?? "en")
        list = category.list.shuffled()
        showCard()
    }
    func showCard(){
        guard list.indices.contains(indexCards) else {
            currentCard = nil
            progressText = "0 of \(totalCards)"
            return
        }

        let card = list[indexCards]
        currentCard = card
        imageURL = nil
        isTranslationBlurred = false
        isBaseTitleBlurred = false
        progressText = "\(indexCards + 1) of \(totalCards)"
        shouldSaySlowly = false

        guard let url = card.picture else { return }
        Task { @MainActor [weak self] in
            let resultURL = await downloadFileDataTask(urlString: url)
            guard self?.currentCard?.id == card.id,
                  self?.currentCard?.picture == url else { return }
            self?.imageURL = resultURL
        }
    }
    
    // Show the next card in the sequence
    func showNextCard() {
        guard indexCards < totalCards else { return }
        imageURL = nil
        indexCards += 1
        if indexCards < totalCards {
            showCard()
        } else {
            currentCard = nil
        }
    }

    func showPreviousCard() {
        guard indexCards > 0 else { return }
        indexCards -= 1
        showCard()
    }
        
    // Toggle the blurred state of the translation
    func toggleTranslationBlur() {
        isTranslationBlurred.toggle()
    }
    
    func toggleBaseTitleBlur() {
        isBaseTitleBlurred.toggle()
    }

    func say(){
        guard let text = currentCard?.title else { return }
        if !shouldSaySlowly {
            voice.strToVoice(text: text)
        } else {
            voice.sayAgain()
        }
        shouldSaySlowly.toggle()
    }
}
