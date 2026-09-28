import SwiftUI

struct CategorySidebarView: View {
    @ObservedObject private var appIntent: AppIntent
    @Binding private var currentScreen: AppScreen
    @StateObject private var viewModel: SelectCategoryViewModel

    init(appIntent: AppIntent, currentScreen: Binding<AppScreen>) {
        self.appIntent = appIntent
        _currentScreen = currentScreen
        _viewModel = StateObject(wrappedValue: SelectCategoryViewModel(appIntent: appIntent))
    }

    var body: some View {
        VStack {
            ScrollView {
                SelectCategoryScreen(viewModel: viewModel)
            }

            Spacer()

            HStack(spacing: 12) {
                Button {
                    currentScreen = .settings
                    appIntent.navigate(to: .settings)
                } label: {
                    Label("Settings", systemImage: "gear")
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.bordered)

                Button {
                    currentScreen = .imports
                    appIntent.navigate(to: .imports)
                } label: {
                    Label("Imported words", systemImage: "text.book.closed")
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.bordered)
            }
        }
        .navigationTitle("Categories")
    }
}
