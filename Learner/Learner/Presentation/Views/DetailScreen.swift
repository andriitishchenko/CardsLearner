import SwiftUI

struct DetailScreen: View {
    let card: ModelCard
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(card.title)
                .font(.largeTitle.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)
            Text(card.translate)
                .font(.title3)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            if let transcription = card.transcription, !transcription.isEmpty {
                Text(transcription)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .navigationTitle("Card Details")
    }
}
