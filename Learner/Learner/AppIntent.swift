import Combine
import Foundation

struct ImportedWordSet: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    let importedAt: Date
    let category: CategoryModel

    var preview: String {
        guard let firstCard = category.list.first else { return "" }
        return "\(firstCard.title) — \(firstCard.translate)"
    }
}

enum StudyReturnDestination: Equatable {
    case categories
    case importedSets

    var screen: AppScreen {
        switch self {
        case .categories: .home
        case .importedSets: .imports
        }
    }

    var title: String {
        switch self {
        case .categories: "Categories"
        case .importedSets: "Imported words"
        }
    }
}

@MainActor
final class ImportedWordSetStore {
    private let userDefaults: UserDefaults
    private let storageKey = "importedWordSets"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func load() throws -> [ImportedWordSet] {
        guard let data = userDefaults.data(forKey: storageKey) else { return [] }
        return try JSONDecoder().decode([ImportedWordSet].self, from: data)
            .sorted { $0.importedAt > $1.importedAt }
    }

    func save(_ wordSet: ImportedWordSet) throws {
        var wordSets = try load()
        wordSets.removeAll { $0.id == wordSet.id }
        wordSets.insert(wordSet, at: 0)
        userDefaults.set(try JSONEncoder().encode(wordSets), forKey: storageKey)
    }

    func delete(id: UUID) throws {
        var wordSets = try load()
        wordSets.removeAll { $0.id == id }
        userDefaults.set(try JSONEncoder().encode(wordSets), forKey: storageKey)
    }
}

struct SharedImportRequestStore {
    private let userDefaults: UserDefaults
    private let storageKey = "IMPORT_PATH"

    init(userDefaults: UserDefaults = UserDefaults(suiteName: "group.at.flashcards") ?? .standard) {
        self.userDefaults = userDefaults
    }

    func takePendingURL() -> URL? {
        guard let path = userDefaults.string(forKey: storageKey) else { return nil }
        userDefaults.removeObject(forKey: storageKey)
        return URL(string: path)
    }
}

protocol Intent: ObservableObject{}

@MainActor
class AppIntent: Intent {
    @Published var navigationPath: [AppScreen] = []
    @Published var errorMessage: String?
    @Published var list:[CategoryModel] = []
    @Published private(set) var importedWordSets: [ImportedWordSet] = []
    @Published var currentScreen: AppScreen = .home
    @Published var isLoading = false
    private(set) var studyReturnDestination: StudyReturnDestination = .categories

    var navigationReturnDestination: StudyReturnDestination {
        currentScreen == .imports ? .categories : studyReturnDestination
    }
        
    let userSettings:UserSettingsUseCase
    let localDatasource: LocalDataSource
    let remoteDatasource: RemoteDataSource
    private let importedWordSetStore: ImportedWordSetStore

    init(navigationPath: [AppScreen] = [],
         errorMessage: String? = nil,
         localDatasource: LocalDataSource,
         remoteDatasource: RemoteDataSource,
         importedWordSetStore: ImportedWordSetStore = ImportedWordSetStore()) {
        
        self.navigationPath = navigationPath
        self.errorMessage = errorMessage
        
        self.localDatasource = localDatasource
        self.remoteDatasource = remoteDatasource
        self.importedWordSetStore = importedWordSetStore

        do {
            self.importedWordSets = try importedWordSetStore.load()
        } catch {
            self.errorMessage = "Unable to load imported word sets: \(error.localizedDescription)"
        }
                
        let userDefaultsReposit = UserDefaultsRepositoryImpl()
        self.userSettings = UserSettingsUseCaseImpl(userDefaultsRepository: userDefaultsReposit)
        
        Task{
            await forceFetching()
        }
    }
    
    func forceFetching(isForce:Bool = false) async{
        isLoading = true
        
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
        }
        isLoading = false
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
            
            await self.downloadImages(list)
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
        }catch {
            errorMessage = "\(error.localizedDescription)"
        }
    }
                                                                         
    private func saveFetchedData(_ list: [CategoryModel]) async throws {
        let localRepository = LocalDataRepositoryImpl(localDataSource: self.localDatasource)
        let localDataProcessor = LocalDataProcessingUseCaseImpl(localRepository: localRepository)
        try localDataProcessor.validate(data: list)
        try await localDataProcessor.cleanup()
        try await localDataProcessor.executeSave(data: list)
    }
    
    private func downloadImages(_ list: [CategoryModel]) async {
        let imageURLs = list.flatMap { category in
            [category.picture] + category.list.compactMap(\.picture)
        }

        for startIndex in stride(from: 0, to: imageURLs.count, by: 8) {
            let endIndex = min(startIndex + 8, imageURLs.count)
            let batch = imageURLs[startIndex..<endIndex]
            await withTaskGroup(of: Void.self) { group in
                for url in batch {
                    group.addTask {
                        _ = await downloadFileDataTask(urlString: url)
                    }
                }
                await group.waitForAll()
            }
        }
    }
        
    func navigate(to screen: AppScreen) {
        isLoading = false
        navigationPath.append(screen)
        self.currentScreen = screen
    }
    
    func navigateBack() {
        guard !navigationPath.isEmpty else { return }
        navigationPath.removeLast()
        currentScreen = navigationPath.last ?? .home
    }

    func selectMainCategory(_ category: CategoryModel) {
        studyReturnDestination = .categories
        navigate(to: .categoryOption(category: category))
    }

    func clearNavigation() {
        navigationPath.removeAll()
        currentScreen = navigationReturnDestination.screen
    }
        
    func handleImport(file: URL){
        
        let strLang = list.lazy.compactMap { $0.list.first?.localCode }.first ?? "en"
        
        if let test1 = getQueryStringParameter(url: file.absoluteString, param: "importFile"){
            if let u = URL(string: test1), u != file, u.isFileURL {
                handleImportContents(file: u, language: strLang)
            }
            return
        }

        guard file.isFileURL else { return }
        handleImportContents(file: file, language: strLang)
    }

    private func handleImportContents(file: URL, language strLang: String) {
        isLoading = true
        guard let pairs = parseFileToWordPairs(file: file), !pairs.isEmpty else {
            errorMessage = "The selected file contains no valid word pairs."
            isLoading = false
            return
        }

        saveImportedWordSet(pairs: pairs, language: strLang)
        isLoading = false
    }

    func importFromURL(_ address: String) async {
        isLoading = true
        defer { isLoading = false }

        guard let url = URL(string: address.trimmingCharacters(in: .whitespacesAndNewlines)),
              ["http", "https"].contains(url.scheme?.lowercased() ?? "") else {
            errorMessage = "Enter a valid http or https URL."
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let response = response as? HTTPURLResponse,
                  (200..<300).contains(response.statusCode),
                  let text = String(data: data, encoding: .utf8) else {
                errorMessage = "The URL did not return readable text."
                return
            }
            importText(text)
        } catch {
            errorMessage = "Unable to import from this URL: \(error.localizedDescription)"
        }
    }

    func importText(_ text: String) {
        let pairs = WordPairParser.parse(text)
        guard !pairs.isEmpty else {
            errorMessage = "No valid word pairs were found."
            return
        }
        let language = list.lazy.compactMap { $0.list.first?.localCode }.first ?? "en"
        saveImportedWordSet(pairs: pairs, language: language)
    }

    func selectImportedWordSet(_ wordSet: ImportedWordSet) {
        studyReturnDestination = .importedSets
        navigate(to: .categoryOption(category: wordSet.category))
    }

    func deleteImportedWordSet(_ wordSet: ImportedWordSet) {
        do {
            try importedWordSetStore.delete(id: wordSet.id)
            importedWordSets.removeAll { $0.id == wordSet.id }
        } catch {
            errorMessage = "Unable to delete imported word set: \(error.localizedDescription)"
        }
    }

    private func saveImportedWordSet(pairs: [(String, String)], language: String) {
        var cards: [ModelCard] = []
        let categoryID = Self.uniqueCategoryID()
        for (index, pair) in pairs.enumerated() {
            let latinString = pair.0.lowercased().applyingTransform(StringTransform.toLatin, reverse: false)
            let noDiacriticString = latinString?.applyingTransform(StringTransform.stripDiacritics, reverse: false) ?? ""
            cards.append(ModelCard(id: index + 1,
                                   categoryId: categoryID,
                                   title: pair.0,
                                   translate: pair.1,
                                   localCode: language,
                                   picture: nil,
                                   voice: nil,
                                   transcription: "[\(noDiacriticString)]"))
        }

        let pictureURL = Bundle.main.url(forResource: "notes", withExtension: "png")?.absoluteString ?? ""
        let category = CategoryModel(id: categoryID, title: "Imported words", picture: pictureURL, order: 0, list: cards)
        let wordSet = ImportedWordSet(id: UUID(), importedAt: Date(), category: category)
        do {
            try importedWordSetStore.save(wordSet)
            importedWordSets.insert(wordSet, at: 0)
            errorMessage = nil
        } catch {
            errorMessage = "Unable to save imported word pairs: \(error.localizedDescription)"
        }
    }

    private static func uniqueCategoryID() -> Int {
        let uuidPrefix = String(UUID().uuidString.prefix(8))
        let randomPart = Int(uuidPrefix, radix: 16) ?? 0
        return 1_000_000_000 + randomPart % 1_000_000_000
    }
}
