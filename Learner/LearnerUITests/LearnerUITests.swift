import XCTest

final class LearnerUITests: XCTestCase {
    @MainActor
    func testScreenshots() {
        let app = XCUIApplication()
        setupSnapshot(app, waitForAnimations: true)
        app.launch()
        XCUIDevice.shared.orientation = .portrait

        let settingsButton = app.buttons["Settings"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 30), "The categories screen should show Settings")
        snapshot("0")

        settingsButton.tap()
        XCTAssertTrue(app.navigationBars["Select Language"].waitForExistence(timeout: 10))
        snapshot("1")

        let categoriesButton = app.buttons["Categories"]
        XCTAssertTrue(categoriesButton.waitForExistence(timeout: 10), "Settings should provide a return action to categories")
        categoriesButton.tap()

        let importsButton = app.buttons["Imported words"]
        XCTAssertTrue(importsButton.waitForExistence(timeout: 10), "The categories screen should show Imported words")
        importsButton.tap()
        XCTAssertTrue(app.navigationBars["Imported words"].waitForExistence(timeout: 10))
    }
}
