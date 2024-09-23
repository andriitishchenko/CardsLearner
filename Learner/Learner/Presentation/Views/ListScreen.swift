import SwiftUI

struct ListScreen: View {
    @StateObject private var viewModel: CardsViewModel
    
    init(viewModel: CardsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else if viewModel.cards.isEmpty {
                Text("No cards available.")
                    .padding()
            } else {
                List(viewModel.cards, id: \.id) { card in
                    Text(card.title)
                }
            }
        }
        .navigationTitle("Card List")
        .onAppear {
            viewModel.fetchCards()
        }
    }
}
