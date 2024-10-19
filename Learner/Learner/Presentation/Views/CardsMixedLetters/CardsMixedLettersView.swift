//
//  CardsMixedLettersView.swift
//  Learner
//
//  Created by Andrii Tishchenko on 2024-10-19.
//

import SwiftUI

struct CardsMixedLettersView: View {
    @ObservedObject var viewModel: CardsMixedLettersViewModel
    
    var body: some View {
        VStack {
            if viewModel.isCompleted {
                CompletedView(failedWordsCount: viewModel.failedWordsCount)
            } else {
                Text(viewModel.currentCard?.translate ?? "") // Display the original phrase at the top
                    .font(.headline)
                Text("\(viewModel.currentWordIndex + 1) of \(viewModel.totalWords)")
                    .padding(.bottom)

                // Display letter placeholders
                let placeholderCount = viewModel.selectedLetters.count
                ForEach(0..<placeholderCount, id: \.self) { index in
                    HStack(spacing: 5) {
                        ForEach(0..<viewModel.selectedLetters[index].count, id: \.self) { letterIndex in
                            ZStack {
                                Rectangle()
                                    .frame(width: 40, height: 50)
                                    .foregroundColor(.gray)
                                    .opacity(0.3)
                                    .border(Color.black)
                                Text(viewModel.selectedLetters[index][letterIndex] ?? "_")
                                    .font(.largeTitle)
                                    .foregroundColor(viewModel.isCorrect ? .green : .primary)
                            }
                        }
                    }
                }

                // Letter buttons
                let letterOptions = viewModel.letterOptions
                let columns = Array(repeating: GridItem(.flexible()), count:viewModel.longestWordLenght) // 5 letters per row
                LazyVGrid(columns: columns, spacing: 5) {
                    ForEach(letterOptions.indices, id: \.self) { index in
                        let letter = letterOptions[index]
                        Button(action: {
                            viewModel.selectLetter(letter)
                        }) {
                            Text(letter)
                                .font(.largeTitle)
                                .frame(width: 40, height: 50)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(5)
                        }
                    }
                }

                HStack {
                    Button(action: {
                        viewModel.resetWord()
                    }) {
                        Text("Reset")
                            .font(.title)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(5)
                    }

                    Button(action: {
                        viewModel.removeLastLetter()
                    }) {
                        Text("Delete Last")
                            .font(.title)
                            .padding()
                            .background(Color.orange)
                            
                            .foregroundColor(.white)
                            .cornerRadius(5)
                    }
                }
                .padding(.top)
                Spacer()
            }
        }
        .padding()
    }
}

struct CompletedView: View {
    let failedWordsCount: Int

    var body: some View {
        VStack {
            Text("Completed")
                .font(.largeTitle)
                .padding()

            Text("Failed Words Count: \(failedWordsCount)")
                .font(.headline)
                .padding()
        }
    }
}
