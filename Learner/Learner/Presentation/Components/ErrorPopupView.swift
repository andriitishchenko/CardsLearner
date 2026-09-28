//
//  ErrorPopupView.swift
//  BookApp
//
//  Created by Andrii Tishchenko on 2024-08-30.
//

import SwiftUI

struct ErrorPopupView: View {
    let message: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.title3)
                .accessibilityHidden(true)
            Text(message)
                .font(.body)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .foregroundColor(.red)
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
