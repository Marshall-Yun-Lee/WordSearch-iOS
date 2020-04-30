//
//  WordSearchUITests.swift
//  WordSearchUITests
//
//  Created by Marshall Lee on 2020-04-24.
//  Copyright © 2020 Marshall Lee. All rights reserved.
//

import XCTest

class WordSearchUITests: XCTestCase {
     let app = XCUIApplication()

       func testUI() throws {
        app.launch()
        
        let app = XCUIApplication()
        let startButton = app.buttons["START"]
        startButton.tap()
        
        let arrowLeftButton = app.buttons["arrow.left"]
        arrowLeftButton.tap()
        startButton.tap()
        
        // word list validation
        app.buttons["ellipsis"].tap()
        XCTAssertTrue(app.staticTexts["WORD LIST"].exists)
        XCTAssertTrue(app.staticTexts["Swift"].exists)
        XCTAssertTrue(app.staticTexts["Kotlin"].exists)
        XCTAssertTrue(app.staticTexts["ObjectiveC"].exists)
        XCTAssertTrue(app.staticTexts["Variable"].exists)
        XCTAssertTrue(app.staticTexts["Java"].exists)
        XCTAssertTrue(app.staticTexts["Mobile"].exists)
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element(boundBy: 0).swipeDown()
        app.swipeDown()
        XCTAssertFalse(app.staticTexts["WORD LIST"].exists)
        
        // hint button validation
        app.buttons["HINT(5)"].tap()
        app.buttons["HINT(4)"].tap()
        app.buttons["HINT(3)"].tap()
        app.buttons["HINT(2)"].tap()
        app.buttons["HINT(1)"].tap()
        app.buttons["HINT(0)"].tap()
        app.buttons["RESET"].tap()
        
        
        XCTAssertTrue(app.buttons["HINT(5)"].exists)
        
        // wait for time out
        sleep(70)
        app.buttons["RETRY"].tap()
        XCTAssertTrue(app.buttons["HINT(5)"].exists)
        // still in game view
        arrowLeftButton.tap()
        
        // back to main view
        XCTAssertTrue(app.buttons["START"].exists)
        XCTAssertTrue(app.buttons["CREDIT"].exists)
        app.buttons["CREDIT"].tap()
        
        // credit
        XCTAssertTrue(app.buttons["Marshall Yunseok Lee"].exists)
        XCTAssertTrue(app.buttons["SEND EMAIL"].exists)
       }
}
