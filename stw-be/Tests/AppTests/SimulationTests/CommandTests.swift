//
//  CommandTests.swift
//  
//
//  Created by Maarten Engels on 18/12/2021.
//

import XCTest
@testable import Simulation

class CommandTests: XCTestCase {

    var netherlands: Country {
        Country(name: "The Netherlands", countryCode: "NL", baseYearlyEmissions: 0.46, baseGDP: 90705, population: 16981295)
    }
    
    var earth: Earth {
        Earth()
    }
    
    var warmedEarth: Earth {
        var earth = Earth()
        
        for _ in earth.currentYear ..< 2050 {
            earth.tick(yearlyEmission: 10)
        }
        
        return earth
    }
    
    func testGetListOfAvailableCommands() {
        XCTAssertGreaterThan(netherlands.availableCommands.count, 0)
    }
    
    func testExampleCommand() {
        let command = CountryCommand.exampleCommand(message: "Foo")
        let result = netherlands.executeCommand(command, in: earth)
        XCTAssertEqual(result.resultMessage, "Received an example command with message: Foo")
    }
    
    func testSubsidiseFossilFuels() {
        let command = CountryCommand.subsidiseFossilFuels
        let result = netherlands.executeCommand(command, in: earth)
        XCTAssertGreaterThan(result.updatedCountry.baseGDP, netherlands.baseGDP)
        XCTAssertGreaterThan(result.updatedCountry.yearlyEmissions, netherlands.yearlyEmissions)
    }
    
    func testReverseCommand() {
        let command = CountryCommand.subsidiseFossilFuels
        let applyResult = netherlands.executeCommand(command, in: earth)
        
        let reverseResult = applyResult.updatedCountry.reverseCommand(command, in: earth)
        
        XCTAssertEqual(reverseResult.updatedCountry.baseGDP, netherlands.baseGDP)
        XCTAssertEqual(reverseResult.updatedCountry.yearlyEmissions, netherlands.yearlyEmissions)
    }
}
