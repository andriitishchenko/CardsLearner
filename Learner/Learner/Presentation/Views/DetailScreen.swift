import SwiftUI

struct DetailScreen: View {
    let card: ModelCard
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(card.title)
                .font(.largeTitle)
                .padding()
            Text(card.translate)
                .font(.body)
                .padding()
        }
        .navigationTitle("Card Details")
    }
}
