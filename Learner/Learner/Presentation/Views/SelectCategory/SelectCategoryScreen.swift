//
//  SelectCategoryScreen.swift
//  CardsLearner
//
//  Created by Andrii Tishchenko on 2024-09-16.
//
//


import SwiftUI

struct SelectCategoryScreen: View {
    @StateObject var viewModel: SelectCategoryViewModel
    @State private var currentSelected: CategoryModel?
    
    // Dynamic column layout for different devices
    func columnsForMenu() -> [GridItem] {
            return [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ]
    }
    
    var body: some View {
            List(selection: $currentSelected){}.frame(height: 0) //workaround to have custom menu
            VStack {
                LazyVGrid(columns: columnsForMenu(), spacing: 16) {
                    ForEach(viewModel.categories, id: \.id) { category in
                        Button(action: {
                            currentSelected = category
                            viewModel.selectCategory(category: category)
                        }) {
                            CategoryGridItemView(category: category)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
    }
}

//#Preview {
//    
//    let intent = MockAppIntent()
//    let vm = SelectCategoryViewModel(appIntent: intent)
//    return SelectCategoryScreen(viewModel: vm)
//}
