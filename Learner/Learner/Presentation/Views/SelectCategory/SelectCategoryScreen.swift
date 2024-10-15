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
    @State private var width:CGFloat = 0.0
    // Dynamic column layout for different devices
    func columnsForMenu(screenWidth: CGFloat) -> [GridItem] {
        let thresholdForThreeColumns: CGFloat = 600
        if isLandscape && UIDevice.current.userInterfaceIdiom == .phone && screenWidth > thresholdForThreeColumns{
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
            LazyVGrid(columns: columnsForMenu(screenWidth: self.width), spacing: 16) {
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
        .background(
            GeometryReader { proxy in
                Color.clear
                    .onAppear {
                        self.width = proxy.size.width
                    }
                    .onChange(of: proxy.size) { _,_ in
                        self.width = proxy.size.width
                    }
            }
        )
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
