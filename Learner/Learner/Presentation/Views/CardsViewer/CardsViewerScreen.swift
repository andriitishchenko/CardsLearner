//
//  CardsViewerScreen.swift
//  CardsLearner
//
//  Created by Andrii Tishchenko on 2024-09-16.
//

import SwiftUI

struct CardsViewerScreen: View {
    @ObservedObject var viewModel: CardsViewerViewModel
    
    var imageName: String {
        if #available(iOS 18.0, *) {
            return "photo.badge.exclamationmark.fill.circle"
        } else {
            return "photo"
        }
    }

    
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
                AsyncImage(url: viewModel.imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFit()
                    default:
                        VStack {
                            Image(systemName:imageName)
                            .font(.largeTitle)
                            Text("No image")
                        }
                    }
                }.frame(maxWidth: .infinity, maxHeight: 300)
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
                .padding()
                
            } else {
                Text("There are no more cards available")
            }
        }
        .padding()
        .gesture(
                    DragGesture(minimumDistance: 30, coordinateSpace: .local)
                        .onEnded { value in
                            if value.translation.width < 0 {
                                    viewModel.showNextCard()
                            }
                        }
                )
    }
}

//#Preview {
//    let intent = MockAppIntent()
//    let vm = CardsViewerViewModel(appIntent: intent)
//    return  CardsViewerScreen(viewModel: vm)
//    
//}
