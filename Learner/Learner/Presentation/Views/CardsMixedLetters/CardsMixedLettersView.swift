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
        ScrollView {
          VStack(spacing: 24) {
            if viewModel.isCompleted {
                CompletedView(failedWordsCount: viewModel.failedWordsCount)
            } else {
                if let currentCard = viewModel.currentCard {
                    Button(action: viewModel.say) {
                        Label(currentCard.translate, systemImage: "speaker.wave.2.fill")
                            .font(.title3.weight(.semibold))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, minHeight: 64)
                            .padding(.horizontal, 16)
                    }
                    .buttonStyle(.bordered)
                }
                Text("\(viewModel.currentWordIndex + 1) of \(viewModel.totalWords)")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(Capsule())

                // Display letter placeholders
                let placeholderCount = viewModel.selectedLetters.count
                ForEach(0..<placeholderCount, id: \.self) { index in
                    HStack(spacing: 5) {
                        ForEach(0..<viewModel.selectedLetters[index].count, id: \.self) { letterIndex in
                            ZStack {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(Color(.secondarySystemBackground))
                                    .frame(width: 38, height: 48)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                            .stroke(Color.primary.opacity(0.12), lineWidth: 1)
                                    }
                                Text(viewModel.selectedLetters[index][letterIndex] ?? "_")
                                    .font(.title2.weight(.semibold))
                                    .foregroundColor(viewModel.statusColor())
                            }
                        }
                    }
                }

                // Letter buttons
                let letterOptions = viewModel.letterOptions
                let columns = Array(repeating: GridItem(.flexible(minimum: 30, maximum: 44)), count: viewModel.longestWordLenght)
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(letterOptions.indices, id: \.self) { index in
                        let letter = letterOptions[index]
                        Button(action: {
                            viewModel.selectLetter(letter)
                        }) {
                            Text(letter)
                                .font(.title2.weight(.semibold))
                                .frame(maxWidth: .infinity, minHeight: 48)
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }
                    }
                }

                HStack {
                    Button(action: {
                        viewModel.resetWord()
                    }) {
                        Text("Reset")
                            .font(.body.weight(.semibold))
                            .frame(maxWidth: .infinity, minHeight: 48)
                    }

                    Button(action: {
                        viewModel.removeLastLetter()
                    }) {
                        Text("Delete")
                            .font(.body.weight(.semibold))
                            .frame(maxWidth: .infinity, minHeight: 48)
                    }
                }
                .buttonStyle(.bordered)
            }
          }
          .padding(20)
          .frame(maxWidth: 560)
          .frame(maxWidth: .infinity)
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 40, coordinateSpace: .local)
                .onEnded { value in
                    guard abs(value.translation.width) > abs(value.translation.height) else { return }
                    if value.translation.width < 0 {
                        viewModel.showNextWord()
                    } else {
                        viewModel.showPreviousWord()
                    }
                }
        )
    }
}

struct CompletedView: View {
    let failedWordsCount: Int

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 48))
                .foregroundColor(.green)
            Text("Completed")
                .font(.largeTitle.weight(.bold))

            Text("Failed Words Count: \(failedWordsCount)")
                .font(.title3)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(28)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
