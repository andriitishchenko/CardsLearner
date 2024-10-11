import SwiftUI
import Combine


protocol Intent: ObservableObject{}

@MainActor
class AppIntent: Intent {
    @Published var navigationPath = NavigationPath()
    @Published var errorMessage: String?
    @Published var list:[CategoryModel] = []
    @Published var currentScreen: AppScreen = .home
    @Published var isLoading = false
        
    let userSettings:UserSettingsUseCase
    let localDatasource: LocalDataSource
    let remoteDatasource: RemoteDataSource

    init(navigationPath: NavigationPath = NavigationPath(),
         errorMessage: String? = nil,
         localDatasource: LocalDataSource,
         remoteDatasource: RemoteDataSource) {
        
        self.navigationPath = navigationPath
        self.errorMessage = errorMessage
        
        self.localDatasource = localDatasource
        self.remoteDatasource = remoteDatasource
                
        let userDefaultsReposit = UserDefaultsRepositoryImpl()
        self.userSettings = UserSettingsUseCaseImpl(userDefaultsRepository: userDefaultsReposit)
        
        Task{
            await forceFetching()
        }
    }
    
    func forceFetching(isForce:Bool = false) async{
        await MainActor.run {
            isLoading = true
        }
        
        if (isForce){
            print("Fetch")
            await self.fetchData()
            await self.loadLocalData()
        }else{
            
            await self.loadLocalData()
            
            if (self.list.isEmpty){
                print("Fetch")
                await self.fetchData()
                await self.loadLocalData()
            }
            else{
                await MainActor.run {
                    print("Loaded")
                    self.navigate(to: .list)
                }
            }
        }
        await MainActor.run {
            isLoading = false
        }
    }
    
    func updateUserSettings(origin:String, cards:String) {
        Task {
            let us = UserSettings(originURL: origin, learnURL: cards)
            do {
                try await userSettings.executeSave(settings: us)
                await forceFetching(isForce: true)
            } catch {
                errorMessage = "\(error.localizedDescription)"
            }
        }
    }
    
    func getUserSettings() async -> UserSettings? {
        do{
            let us =  try await self.userSettings.executeLoad()
            return us
        }
        catch {
            errorMessage = "E: \(error.localizedDescription)"
        }
        return nil
    }
    
    private func fetchData() async {
        do {
            let us = try await self.userSettings.executeLoad()
            let remoterep = RemoteDataRepositoryImpl(remoteDataSource: self.remoteDatasource)
            let aggragate = AggregateDataUseCaseImpl(settings: us, remoteRepository: remoterep)

            let list = try await aggragate.execute()
            try await self.saveFetchedData(list)
            
            try await self.downloadImages(list)
            isLoading = false
        } catch {
            errorMessage = "E: \(error.localizedDescription)"
        }
    }
    
    @MainActor
    private func loadLocalData() async {
        let localRepository = LocalDataRepositoryImpl(localDataSource: self.localDatasource)
        let localDataProcessor = LocalDataProcessingUseCaseImpl(localRepository: localRepository)
        do{
            self.list = try await localDataProcessor.executeLoad()
            isLoading = false
        }catch {
            errorMessage = "\(error.localizedDescription)"
        }
    }
                                                                         
    private func saveFetchedData(_ list: [CategoryModel]) async throws {
        let localRepository = LocalDataRepositoryImpl(localDataSource: self.localDatasource)
        let localDataProcessor = LocalDataProcessingUseCaseImpl(localRepository: localRepository)
        do{
            try await localDataProcessor.cleanup()
            try await localDataProcessor.executeSave(data: list)
        }catch {
            errorMessage = "\(error.localizedDescription)"
        }
    }
    
    private func downloadImages(_ list: [CategoryModel]) async throws {
        DispatchQueue.global(qos: .background).async {
            for category in list {
                Task{
                    _ = await downloadFileDataTask(urlString: category.picture)
                }
                for card in category.list {
                    Task{
                        _ = await downloadFileDataTask(urlString: card.picture ?? "")
                    }
                }
            }
        }
    }
        
    func navigate(to screen: AppScreen) {
        isLoading = false
        navigationPath.append(screen)
        self.currentScreen = screen
    }
    
    func navigateBack() {
        navigationPath.removeLast()
    }
    
    func clearNavigation() {
        navigationPath.removeLast(navigationPath.count)
    }
}

