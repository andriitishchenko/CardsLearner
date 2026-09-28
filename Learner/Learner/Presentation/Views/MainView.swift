import SwiftUI

struct MainView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private let appIntent: AppIntent

    init(appIntent: AppIntent) {
        self.appIntent = appIntent
    }

    @ViewBuilder
    var body: some View {
        if #available(iOS 16.0, *), horizontalSizeClass == .regular {
            ModernNavigationContainer(appIntent: appIntent)
        } else {
            LegacyNavigationContainer(appIntent: appIntent)
        }
    }
}
