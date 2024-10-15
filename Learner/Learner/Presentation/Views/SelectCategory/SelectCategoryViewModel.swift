//
//  SelectCategoryViewModel.swift
//  CardsLearner
//
//  Created by Andrii Tishchenko on 2024-09-16.
//

import Foundation
import SwiftUI
import Combine

@MainActor 
class SelectCategoryViewModel: ObservableObject {
    @Published 
    var categories: [CategoryModel] = []
    
    @Published 
    var selectedCategory: CategoryModel? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    private var appIntent: AppIntent
    
    init(appIntent: AppIntent) {
        self.appIntent = appIntent
        bindToIntent()
    }

    
    private func bindToIntent() {
        appIntent.$list
            .sink { [weak self] list in
                self?.categories = list.sorted(by: {
                    return $0.order < $1.order
                })
            }
            .store(in: &cancellables)
      }

    
    func selectCategory(category: CategoryModel) {
        self.appIntent.navigate(to: .categoryOption(category: category))
        
    }
    
    func openSettings(){
        self.appIntent.navigate(to: .settings)
    }
}
