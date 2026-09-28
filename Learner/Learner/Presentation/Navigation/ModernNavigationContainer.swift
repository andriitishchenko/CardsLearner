import SwiftUI

@available(iOS 16.0, *)
struct ModernNavigationContainer: View {
    @ObservedObject var appIntent: AppIntent
    @State private var currentScreen: AppScreen = .home

    var body: some View {
        NavigationSplitView {
            CategorySidebarView(appIntent: appIntent, currentScreen: $currentScreen)
        } detail: {
            NavigationStack {
                MainScreenContentView(appIntent: appIntent, currentScreen: currentScreen)
                    .id(currentScreen)
            }
        }
        .navigationSplitViewStyle(.balanced)
        .onReceive(appIntent.$currentScreen) { currentScreen = $0 }
    }
}
