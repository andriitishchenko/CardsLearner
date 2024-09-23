
import SwiftUI
import Combine

@MainActor 
class CardsViewModel: ObservableObject {
    @Published var cards: [CategoryModel] = []
    @Published var errorMessage: String?
    
    private var appIntent: AppIntent
    
    init(appIntent: AppIntent) {
        self.appIntent = appIntent
        bindIntent()
    }
    
    private func bindIntent() {
        appIntent.$errorMessage
            .assign(to: &$errorMessage)
        
        cards = self.appIntent.list
    }
    
    func fetchCards() {

    }
}
