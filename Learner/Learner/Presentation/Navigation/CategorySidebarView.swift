import SwiftUI

struct CategorySidebarView: View {
    @ObservedObject private var appIntent: AppIntent
    @StateObject private var viewModel: SelectCategoryViewModel

    init(appIntent: AppIntent) {
        self.appIntent = appIntent
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
                    appIntent.navigateToRoot(.settings)
                } label: {
                    Label("Settings", systemImage: "gear")
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.bordered)

                Button {
                    appIntent.navigateToRoot(.imports)
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
