import Foundation
import XCTest
@testable import Learner

@MainActor
final class LearnerTests: XCTestCase {
    func testForwardQuizBehavior() async throws {
        let emptyQuiz = CardsQuizViewModel(category: category(cards: []))
        XCTAssertTrue(emptyQuiz.isCompleted)
        XCTAssertEqual(emptyQuiz.scoreTitle, "Fails: 0")
        XCTAssertEqual(emptyQuiz.progressText, "0 of 0")

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

        quiz.selectOption("not an available option")
        XCTAssertEqual(quiz.selectedOption, incorrect)

        quiz.selectOption(card.translate)
        XCTAssertTrue(quiz.isCorrect)
        try await Task.sleep(for: .seconds(2.1))
        XCTAssertEqual(quiz.progressText, "2 of 3")
        XCTAssertFalse(quiz.isCompleted)

        quiz.showNextCard()
        quiz.showNextCard()
        XCTAssertTrue(quiz.isCompleted)
        XCTAssertEqual(quiz.scoreTitle, "Fails: 1")
    }

    func testReverseQuizBehavior() async throws {
        let emptyQuiz = CardsQuizInvertViewModel(category: category(cards: []))
        XCTAssertTrue(emptyQuiz.isCompleted)
        XCTAssertEqual(emptyQuiz.scoreTitle, "Fails: 0")
        XCTAssertEqual(emptyQuiz.progressText, "0 of 0")

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

        quiz.selectOption("not an available option")
        XCTAssertEqual(quiz.selectedOption, incorrect)

        quiz.selectOption(card.title)
        XCTAssertTrue(quiz.isCorrect)
        try await Task.sleep(for: .seconds(2.1))
        XCTAssertEqual(quiz.progressText, "2 of 3")
        XCTAssertFalse(quiz.isCompleted)

        quiz.showNextCard()
        quiz.showNextCard()
        XCTAssertTrue(quiz.isCompleted)
        XCTAssertEqual(quiz.scoreTitle, "Fails: 1")
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

    func testStudyReturnDestinationPreservesTheCategorySource() {
        XCTAssertEqual(StudyReturnDestination.categories.screen, .home)
        XCTAssertEqual(StudyReturnDestination.categories.title, "Categories")
        XCTAssertEqual(StudyReturnDestination.importedSets.screen, .imports)
        XCTAssertEqual(StudyReturnDestination.importedSets.title, "Imported words")
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

}
