import Foundation
import XCTest
@testable import Learner

@MainActor
final class LearnerTests: XCTestCase {
    func testGroupCardsRelationshipHasSingleGroupInverse() throws {
        let persistence = PersistenceController(inMemory: true)
        let context = persistence.container.viewContext
        let model = try XCTUnwrap(context.persistentStoreCoordinator?.managedObjectModel)
        let groupEntity = try XCTUnwrap(model.entitiesByName["GroupEntity"])
        let cardsRelationship = try XCTUnwrap(groupEntity.relationshipsByName["cards"])
        let groupRelationship = try XCTUnwrap(cardsRelationship.inverseRelationship)

        XCTAssertEqual(groupRelationship.name, "group")
        XCTAssertFalse(groupRelationship.isToMany)

        let firstGroup = GroupEntity(context: context)
        let secondGroup = GroupEntity(context: context)
        let card = CardEntity(context: context)
        firstGroup.addToCards(card)

        XCTAssertEqual(card.group, firstGroup)

        secondGroup.addToCards(card)

        XCTAssertEqual(card.group, secondGroup)
        XCTAssertFalse((firstGroup.cards as? Set<CardEntity>)?.contains(card) ?? false)
        XCTAssertTrue((secondGroup.cards as? Set<CardEntity>)?.contains(card) ?? false)
    }

    func testForwardQuizBehavior() async throws {
        let emptyQuiz = CardsQuizViewModel(category: category(cards: []))
        XCTAssertTrue(emptyQuiz.isCompleted)
        XCTAssertEqual(emptyQuiz.scoreTitle, "Fails: 0")
        XCTAssertEqual(emptyQuiz.progressText, "0 of 0")
        XCTAssertTrue(emptyQuiz.incorrectAnswers.isEmpty)

        let quiz = CardsQuizViewModel(category: category(cards: cards()))
        guard let card = quiz.currentCard else {
            XCTFail("Expected a current card")
            return
        }
        XCTAssertEqual(quiz.displayTitle, card.title)
        assertUniqueOptions(quiz.options, correctAnswer: card.translate)

        guard let incorrect = quiz.options.first(where: { $0 != card.translate }) else {
            XCTFail("Expected an incorrect answer option")
            return
        }
        quiz.selectOption(incorrect)
        XCTAssertEqual(quiz.currentCard?.id, card.id)
        XCTAssertFalse(quiz.isCorrect)
        XCTAssertEqual(quiz.incorrectAnswers.count, 1)
        XCTAssertEqual(quiz.incorrectAnswers[0].question, card.title)
        XCTAssertEqual(quiz.incorrectAnswers[0].correctAnswer, card.translate)

        quiz.selectOption("not an available option")
        XCTAssertEqual(quiz.selectedOption, incorrect)
        XCTAssertEqual(quiz.incorrectAnswers.count, 1)

        guard let secondIncorrect = quiz.options.first(where: { $0 != card.translate && $0 != incorrect }) else {
            XCTFail("Expected a second incorrect answer option")
            return
        }
        quiz.selectOption(secondIncorrect)
        XCTAssertEqual(quiz.incorrectAnswers.count, 1)
        XCTAssertEqual(quiz.incorrectAnswers.map(\.question), [card.title])
        XCTAssertEqual(quiz.incorrectAnswers[0].correctAnswer, card.translate)

        quiz.selectOption(card.translate)
        XCTAssertTrue(quiz.isCorrect)
        try await Task.sleep(nanoseconds: 2_100_000_000)
        XCTAssertEqual(quiz.progressText, "2 of 3")
        XCTAssertFalse(quiz.isCompleted)

        quiz.showNextCard()
        quiz.showNextCard()
        XCTAssertTrue(quiz.isCompleted)
        XCTAssertEqual(quiz.scoreTitle, "Fails: 2")
        XCTAssertEqual(quiz.incorrectAnswers.count, 1)
    }

    func testReverseQuizBehavior() async throws {
        let emptyQuiz = CardsQuizInvertViewModel(category: category(cards: []))
        XCTAssertTrue(emptyQuiz.isCompleted)
        XCTAssertEqual(emptyQuiz.scoreTitle, "Fails: 0")
        XCTAssertEqual(emptyQuiz.progressText, "0 of 0")
        XCTAssertTrue(emptyQuiz.incorrectAnswers.isEmpty)

        let quiz = CardsQuizInvertViewModel(category: category(cards: cards()))
        guard let card = quiz.currentCard else {
            XCTFail("Expected a current card")
            return
        }
        XCTAssertEqual(quiz.displayTitle, card.translate)
        assertUniqueOptions(quiz.options, correctAnswer: card.title)

        guard let incorrect = quiz.options.first(where: { $0 != card.title }) else {
            XCTFail("Expected an incorrect answer option")
            return
        }
        quiz.selectOption(incorrect)
        XCTAssertEqual(quiz.currentCard?.id, card.id)
        XCTAssertFalse(quiz.isCorrect)
        XCTAssertEqual(quiz.incorrectAnswers.count, 1)
        XCTAssertEqual(quiz.incorrectAnswers[0].question, card.translate)
        XCTAssertEqual(quiz.incorrectAnswers[0].correctAnswer, card.title)

        quiz.selectOption("not an available option")
        XCTAssertEqual(quiz.selectedOption, incorrect)
        XCTAssertEqual(quiz.incorrectAnswers.count, 1)

        guard let secondIncorrect = quiz.options.first(where: { $0 != card.title && $0 != incorrect }) else {
            XCTFail("Expected a second incorrect answer option")
            return
        }
        quiz.selectOption(secondIncorrect)
        XCTAssertEqual(quiz.incorrectAnswers.count, 1)
        XCTAssertEqual(quiz.incorrectAnswers.map(\.question), [card.translate])
        XCTAssertEqual(quiz.incorrectAnswers[0].correctAnswer, card.title)

        quiz.selectOption(card.title)
        XCTAssertTrue(quiz.isCorrect)
        try await Task.sleep(nanoseconds: 2_100_000_000)
        XCTAssertEqual(quiz.progressText, "2 of 3")
        XCTAssertFalse(quiz.isCompleted)

        quiz.showNextCard()
        quiz.showNextCard()
        XCTAssertTrue(quiz.isCompleted)
        XCTAssertEqual(quiz.scoreTitle, "Fails: 2")
        XCTAssertEqual(quiz.incorrectAnswers.count, 1)
    }

    func testQuizCanReturnToThePreviousCard() {
        let quiz = CardsQuizViewModel(category: category(cards: cards()))
        let firstCardID = quiz.currentCard?.id

        quiz.showPreviousCard()
        XCTAssertEqual(quiz.currentCard?.id, firstCardID)

        quiz.showNextCard()
        let secondCardID = quiz.currentCard?.id
        XCTAssertNotEqual(secondCardID, firstCardID)

        quiz.showPreviousCard()
        XCTAssertEqual(quiz.currentCard?.id, firstCardID)
        XCTAssertNil(quiz.selectedOption)
    }

    func testViewerCanReturnToThePreviousCardAndRecoverFromCompletion() {
        let viewer = CardsViewerViewModel(category: category(cards: cards()))
        let firstCardID = viewer.currentCard?.id

        viewer.showPreviousCard()
        XCTAssertEqual(viewer.currentCard?.id, firstCardID)

        viewer.showNextCard()
        let secondCardID = viewer.currentCard?.id
        XCTAssertNotEqual(secondCardID, firstCardID)

        viewer.showPreviousCard()
        XCTAssertEqual(viewer.currentCard?.id, firstCardID)

        viewer.showNextCard()
        viewer.showNextCard()
        viewer.showNextCard()
        XCTAssertNil(viewer.currentCard)
        viewer.showPreviousCard()
        XCTAssertNotNil(viewer.currentCard)
    }

    func testMixedLettersCanReturnToThePreviousWord() {
        let game = CardsMixedLettersViewModel(category: category(cards: cards()))
        let firstCardID = game.currentCard?.id

        game.showPreviousWord()
        XCTAssertEqual(game.currentCard?.id, firstCardID)

        game.showNextWord()
        let secondCardID = game.currentCard?.id
        XCTAssertNotEqual(secondCardID, firstCardID)

        game.selectLetter(game.letterOptions[0])
        game.showPreviousWord()
        XCTAssertEqual(game.currentCard?.id, firstCardID)
        XCTAssertEqual(game.currentWordIndex, 0)
        XCTAssertTrue(game.selectedLetters.flatMap { $0 }.allSatisfy { $0 == nil })
    }

    func testWordPairParserSupportsDelimitersAndPreservesLaterDelimiters() {
        let result = WordPairParser.parse("  word - translation - extra  \nleft; right\nthird\tthird translation\nfourth, fourth, extra\nfifth–fifth translation\nsixth—sixth translation\nseventh-seventh translation")

        guard result.count == 7 else {
            XCTFail("Expected seven valid word pairs")
            return
        }
        XCTAssertEqual(result[0].0, "word")
        XCTAssertEqual(result[0].1, "translation - extra")
        XCTAssertEqual(result[1].0, "left")
        XCTAssertEqual(result[1].1, "right")
        XCTAssertEqual(result[2].0, "third")
        XCTAssertEqual(result[2].1, "third translation")
        XCTAssertEqual(result[3].0, "fourth")
        XCTAssertEqual(result[3].1, "fourth, extra")
        XCTAssertEqual(result[4].0, "fifth")
        XCTAssertEqual(result[4].1, "fifth translation")
        XCTAssertEqual(result[5].0, "sixth")
        XCTAssertEqual(result[5].1, "sixth translation")
        XCTAssertEqual(result[6].0, "seventh")
        XCTAssertEqual(result[6].1, "seventh translation")
    }

    func testWordPairParserRejectsMissingOrEmptyValues() {
        XCTAssertTrue(WordPairParser.parse("missing delimiter\n - value\nkey -   \n").isEmpty)
    }

    func testImportedWordSetsPersistAndKeepTheirWordPairs() throws {
        let suiteName = "ImportedWordSetStoreTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let oldSet = importedSet(date: Date(timeIntervalSince1970: 100), word: "old", translation: "старый")
        let newSet = importedSet(date: Date(timeIntervalSince1970: 200), word: "new", translation: "новый")
        let store = ImportedWordSetStore(userDefaults: defaults)
        try store.save(oldSet)
        try store.save(newSet)

        let reloadedSets = try ImportedWordSetStore(userDefaults: defaults).load()
        XCTAssertEqual(reloadedSets.map(\.id), [newSet.id, oldSet.id])
        XCTAssertEqual(reloadedSets[0].category.list.first?.title, "new")
        XCTAssertEqual(reloadedSets[0].category.list.first?.translate, "новый")
        XCTAssertEqual(reloadedSets[0].preview, "new — новый")
        XCTAssertEqual(reloadedSets[0].displayName, "new — новый")
        XCTAssertNil(reloadedSets[0].name)
    }

    func testImportedWordSetCanBeRenamedAndRestoredToItsDefaultName() throws {
        let suiteName = "ImportedWordSetRenameTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let original = importedSet(date: Date(timeIntervalSince1970: 300), word: "hello", translation: "привет")
        let store = ImportedWordSetStore(userDefaults: defaults)
        try store.save(original)

        try store.rename(id: original.id, to: "  Travel words  ")

        var savedSet = try XCTUnwrap(store.load().first)
        XCTAssertEqual(savedSet.name, "Travel words")
        XCTAssertEqual(savedSet.displayName, "Travel words")
        XCTAssertEqual(savedSet.importedAt, original.importedAt)
        XCTAssertEqual(savedSet.category.list, original.category.list)

        try store.rename(id: original.id, to: " \n  ")
        savedSet = try XCTUnwrap(ImportedWordSetStore(userDefaults: defaults).load().first)
        XCTAssertNil(savedSet.name)
        XCTAssertEqual(savedSet.displayName, "hello — привет")
        XCTAssertEqual(savedSet.category.list, original.category.list)
    }

    func testImportedWordSetsSavedBeforeNamesWereAddedStillLoad() throws {
        let suiteName = "LegacyImportedWordSetTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let legacySet = importedSet(date: Date(timeIntervalSince1970: 400), word: "book", translation: "книга")
        let legacyData = try JSONEncoder().encode([
            LegacyImportedWordSetFixture(id: legacySet.id, importedAt: legacySet.importedAt, category: legacySet.category)
        ])
        defaults.set(legacyData, forKey: "importedWordSets")

        let loadedSet = try XCTUnwrap(ImportedWordSetStore(userDefaults: defaults).load().first)
        XCTAssertNil(loadedSet.name)
        XCTAssertEqual(loadedSet.displayName, "book — книга")
        XCTAssertEqual(loadedSet.category.list, legacySet.category.list)
    }

    func testImportedWordSetCanBeDeleted() throws {
        let suiteName = "ImportedWordSetDeletionTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let retainedSet = importedSet(date: Date(timeIntervalSince1970: 100), word: "keep", translation: "оставить")
        let deletedSet = importedSet(date: Date(timeIntervalSince1970: 200), word: "remove", translation: "удалить")
        let store = ImportedWordSetStore(userDefaults: defaults)
        try store.save(retainedSet)
        try store.save(deletedSet)

        try store.delete(id: deletedSet.id)

        XCTAssertEqual(try store.load().map(\.id), [retainedSet.id])
    }

    func testSharedImportRequestIsConsumedOnlyOnce() throws {
        let suiteName = "SharedImportRequestStoreTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let importURL = URL(fileURLWithPath: "/tmp/sharedData.txt")
        defaults.set(importURL.absoluteString, forKey: "IMPORT_PATH")
        let store = SharedImportRequestStore(userDefaults: defaults)

        XCTAssertEqual(store.takePendingURL(), importURL)
        XCTAssertNil(store.takePendingURL())
    }

    func testNavigationBackReturnsOneRouteAtATimeForMainCategoryStudy() throws {
        let appIntent = try makeAppIntent()
        let selectedCategory = category(cards: cards())
        let categoryOptions = AppScreen.categoryOption(category: selectedCategory)
        let quiz = AppScreen.detail(category: selectedCategory, selectedInteraction: .quiz)

        appIntent.selectMainCategory(selectedCategory)
        XCTAssertEqual(appIntent.currentScreen, categoryOptions)
        appIntent.navigate(to: quiz)
        XCTAssertEqual(appIntent.currentScreen, quiz)
        XCTAssertEqual(appIntent.navigationBackTitle, selectedCategory.title)

        appIntent.navigateBack()
        XCTAssertEqual(appIntent.currentScreen, categoryOptions)
        XCTAssertEqual(appIntent.navigationPath, [categoryOptions])
        XCTAssertEqual(appIntent.navigationBackTitle, "Categories")

        appIntent.navigateBack()
        XCTAssertEqual(appIntent.currentScreen, .home)
        XCTAssertTrue(appIntent.navigationPath.isEmpty)
    }

    func testNavigationBackReturnsThroughImportedSetToImportedWords() throws {
        let appIntent = try makeAppIntent()
        let wordSet = importedSet(date: Date(), word: "hello", translation: "привет")
        let categoryOptions = AppScreen.categoryOption(category: wordSet.category)
        let quiz = AppScreen.detail(category: wordSet.category, selectedInteraction: .quiz)

        appIntent.navigateToRoot(.imports)
        appIntent.selectImportedWordSet(wordSet)
        appIntent.navigate(to: quiz)

        appIntent.navigateBack()
        XCTAssertEqual(appIntent.currentScreen, categoryOptions)
        appIntent.navigateBack()
        XCTAssertEqual(appIntent.currentScreen, .imports)
        XCTAssertEqual(appIntent.navigationBackTitle, "Categories")
        appIntent.navigateBack()
        XCTAssertEqual(appIntent.currentScreen, .home)
        XCTAssertTrue(appIntent.navigationPath.isEmpty)

        appIntent.navigateToRoot(.imports)
        appIntent.selectMainCategory(wordSet.category)
        XCTAssertEqual(appIntent.navigationPath, [categoryOptions])
        XCTAssertEqual(appIntent.navigationBackTitle, "Categories")
    }

    func testNavigationPathUpdatesCurrentScreenWhenNativeStackPops() throws {
        let appIntent = try makeAppIntent()
        let selectedCategory = category(cards: cards())
        let categoryOptions = AppScreen.categoryOption(category: selectedCategory)
        let quiz = AppScreen.detail(category: selectedCategory, selectedInteraction: .quiz)

        appIntent.setNavigationPath([categoryOptions, quiz])
        XCTAssertEqual(appIntent.currentScreen, quiz)

        appIntent.setNavigationPath([categoryOptions])
        XCTAssertEqual(appIntent.currentScreen, categoryOptions)

        appIntent.setNavigationPath([])
        XCTAssertEqual(appIntent.currentScreen, .home)
    }

    private func assertUniqueOptions(_ options: [String], correctAnswer: String, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertTrue(options.contains(correctAnswer), file: file, line: line)
        XCTAssertEqual(Set(options).count, options.count, file: file, line: line)
        XCTAssertLessThanOrEqual(options.count, 3, file: file, line: line)
    }

    private func category(cards: [ModelCard]) -> CategoryModel {
        CategoryModel(id: 1, title: "Test", picture: "", order: 0, list: cards)
    }

    private func cards() -> [ModelCard] {
        [
            ModelCard(id: 1, categoryId: 1, title: "One", translate: "Uno", localCode: "en", picture: nil, voice: nil, transcription: nil),
            ModelCard(id: 2, categoryId: 1, title: "Two", translate: "Dos", localCode: "en", picture: nil, voice: nil, transcription: nil),
            ModelCard(id: 3, categoryId: 1, title: "Three", translate: "Tres", localCode: "en", picture: nil, voice: nil, transcription: nil)
        ]
    }

    private func importedSet(date: Date, word: String, translation: String) -> ImportedWordSet {
        let card = ModelCard(id: 1, categoryId: 1001, title: word, translate: translation, localCode: "en", picture: nil, voice: nil, transcription: nil)
        let category = CategoryModel(id: 1001, title: "Imported words", picture: "", order: 0, list: [card])
        return ImportedWordSet(id: UUID(), importedAt: date, category: category)
    }

    private func makeAppIntent() throws -> AppIntent {
        let persistence = PersistenceController(inMemory: true)
        let localDataSource = LocalDataSourceImpl(context: persistence.container.viewContext)
        let suiteName = "NavigationTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        let store = ImportedWordSetStore(userDefaults: defaults)
        return AppIntent(
            localDatasource: localDataSource,
            remoteDatasource: EmptyRemoteDataSource(),
            importedWordSetStore: store
        )
    }

}

private struct EmptyRemoteDataSource: RemoteDataSource {
    func fetchCards(url: String) async throws -> CardResponse {
        CardResponse(version: 1, lang: "en", list: [])
    }

    func fetchCategories(url: String) async throws -> CategoryResponse {
        CategoryResponse(lang: "en", version: 1, list: [])
    }
}

private struct LegacyImportedWordSetFixture: Encodable {
    let id: UUID
    let importedAt: Date
    let category: CategoryModel
}
