//
//  InteractionOptionScreen.swift
//  Learner
//
//  Created by Andrii Tishchenko on 2024-09-27.
//

import SwiftUI
import GoogleMobileAds

struct InteractionOptionScreen: View {
    let category: CategoryModel
    let onOptionSelected: (InteractionType) -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("How do you want to interact with cards?")
                .font(.title2.weight(.semibold))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
                .padding(.top, 12)
                .padding(.bottom, 8)

            Button(action: {
                onOptionSelected(.viewer)
            }) {
                Label("Card Viewer", systemImage: "photo")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Button(action: {
                onOptionSelected(.quiz)
            }) {
                Label("Quiz Mode", systemImage: "questionmark.circle")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Button(action: {
                onOptionSelected(.quizInvert)
            }) {
                Label("Quiz Inverted", systemImage: "arrow.uturn.left.circle")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Button(action: {
                onOptionSelected(.mixedLetters)
            }) {
                Label("Mixed letters", systemImage: "arrow.left.arrow.right")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(Color(
                        red: 1,
                        green: 0.55,
                        blue: 0.41
                    ))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            GeometryReader { geometry in
                let adSize = largeAnchoredAdaptiveBanner(width: geometry.size.width)
                VStack {
                    Spacer(minLength: 12)
                    BannerViewAd(adSize)
                        .frame(height: adSize.size.height)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
}
