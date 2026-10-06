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
                    CategorySidebarView(appIntent: appIntent)
                } else {
                    MainScreenContentView(appIntent: appIntent, currentScreen: currentScreen)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button {
                                    appIntent.navigateBack()
                                } label: {
                                    Label(appIntent.navigationBackTitle, systemImage: "chevron.backward")
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
