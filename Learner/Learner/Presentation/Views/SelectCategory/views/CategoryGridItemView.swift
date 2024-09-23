//
//  CategoryGridItemView.swift
//  CardsLearner
//
//  Created by Andrii Tishchenko on 2024-09-16.
//

import SwiftUI
import Foundation

struct CategoryGridItemView: View {
    let category: CategoryModel
    
    var body: some View {
        VStack {
            if let url = URL(string: category.picture) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.gray
                }
                .frame(width: 100, height: 100)
                .cornerRadius(10)
            } else {
                Color.gray
                    .frame(width: 100, height: 100)
                    .cornerRadius(10)
            }
            
            Text(category.title)
                .font(.headline)
                .padding(.top, 5)
        }
        .padding()
    }
}

#Preview {
    let cat = CategoryModel(id: 1, title: "Family", picture: "https://loremflickr.com/640/480/family", list: [])
    return CategoryGridItemView(category:cat)
}
