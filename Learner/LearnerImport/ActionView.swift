//
//  ActionView.swift
//  LearnerImport
//
//  Created by Andrii Tishchenko on 2024-10-25.
//
import SwiftUI

struct ActionView: View {
    var wordPairs: [(String, String)] // Array of tuples to hold word pairs
    var onContinue: () -> Void
    
    var body: some View {
        VStack {
            // App Icon
            Image("AppIcon") // Ensure you have an image named "AppIcon" in your assets
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .cornerRadius(10)
                .padding(.top, -50)
                

            // Displaying text in two columns
            ScrollView{
                HStack {
                    VStack(alignment: .trailing) {
                        ForEach(Array(wordPairs.enumerated()), id: \.offset) { entry in
                            Text(entry.element.0)
                                .padding(5)
                        }
                    }
                    .frame(maxWidth: .infinity)

                    Divider()
                        .frame(width: 1)
                        .background(Color.gray)

                    VStack(alignment: .leading) {
                        ForEach(Array(wordPairs.enumerated()), id: \.offset) { entry in
                            Text(entry.element.1)
                                .padding(5)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding()
            }
            Spacer()
            
            // Continue Button
            Button(action: {
                onContinue()
            }) {
                Text("Continue")
                    .font(.headline)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
}
