//
//  CountryTests.swift
//
//
//  Created by Maarten Engels on 28/11/2021.
//

@testable import Simulation
import XCTVapor

final class CountryTests: XCTestCase {
    
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
    
    func testCountry() {
        XCTAssertEqual(netherlands.emissionReductionSpent, 0)
        XCTAssertEqual(netherlands.emissionReduction, 0)
    }
    
    func testCountryInvestsInEmissionReduction() {
        var country = netherlands
        
        country.emissionReductionSpent = country.baseGDP * 0.01
        
        XCTAssertGreaterThan(country.emissionReduction, 0)
        XCTAssertLessThan(country.yearlyEmissions, country.baseYearlyEmissions)
    }
    
    func testGlobalWarmingLowersGDP() {
        XCTAssertLessThan(netherlands.getCorrectedGDP(warmedEarth), netherlands.getCorrectedGDP(earth))
    }
}
