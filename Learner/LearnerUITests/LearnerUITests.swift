//
//  LearnerUITests.swift
//  LearnerUITests
//
//  Created by Andrii Tishchenko on 2024-09-18.
//

import XCTest

final class LearnerUITests: XCTestCase {
    
    var app:XCUIApplication!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

  
  //////////////////
  
  
  
  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
      app = XCUIApplication()
        Task{
            await setupSnapshot(app, waitForAnimations: true)
            await app.launch()
        }
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    continueAfterFailure = false

    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
    @MainActor func testScreenshots() {
    XCUIDevice.shared.orientation = .portrait
    
    let delayExpectation = expectation(description: "Waiting ...")
    DispatchQueue.main.asyncAfter(deadline: .now()) {
        while !self.app.buttons["Colors"].exists {
            sleep(1)
        }
        delayExpectation.fulfill()
        
    }
    waitForExpectations(timeout: 60)
        
    
    
//    let tabBarsQuery = XCUIApplication().tabBars
//    tabBarsQuery.buttons.element(boundBy: 0).tap()
//    app.windows.scrollViews.element.pinch(withScale: 20, velocity: 10)
    snapshot("0")
        
    app.buttons["Colors"].tap()
    snapshot("1")
        
    app.buttons["Card Viewer"].tap()
    snapshot("2")
    app.buttons["Categories"].tap()
        
    app.buttons["Colors"].tap()
    app.buttons["Quiz Mode"].tap()
    snapshot("3")
    app.buttons["Categories"].tap()
    
    app.buttons["Colors"].tap()
    app.buttons["Quiz Inverted"].tap()
    snapshot("4")
    app.buttons["Categories"].tap()
    
        
    
    

    
//    app.windows.scrollViews.element.swipeLeft()
//    app.windows.scrollViews.element.swipeLeft()
//    tabBarsQuery.buttons.element(boundBy: 1).tap()
//    snapshot("1")
//    
  




    //tap the first cell
//    let firstCell = app.tables.cells.element(boundBy: 0)
//    firstCell.tap()
//    snapshot("2")
    
    
    //tap the first cell
//    let dCell = app.tables.cells.element(boundBy: 0)
//    dCell.tap()
//    snapshot("3")
    
    
    
    
    
    
//    tabBarsQuery.buttons.element(boundBy: 2).tap()
    
    //swipe the first cell
//    let sCell = app.tables.cells.element(boundBy: 0)
//    sCell.swipeRight()
    
//    tabBarsQuery.buttons.element(boundBy: 1).waitForExistence(timeout: 4)
    //        app.otherElements["eventlocation"].tap()
//    snapshot("4")
    //
    //        // Twitter
    //        tabBarsQuery.buttons.element(boundBy: 2).tap()
    //        snapshot("map")
  }

//
//    func testLaunchPerformance() throws {
//        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
//            // This measures how long it takes to launch your application.
//            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
//                XCUIApplication().launch()
//            }
//        }
//    }
}
