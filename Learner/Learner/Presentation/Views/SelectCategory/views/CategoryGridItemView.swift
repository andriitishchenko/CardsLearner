import SwiftUI
import Foundation
import Combine

struct CategoryGridItemView: View {
    let category: CategoryModel
    @State private var url: URL?

    private func loadImage() {
        Task {
            let cachedURL = await downloadFileDataTask(urlString: category.picture)
            await MainActor.run {
                url = cachedURL
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ZStack {
                    Color.secondary.opacity(0.12)
                    Image(systemName: "photo")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1.25, contentMode: .fit)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            Text(category.title)
                .font(.headline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .frame(maxWidth: .infinity, minHeight: 40, alignment: .topLeading)
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        }
        .onAppear(perform: loadImage)
    }
}

#Preview {
    let category = CategoryModel(id: 1, title: "Personality", picture: "https://loremflickr.com/640/480/family", order: 0, list: [])
    return CategoryGridItemView(category: category)
}
