import SwiftUI

struct CategorySidebarView: View {
    @ObservedObject private var appIntent: AppIntent
    @StateObject private var viewModel: SelectCategoryViewModel

    init(appIntent: AppIntent) {
        self.appIntent = appIntent
        _viewModel = StateObject(wrappedValue: SelectCategoryViewModel(appIntent: appIntent))
    }

    var body: some View {
        ScrollView {
            SelectCategoryScreen(viewModel: viewModel)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
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
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
        }
        .navigationTitle("Categories")
    }
}
