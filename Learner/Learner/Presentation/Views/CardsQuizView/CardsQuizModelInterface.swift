//
//  CardsQuizModelInterphase.swift
//  Learner
//
//  Created by Andrii Tishchenko on 2024-09-27.
//

import Combine

protocol CardsQuizModelInterface : ObservableObject{
    var currentCard: ModelCard? { get set }
    var progressText: String { get set }
    var displayTitle: String? { get set }
    var options: [String] { get set }
    var selectedOption: String? { get set }
    var isNextButtonDisabled: Bool { get set }
    var isCorrect: Bool { get set }
    
    func showCard()
    func selectOption(_ option: String)
    func showNextCard()
}

