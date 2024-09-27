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
                    
                case .categoryOption(let category):
                    // Show the options to select the interaction type
                    InteractionOptionScreen(category: category) { selectedOption in
                        handleSelectedOption(selectedOption, category: category)
                    }
                    
                case .detail(let category, let selectedInteraction):
                    // Load the selected interaction view
                    switch selectedInteraction {
                    case .quiz:
                        let vm = CardsQuizViewModel(appIntent: self.appIntent, category: category)
                        CardsQuizScreen(viewModel: vm)
                    case .viewer:
                        let vm = CardsViewerViewModel(appIntent: self.appIntent, category: category)
                        CardsViewerScreen(viewModel: vm)
                    case .quizInvert:
                        let vm = CardsQuizInvertViewModel(appIntent: self.appIntent, category: category)
                        CardsQuizScreen(viewModel: vm)
                    }
                    
                default:
                    Text("Select a category or open settings")
                        .foregroundColor(.gray)
                }
            }
            
            
            
            
        }
        .navigationSplitViewStyle(.balanced)
        .onReceive(appIntent.$currentScreen) { val in
            appScreen = val
        }
    }

    // Handle the interaction type selected by the user
    private func handleSelectedOption(_ selectedOption: InteractionType, category: CategoryModel) {
        appScreen = .detail(category: category, selectedInteraction: selectedOption)
    }
}
