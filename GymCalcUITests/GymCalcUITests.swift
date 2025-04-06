//
//  GymCalcUITests.swift
//  GymCalcUITests
//
//  Created by Andrew Slifkin on 2/2/25.
//

import XCTest

final class GymCalcUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testWeightAdjustment() throws {
        // Test weight adjustment buttons
        let incrementButton = app.buttons["+"]
        let decrementButton = app.buttons["-"]
        
        // Initial weight should be visible
        let weightText = app.staticTexts.element(matching: .any, identifier: "currentWeight")
        XCTAssertTrue(weightText.exists)
        
        // Test increment
        incrementButton.tap()
        // Wait for animation
        Thread.sleep(forTimeInterval: 0.5)
        
        // Test decrement
        decrementButton.tap()
        Thread.sleep(forTimeInterval: 0.5)
    }
    
    func testBarbellSelection() throws {
        // Open barbell management
        app.buttons["Equipment"].tap()
        
        // Verify barbell list appears
        let barbellList = app.collectionViews["barbellList"]
        XCTAssertTrue(barbellList.exists)
        
        // Select first barbell
        if let firstBarbell = barbellList.cells.firstMatch {
            firstBarbell.tap()
        }
        
        // Verify selection is reflected
        let selectedBarbell = app.staticTexts["selectedBarbell"]
        XCTAssertTrue(selectedBarbell.exists)
    }
    
    func testSettingsInteraction() throws {
        // Open settings
        app.buttons["settings"].tap()
        
        // Test unit toggle
        let unitToggle = app.switches["unitToggle"]
        XCTAssertTrue(unitToggle.exists)
        unitToggle.tap()
        
        // Test theme toggle
        let themeToggle = app.switches["themeToggle"]
        XCTAssertTrue(themeToggle.exists)
        themeToggle.tap()
        
        // Close settings
        app.buttons["Done"].tap()
    }
    
    func testPlateBreakdownDisplay() throws {
        // Set a specific weight that should show plates
        let weightField = app.textFields["weightInput"]
        XCTAssertTrue(weightField.exists)
        
        weightField.tap()
        weightField.typeText("225")
        app.buttons["Done"].tap()
        
        // Verify plate breakdown is shown
        let plateBreakdown = app.staticTexts["plateBreakdown"]
        XCTAssertTrue(plateBreakdown.exists)
        
        // Verify expected plates are shown (e.g., for 225 lbs: 4x45lb plates)
        let plateText = plateBreakdown.label
        XCTAssertTrue(plateText.contains("45"))
    }

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
