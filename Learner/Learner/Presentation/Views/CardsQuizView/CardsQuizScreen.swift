import SwiftUI

struct CardsQuizScreen<ViewModel: CardsQuizModelInterface>: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                if viewModel.isCompleted {
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.green)
                        Text("Completed")
                            .font(.largeTitle.weight(.bold))
                        Text(viewModel.scoreTitle ?? "--/--")
                            .font(.title2.weight(.semibold))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(28)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                    if !viewModel.incorrectAnswers.isEmpty {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Review incorrect answers")
                                .font(.headline)

                            LazyVStack(alignment: .leading, spacing: 14) {
                                ForEach(Array(viewModel.incorrectAnswers.enumerated()), id: \.element.id) { index, answer in
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("\(index + 1). \(answer.question)")
                                        .font(.body.weight(.semibold))
                                        Text("Correct answer: \(answer.correctAnswer)")
                                            .foregroundColor(.green)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                    if index < viewModel.incorrectAnswers.count - 1 {
                                        Divider()
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                } else if let title = viewModel.displayTitle {
                    VStack(spacing: 12) {
                        Text("Translate")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.secondary)
                        Text(title)
                            .font(.largeTitle.weight(.semibold))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.vertical, 28)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                    VStack(spacing: 12) {
                        ForEach(Array(viewModel.options.enumerated()), id: \.offset) { _, option in
                            Button {
                                viewModel.selectOption(option)
                            } label: {
                                HStack(spacing: 12) {
                                    Text(option)
                                        .font(.body.weight(.semibold))
                                        .multilineTextAlignment(.leading)
                                    Spacer(minLength: 8)
                                    if option == viewModel.selectedOption {
                                        Image(systemName: viewModel.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                            .accessibilityHidden(true)
                                    }
                                }
                                .frame(maxWidth: .infinity, minHeight: 52)
                                .padding(.horizontal, 16)
                                .foregroundColor(option == viewModel.selectedOption ? .white : .primary)
                                .background(optionBackground(for: option))
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(option == viewModel.selectedOption ? Color.clear : Color.primary.opacity(0.1), lineWidth: 1)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Text(viewModel.progressText)
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color(.tertiarySystemBackground))
                        .clipShape(Capsule())
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "rectangle.stack")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("No cards available")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 48)
                }
            }
            .padding(20)
            .frame(maxWidth: 560)
            .frame(maxWidth: .infinity)
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 40, coordinateSpace: .local)
                .onEnded { value in
                    guard abs(value.translation.width) > abs(value.translation.height) else { return }
                    if value.translation.width < 0 {
                        viewModel.showNextCard()
                    } else {
                        viewModel.showPreviousCard()
                    }
                }
        )
    }

    private func optionBackground(for option: String) -> Color {
        guard option == viewModel.selectedOption else {
            return Color(.secondarySystemBackground)
        }
        return viewModel.isCorrect ? .green : .red
    }
}
