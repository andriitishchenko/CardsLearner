//
//  CategoryGridItemView.swift
//  CardsLearner
//
//  Created by Andrii Tishchenko on 2024-09-16.
//

import SwiftUI
import Foundation
import Combine

struct CategoryGridItemView: View {
    let category: CategoryModel
    @State var url:URL?
    
    func loadImage(){
        Task{
            let urlCache = await downloadFileDataTask(urlString: category.picture)
            await MainActor.run {
                self.url = urlCache
            }
        }
    }
    
    var body: some View {
        VStack {
            AsyncImage(url: self.url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.gray
                }
                .frame(width: 100, height: 100)
                .cornerRadius(10)
            Text(category.title)
                .font(.headline)
                .lineLimit(1)
                .padding(.all, 0)
                .padding(.top, 5)
        }
        .padding(0)
        .onAppear {
            loadImage()
        }
    }
}

#Preview {
    let cat = CategoryModel(id: 1, title: "Personality", picture: "https://loremflickr.com/640/480/family",order:0, list: [])
    return CategoryGridItemView(category:cat)
}
