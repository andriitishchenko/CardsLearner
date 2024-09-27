//
//  CardsQuizScreen.swift
//  Learner
//
//  Created by Andrii Tishchenko on 2024-09-27.
//

import SwiftUI

struct CardsQuizScreen<ViewModel: CardsQuizModelInterface>: View {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            if let title = viewModel.displayTitle {
                // Display the word in the origin language
                Text(title)
                    .font(.largeTitle)
                    .padding(.bottom, 10)
                
                // Display the translation options
                VStack(spacing: 10) {
                    ForEach(viewModel.options, id: \.self) { option in
                        Button(action: {
                            viewModel.selectOption(option)
                        }) {
                            Text(option)
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(option == viewModel.selectedOption ? (viewModel.isCorrect ? Color.green : Color.red) : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // Progress
                Text(viewModel.progressText)
                    .font(.headline)
                    .padding(.bottom, 10)
                
                // Next button
                Button(action: {
                    viewModel.showNextCard()
                }) {
                    Text("Next")
                        .font(.headline)
                        .frame(minWidth: 100, minHeight: 44)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(viewModel.isNextButtonDisabled)
                .padding(.top, 20)
            } else {
                Text("No cards available")
            }
        }
        .padding()
    }
}
