import SwiftUI

struct LegacyNavigationContainer: View {
    @ObservedObject var appIntent: AppIntent
    @State private var currentScreen: AppScreen = .home

    private var isShowingCategories: Bool {
        currentScreen == .home || currentScreen == .list
    }

    var body: some View {
        NavigationView {
            Group {
                if isShowingCategories {
                    CategorySidebarView(appIntent: appIntent, currentScreen: $currentScreen)
                } else {
                    MainScreenContentView(appIntent: appIntent, currentScreen: currentScreen)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button {
                                    appIntent.clearNavigation()
                                } label: {
                                    Label(appIntent.navigationReturnDestination.title, systemImage: "chevron.backward")
                                }
                            }
                        }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onReceive(appIntent.$currentScreen) { currentScreen = $0 }
    }
}
