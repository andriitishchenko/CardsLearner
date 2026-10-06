import SwiftUI

@available(iOS 16.0, *)
struct ModernNavigationContainer: View {
    @ObservedObject var appIntent: AppIntent

    var body: some View {
        NavigationSplitView {
            CategorySidebarView(appIntent: appIntent)
        } detail: {
            NavigationStack(path: Binding(
                get: { appIntent.navigationPath },
                set: { appIntent.setNavigationPath($0) }
            )) {
                MainScreenContentView(appIntent: appIntent, currentScreen: .home)
                    .navigationTitle("Categories")
                    .navigationDestination(for: AppScreen.self) { screen in
                        MainScreenContentView(appIntent: appIntent, currentScreen: screen)
                    }
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
}
