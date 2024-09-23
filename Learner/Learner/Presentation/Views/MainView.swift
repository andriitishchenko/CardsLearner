import SwiftUI
import Combine

struct MainView: View {
    private var appIntent: AppIntent
    @State var onButtonClick: Int? = nil
    @State private var isPushed = false
    @State var columnVisibility: NavigationSplitViewVisibility = .doubleColumn
    
    @State var appScreen: AppScreen = .home
    
    init(appIntent: AppIntent) {
        self.appIntent = appIntent
    }
    
    var body: some View{
        NavigationSplitView(
            columnVisibility: $columnVisibility
        ) {
            ScrollView(){
                let vm = SelectCategoryViewModel(appIntent: self.appIntent)
                SelectCategoryScreen(viewModel: vm)
            }
            Spacer()

            Button() {
                onButtonClick = 1
            }
            label: {
                Label("Settings", systemImage: "gear")
            }
            
            List(selection: $onButtonClick){}.frame(height: 0)
            .onChange(of: onButtonClick,initial: false) { (newValue, i) in
                    appIntent.navigate(to: .settings)
            }
            .navigationTitle("Categories")
        
            .toolbar {
            }
            
        } detail: {
            NavigationStack {
                switch appScreen {
                    
                case .settings:
                    let vm = SelectLanguageViewModel(appIntent: self.appIntent)
                    SelectLanguageScreen(viewModel: vm)
                    
                case .detail(let category):
                    let vm = CardsViewerViewModel(appIntent: self.appIntent, category: category)
                    CardsViewerScreen(viewModel: vm)
                    
                default:(
                    Text("Select a category or open settings")
                        .foregroundColor(.gray))
                }
            }
        }
        .navigationSplitViewStyle(.balanced)
        .onReceive(appIntent.$currentScreen) { val in
            appScreen = val
        }
        
    }
}
