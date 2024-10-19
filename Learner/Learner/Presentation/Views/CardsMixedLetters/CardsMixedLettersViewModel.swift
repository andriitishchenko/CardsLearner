//
//  CardsMixedLettersViewModel.swift
//  Learner
//
//  Created by Andrii Tishchenko on 2024-10-19.
//

import Foundation
import SwiftUI

class CardsMixedLettersViewModel: ObservableObject {
    @Published var currentCard: ModelCard?
    @Published var currentWordIndex = 0
    @Published var totalWords = 0
    @Published var selectedLetters: [[String?]] = []
    @Published var letterOptions: [String] = []
    @Published var isCorrect = false
    @Published var isCompleted = false
    @Published var failedWordsCount = 0
    @Published var currentWord: String = ""
    @Published var longestWordLenght:Int = 0
    
    private var appIntent: AppIntent
    private var category: CategoryModel
    private var originalPhrase: String = ""

    init(appIntent: AppIntent, category: CategoryModel) {
        self.appIntent = appIntent
        self.category = category
        self.totalWords = category.list.count
        loadNextWord()
    }
    
    func loadNextWord() {
        guard currentWordIndex < totalWords else {
            isCompleted = true
            return
        }
        
        currentCard = category.list[currentWordIndex]
        originalPhrase = currentCard?.title.lowercased() ?? ""
        
        // Initialize selected letters and options
        selectedLetters = splitPhraseIntoLines(phrase: originalPhrase)
        letterOptions = originalPhrase.filter { $0 != " " }.map { String($0) }
        letterOptions.shuffle()
        
        longestWordLenght =  min(8, letterOptions.count)
        if selectedLetters.count > 1 {
            let c = letterOptions.count
            if c / 2 > 8 && c % 2 == 0 {
                longestWordLenght = 1 + c / 2
            }
            else{
                longestWordLenght = 8
            }
        }
        isCorrect = false
    }
    
    // Splits a phrase into lines of characters for display
    private func splitPhraseIntoLines(phrase: String) -> [[String?]] {
        let words = phrase.split(separator: " ")
        return words.map { Array(repeating: nil, count: $0.count) }
    }
    
    func selectLetter(_ letter: String) {
        for lineIndex in 0..<selectedLetters.count {
            if let index = selectedLetters[lineIndex].firstIndex(where: { $0 == nil }) {
                selectedLetters[lineIndex][index] = letter
                checkIfCorrect()
                return
            }
        }
    }
    
    func removeLastLetter() {
        for lineIndex in (0..<selectedLetters.count).reversed() {
            if let index = selectedLetters[lineIndex].lastIndex(where: { $0 != nil }) {
                selectedLetters[lineIndex][index] = nil
                return
            }
        }
    }
    
    func resetWord() {
        selectedLetters = splitPhraseIntoLines(phrase: originalPhrase)
        isCorrect = false
    }
    
    func checkIfCorrect() {
        let selectedPhrase = selectedLetters.map { $0.compactMap { $0 }.joined() }.joined(separator: " ")
        
        if selectedPhrase == originalPhrase {
            isCorrect = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.currentWordIndex += 1
                self.loadNextWord()
            }
        } else if selectedLetters.flatMap({ $0 }).count == originalPhrase.count {
            isCorrect = false
            failedWordsCount += 1
        }
    }
}
