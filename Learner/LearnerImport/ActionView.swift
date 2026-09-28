import SwiftUI

struct ActionView: View {
    var wordPairs: [(String, String)]
    var onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Image("AppIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .padding(.top, 20)
                .padding(.bottom, 12)

            Text("Review imported words")
                .font(.headline)
                .padding(.bottom, 16)

            HStack {
                Text("Word")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Translation")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .font(.caption.weight(.semibold))
            .foregroundColor(.secondary)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)

            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(Array(wordPairs.enumerated()), id: \.offset) { entry in
                        HStack(alignment: .top, spacing: 16) {
                            Text(entry.element.0)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(entry.element.1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .font(.body)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(entry.offset.isMultiple(of: 2) ? Color(.secondarySystemBackground) : Color.clear)
                    }
                }
            }

            Button(action: onContinue) {
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 50)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}
