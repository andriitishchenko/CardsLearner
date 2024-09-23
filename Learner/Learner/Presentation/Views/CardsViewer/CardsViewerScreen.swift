//
//  CardsViewerScreen.swift
//  CardsLearner
//
//  Created by Andrii Tishchenko on 2024-09-16.
//

import SwiftUI

struct CardsViewerScreen: View {
    @ObservedObject var viewModel: CardsViewerViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            if let card = viewModel.currentCard {
                Text(card.translate)
                    .font(.largeTitle)
                    .blur(radius: viewModel.isBaseTitleBlurred ? 10 : 0)
                    .onTapGesture {
                        viewModel.toggleBaseTitleBlur()
                    }
                // Progress
                Text(viewModel.progressText)
                    .font(.headline)
                    .padding(.bottom)
                
                // Card image
                
                    AsyncImage(url: viewModel.imageURL) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                            ProgressView()
                            
                    }
                    .frame(maxWidth: .infinity, maxHeight: 300)
                    .cornerRadius(15)
                
                
                VStack(spacing: 0)
                    {
                    // Card title
                    Text(card.title)
                        .font(.largeTitle)
                        .padding()
                    
                    // Blurred/unblurred translation
                    Text(card.transcription ?? " - ")
                        .font(.title2)
                        .padding()
                }
                    .scaledToFit()
                    .blur(radius: viewModel.isTranslationBlurred ? 10 : 0)
                    .onTapGesture {
                        viewModel.toggleTranslationBlur()
                    }
                
                
                Button(action: {
                    viewModel.say()
                }){
                    Image(systemName: "play.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.blue)
                }
                .padding(.top)
                
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
                .padding()
                
            } else {
                Text("No cards available")
            }
        }
        .padding()
    }
}

//#Preview {
//    let intent = MockAppIntent()
//    let vm = CardsViewerViewModel(appIntent: intent)
//    return  CardsViewerScreen(viewModel: vm)
//    
//}
