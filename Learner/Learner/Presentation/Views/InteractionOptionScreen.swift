//
//  InteractionOptionScreen.swift
//  Learner
//
//  Created by Andrii Tishchenko on 2024-09-27.
//

import SwiftUI

struct InteractionOptionScreen: View {
    let category: CategoryModel
    let onOptionSelected: (InteractionType) -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("How do you want to interact with cards?")
                .font(.title2)
                .padding()

            Button(action: {
                onOptionSelected(.viewer)
            }) {
                Label("Card Viewer", systemImage: "photo")
                    .frame(minWidth: 200, minHeight: 44)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Button(action: {
                onOptionSelected(.quiz)
            }) {
                Label("Quiz Mode", systemImage: "questionmark.circle")
                    .frame(minWidth: 200, minHeight: 44)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Button(action: {
                onOptionSelected(.quizInvert)
            }) {
                Label("Quiz Inverted", systemImage: "arrow.uturn.left.circle")
                    .frame(minWidth: 200, minHeight: 44)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}
