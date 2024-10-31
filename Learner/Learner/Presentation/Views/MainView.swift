import SwiftUI
import Combine

struct MainView: View {
    private var appIntent: AppIntent
    @State var onButtonClick: Int? = nil
    @State private var isPushed = false
    @State var columnVisibility: NavigationSplitViewVisibility = .doubleColumn
    
    @State var appScreen: AppScreen = .home
    @State private var isImporting: Bool = false
    
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
            
            HStack(alignment: .center) {
                Button() {
                    onButtonClick = 1
                }
                label: {
                    Label("Settings", systemImage: "gear")
                }
                Text("|")
                Button(action: {
                  isImporting = true
                }, label: {
                    Label("Import", systemImage: "square.and.arrow.down")
                })
                .fileImporter(isPresented: $isImporting,
                              allowedContentTypes: [.plainText, .utf8PlainText, .delimitedText, .commaSeparatedText, .tabSeparatedText],
                  onCompletion: { result in
                                
                  switch result {
                  case .success(let file):
                    let gotAccess = file.startAccessingSecurityScopedResource()
                    if !gotAccess { return }
                    self.appIntent.handleImport(file: file)
                    file.stopAccessingSecurityScopedResource()
                  case .failure(let error):
                    print(error)
                  }
                })
            }
                        
            List(selection: $onButtonClick){}.frame(height: 0)
            .onChange(of: onButtonClick) { newValue in
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
                    case .mixedLetters:
                        let vm = CardsMixedLettersViewModel(appIntent: self.appIntent, category: category)
                        CardsMixedLettersView(viewModel: vm)
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
