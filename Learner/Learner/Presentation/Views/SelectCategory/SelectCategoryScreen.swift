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
    @State private var isLandscape: Bool = false
    
    // Dynamic column layout for different devices
    func columnsForMenu() -> [GridItem] {
        if isLandscape && UIDevice.current.userInterfaceIdiom == .phone {
            return [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ]
        } else {
            return [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ]
        }
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
        // Update the landscape state based on the device orientation
        .onAppear {
            updateOrientation()
        }
        .onRotate { newOrientation in
            updateOrientation()
        }
    }
    
    // Helper function to update the orientation state
    private func updateOrientation() {
        if UIDevice.current.orientation.isLandscape {
            isLandscape = true
        } else if UIDevice.current.orientation.isPortrait {
            isLandscape = false
        }
    }
}

//#Preview {
//    
//    let intent = MockAppIntent()
//    let vm = SelectCategoryViewModel(appIntent: intent)
//    return SelectCategoryScreen(viewModel: vm)
//}
