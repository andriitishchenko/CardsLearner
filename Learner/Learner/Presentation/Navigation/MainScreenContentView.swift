import SwiftUI

struct MainScreenContentView: View {
    @ObservedObject var appIntent: AppIntent
    let currentScreen: AppScreen

    @ViewBuilder
    var body: some View {
        switch currentScreen {
        case .settings:
            StatefulScreen(viewModel: SelectLanguageViewModel(appIntent: appIntent)) {
                SelectLanguageScreen(viewModel: $0)
            }

        case .imports:
            ImportedSetsScreen(appIntent: appIntent)

        case .categoryOption(let category):
            InteractionOptionScreen(category: category) { selectedInteraction in
                appIntent.navigate(to: .detail(category: category, selectedInteraction: selectedInteraction))
            }
            .navigationTitle(category.title)

        case .detail(let category, let selectedInteraction):
            switch selectedInteraction {
            case .quiz:
                StatefulScreen(viewModel: CardsQuizViewModel(category: category)) {
                    CardsQuizScreen(viewModel: $0)
                }
                .navigationTitle("Quiz Mode")
            case .viewer:
                StatefulScreen(viewModel: CardsViewerViewModel(category: category)) {
                    CardsViewerScreen(viewModel: $0)
                }
                .navigationTitle("Card Viewer")
            case .quizInvert:
                StatefulScreen(viewModel: CardsQuizInvertViewModel(category: category)) {
                    CardsQuizScreen(viewModel: $0)
                }
                .navigationTitle("Quiz Inverted")
            case .mixedLetters:
                StatefulScreen(viewModel: CardsMixedLettersViewModel(category: category)) {
                    CardsMixedLettersView(viewModel: $0)
                }
                .navigationTitle("Mixed letters")
            }

        default:
            VStack(spacing: 12) {
                Image(systemName: "rectangle.stack")
                    .font(.system(size: 38))
                    .foregroundColor(.secondary)
                Text("Select a category or open settings")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(24)
        }
    }
}

@MainActor
private struct StatefulScreen<ViewModel: ObservableObject, Content: View>: View {
    @StateObject private var viewModel: ViewModel
    private let content: (ViewModel) -> Content

    init(
        viewModel: @autoclosure @escaping () -> ViewModel,
        @ViewBuilder content: @escaping (ViewModel) -> Content
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
        self.content = content
    }

    var body: some View {
        content(viewModel)
    }
}
