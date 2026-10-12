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
                } else if currentScreen == .settings {
                    MainScreenContentView(appIntent: appIntent, currentScreen: currentScreen)
                } else {
                    MainScreenContentView(appIntent: appIntent, currentScreen: currentScreen)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button {
                                    appIntent.navigateBack()
                                } label: {
                                    Image(systemName: "chevron.backward")
                                        .frame(width: 44, height: 44)
                                        .contentShape(Rectangle())
                                }
                                .accessibilityLabel(appIntent.navigationBackTitle)
                                .buttonStyle(.plain)
                            }
                        }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onReceive(appIntent.$currentScreen) { currentScreen = $0 }
    }
}
