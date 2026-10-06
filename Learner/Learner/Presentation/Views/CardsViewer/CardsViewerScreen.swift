import SwiftUI

struct CardsViewerScreen: View {
    @ObservedObject var viewModel: CardsViewerViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let card = viewModel.currentCard {
                    Text(card.translate)
                        .font(.largeTitle.weight(.semibold))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .blur(radius: viewModel.isBaseTitleBlurred ? 10 : 0)
                        .onTapGesture(perform: viewModel.toggleBaseTitleBlur)

                    Text(viewModel.progressText)
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color(.tertiarySystemBackground))
                        .clipShape(Capsule())

                    AsyncImage(url: viewModel.imageURL) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: 280)
                        } else {
                            VStack(spacing: 8) {
                                Image(systemName: "photo")
                                    .font(.system(size: 38))
                                Text("No image")
                                    .font(.subheadline)
                            }
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, minHeight: 180, maxHeight: 280)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 180, maxHeight: 280)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                    VStack(spacing: 8) {
                        Text(card.title)
                            .font(.title.weight(.semibold))
                            .multilineTextAlignment(.center)
                        Text(card.transcription ?? "—")
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(20)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .blur(radius: viewModel.isTranslationBlurred ? 10 : 0)
                    .onTapGesture(perform: viewModel.toggleTranslationBlur)

                    HStack(spacing: 12) {
                        Button(action: viewModel.say) {
                            Label("Listen", systemImage: "speaker.wave.2.fill")
                                .frame(maxWidth: .infinity, minHeight: 48)
                        }
                        .buttonStyle(.bordered)

                        Button(action: viewModel.showNextCard) {
                            Text("Next")
                                .font(.headline)
                                .frame(maxWidth: .infinity, minHeight: 48)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.seal")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("There are no more cards available")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 64)
                }
            }
            .padding(20)
            .frame(maxWidth: 600)
            .frame(maxWidth: .infinity)
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 30, coordinateSpace: .local)
                .onEnded { value in
                    guard abs(value.translation.width) > abs(value.translation.height) else { return }
                    if value.translation.width < 0 {
                        viewModel.showNextCard()
                    } else if value.translation.width > 0 {
                        viewModel.showPreviousCard()
                    }
                }
        )
    }
}
