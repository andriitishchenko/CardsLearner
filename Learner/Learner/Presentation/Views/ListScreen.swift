import SwiftUI

struct ListScreen: View {
    @StateObject private var viewModel: CardsViewModel
    
    init(viewModel: CardsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        Group {
            if let errorMessage = viewModel.errorMessage {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                    Text(errorMessage)
                        .multilineTextAlignment(.center)
                }
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(24)
            } else if viewModel.cards.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "rectangle.stack")
                        .font(.largeTitle)
                    Text("No cards available.")
                        .font(.headline)
                }
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(viewModel.cards, id: \.id) { category in
                    VStack(alignment: .leading, spacing: 5) {
                        Text(category.title)
                            .font(.headline)
                        Text("\(category.list.count) cards")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 5)
                }
            }
        }
        .navigationTitle("Card List")
        .onAppear {
            viewModel.fetchCards()
        }
    }
}
