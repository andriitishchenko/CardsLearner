//
//  ErrorActionView.swift
//  LearnerImport
//
//  Created by Andrii Tishchenko on 2024-10-26.
//

import SwiftUI

struct ErrorActionView: View {
    var errorMessage: String
    var onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Error")
                .font(.headline)
                .foregroundColor(.red)
            
            Text(errorMessage)
//                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
            
            Button(action: onClose) {
                Text("Close")
                    .font(.body)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 16)
        }
        .padding()
        .cornerRadius(16)
        .shadow(radius: 10)
        .frame(width: UIScreen.main.bounds.width * 0.8, height: 200)
    }
}
