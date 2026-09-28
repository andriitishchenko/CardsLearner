//
//  CardsMixedLettersViewModel.swift
//  Learner
//
//  Created by Andrii Tishchenko on 2024-10-19.
//

import Foundation
import SwiftUI

enum ValidateStatus: Int{
    case none
    case valid
    case invalid
}

@MainActor
final class CardsMixedLettersViewModel: ObservableObject {
    @Published var currentCard: ModelCard?
    @Published var currentWordIndex = 0
    @Published var totalWords = 0
    @Published var selectedLetters: [[String?]] = []
    @Published var letterOptions: [String] = []
    @Published var isCompleted = false
    @Published var failedWordsCount = 0
    @Published var currentWord: String = ""
    @Published var longestWordLenght:Int = 0
    @Published var validationStatus:ValidateStatus = .none
    
    private var originalPhrase: String = ""
    private var voice:Voice
    private var shouldSaySlowly = false
    private var list: [ModelCard]
    private var advanceTask: Task<Void, Never>?

    init(category: CategoryModel) {
        list = category.list.filter { !$0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.shuffled()
        self.totalWords = list.count
        self.voice = Voice(lang: category.list.first?.localCode ?? "en")
        loadNextWord()
    }
    
    func loadNextWord() {
        guard currentWordIndex < totalWords else {
            currentCard = nil
            isCompleted = true
            return
        }

        isCompleted = false
        
        currentCard = list[currentWordIndex]
        originalPhrase = currentCard?.title.lowercased() ?? ""
        
        // Initialize selected letters and options
        selectedLetters = splitPhraseIntoLines(phrase: originalPhrase)
        letterOptions = originalPhrase.filter { $0 != " " }.map { String($0) }
        letterOptions.shuffle()
        
        let c = letterOptions.count
        longestWordLenght = c > 8 ? min(8, min( c, c % 2 == 0 ? c / 2  : 1 + c / 2 )) : c

        validationStatus = .none
        shouldSaySlowly = false
    }

    func showNextWord() {
        guard currentWordIndex < totalWords else { return }
        advanceTask?.cancel()
        advanceTask = nil
        currentWordIndex += 1
        loadNextWord()
    }

    func showPreviousWord() {
        guard currentWordIndex > 0 else { return }
        advanceTask?.cancel()
        advanceTask = nil
        currentWordIndex -= 1
        loadNextWord()
    }
    
    // Splits a phrase into lines of characters for display
    private func splitPhraseIntoLines(phrase: String) -> [[String?]] {
        let words = phrase.split(separator: " ")
        return words.map { Array(repeating: nil, count: $0.count) }
    }
    
    func selectLetter(_ letter: String) {
        let usedCount = selectedLetters.flatMap { $0.compactMap { $0 } }.filter { $0 == letter }.count
        guard usedCount < letterOptions.filter({ $0 == letter }).count else { return }

        for lineIndex in 0..<selectedLetters.count {
            if let index = selectedLetters[lineIndex].firstIndex(where: { $0 == nil }) {
                selectedLetters[lineIndex][index] = letter
                checkIfCorrect()
                return
            }
        }
    }
    
    func removeLastLetter() {
        validationStatus = .none
        for lineIndex in (0..<selectedLetters.count).reversed() {
            if let index = selectedLetters[lineIndex].lastIndex(where: { $0 != nil }) {
                selectedLetters[lineIndex][index] = nil
                return
            }
        }
    }
    
    func resetWord() {
        selectedLetters = splitPhraseIntoLines(phrase: originalPhrase)
        validationStatus = .none
    }
    
    func checkIfCorrect() {
        let selectedPhrase = selectedLetters.map { $0.compactMap { $0 }.joined() }.joined(separator: " ")
        
        if selectedPhrase == originalPhrase {
            validationStatus = .valid
            let completedWordIndex = currentWordIndex
            advanceTask = Task { @MainActor [weak self] in
                do {
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                } catch {
                    return
                }
                guard let self else { return }
                guard !Task.isCancelled, self.currentWordIndex == completedWordIndex else { return }
                self.showNextWord()
            }
        } else if selectedPhrase.count == originalPhrase.count {
            validationStatus = .invalid
            failedWordsCount += 1
        }
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
    
    func statusColor() -> Color{
        let rez:Color = switch validationStatus {
        case .valid:
            .green
        case .invalid:
            .red
        default:
            .primary
        }
        return rez
    }
}
