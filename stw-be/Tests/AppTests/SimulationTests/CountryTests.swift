//
//  CountryTests.swift
//
//
//  Created by Maarten Engels on 28/11/2021.
//

@testable import Simulation
import XCTVapor
import XCTest
import App

final class CountryTests: XCTestCase {
    
    var netherlands: Country {
        Country(name: "The Netherlands", countryCode: "NL", baseYearlyEmissions: 0.46, baseGDP: 90705, population: 16981295, budgetSurplus: -3.949727, giniRating: 28, educationDevelopmentIndex: 0.991817)
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
        XCTAssertGreaterThan(netherlands.yearlyEmissions, 0)
    }
    
//    func testCountryInvestsInEmissionReduction() {
//        var country = netherlands
//
//        country.emissionReductionSpent = country.baseGDP * 0.01
//
//        XCTAssertGreaterThan(country.emissionReduction, 0)
//        XCTAssertLessThan(country.yearlyEmissions, country.yearlyEmissions)
//    }
    
    func testGlobalWarmingLowersGDP() {
        let originalGDP = netherlands.GDP
        var warmedNetherlands = netherlands
        warmedNetherlands.tick(in: warmedEarth)
        XCTAssertLessThan(warmedNetherlands.GDP, originalGDP)
    }
    
    func testTickIncreasesCountryPoints() {
        var country = netherlands
        
        country.tick(in: earth)
        
        XCTAssertGreaterThan(country.countryPoints, netherlands.countryPoints)
    }
    
    func testEnactPolicy() {
        var country = netherlands
        country.countryPoints = Int.max
        
        guard let policy = country.enactablePolicies.randomElement() else {
            XCTFail("No policy found.")
            return
        }
        
        XCTAssertFalse(country.activePolicies.contains(policy))
        
        let result = country.enactPolicy(policy)
        XCTAssertTrue(result.updatedCountry.activePolicies.contains(policy))
    }
    
    func testRevokePolicy() {
        var country = netherlands
        country.countryPoints = Int.max
        
        guard let policy = country.enactablePolicies.randomElement() else {
            XCTFail("No policy found.")
            return
        }
        
        XCTAssertFalse(country.activePolicies.contains(policy))
        
        let result = country.enactPolicy(policy)
        XCTAssertTrue(result.updatedCountry.activePolicies.contains(policy))
        
        let result2 = result.updatedCountry.revokePolicy(policy)
        XCTAssertFalse(result2.updatedCountry.activePolicies.contains(policy))
    }

    func testPolicyAffectsCountry() {
        var country = netherlands
        
        let policy = Policy(name: "testpolicy", effects: [.freePoints(points: 1)], baseCost: 0)
        
        var policyCountry = country.enactPolicy(policy).updatedCountry
        XCTAssertTrue(policyCountry.activePolicies.contains(policy))
        
        country.tick(in: earth)
        policyCountry.tick(in: earth)
        
        XCTAssertGreaterThan(policyCountry.countryPoints, country.countryPoints)
    }
    
    func testCommittedPolicyCannotBeRevoked() throws {
        let country = netherlands
        
        var policy = Policy(name: "testpolicy", effects: [.freePoints(points: 1)], baseCost: 0)
        
        let policyCountry = country.enactPolicy(policy, committed: true)
        
        policy.committed = true
        
        let revokePolicy = policyCountry.updatedCountry.revokePolicy(policy)
        XCTAssertEqual(revokePolicy.resultMessage, "You committed to policy 'testpolicy'. It cannot be revoked.")
        XCTAssertFalse(revokePolicy.result)
    }
    
    
    func testCommittedCountriesGetExtraCountryPoints() {
        var country = netherlands
        
        let policy = Policy(name: "testpolicy", effects: [.freePoints(points: 1)], baseCost: 0)
        
        var policyCountry = country.enactPolicy(policy, committed: true).updatedCountry
        
        country.tick(in: earth)
        policyCountry.tick(in: earth)
        
        XCTAssertGreaterThan(policyCountry.countryPoints, netherlands.countryPoints)
    }
    
    func testPoliciesGetAutomaticallyRevoked() {
        let country = netherlands
        
        let policy = Policy(name: "testpolicy", effects: [.extraEDI(percentage: 2)], baseCost: 0, condition: .lessThanOrEqualEDI(ranking: .A))
        
        var policyCountry = country.enactPolicy(policy).updatedCountry
        XCTAssertTrue(policyCountry.activePolicies.contains(policy))
        
        var maxTries = 1000
        while policyCountry.activePolicies.contains(policy) && maxTries >= 0 {
            if let result = policyCountry.tick(in: earth) {
                print(result)
            }
            maxTries -= 1
        }
            
        XCTAssertFalse(policyCountry.activePolicies.contains(policy))
    }
    
    func testForceRevokePolicy() {
        let country = netherlands
        
        let policy = Policy(name: "testpolicy", effects: [.extraEDI(percentage: 2)], baseCost: 0)
        
        let comittedCountry = country.enactPolicy(policy, committed: true).updatedCountry
        XCTAssertTrue(comittedCountry.activePolicies.contains(where: {$0.name == policy.name }))
        XCTAssertTrue(comittedCountry.committedPolicies.contains(where: {$0.name == policy.name }))
        
        let forceRevokeCountry = comittedCountry.revokePolicy(policy, force: true).updatedCountry
        XCTAssertFalse(forceRevokeCountry.activePolicies.contains(where: {$0.name == policy.name }))
        XCTAssertFalse(forceRevokeCountry.committedPolicies.contains(where: {$0.name == policy.name }))
    }
    
    func testPoliciesGetAutomaticallyRevokedEvenWhenComitted() {
        let country = netherlands
        
        let policy = Policy(name: "testpolicy", effects: [.extraEDI(percentage: 2)], baseCost: 0, condition: .lessThanOrEqualEDI(ranking: .A))
        
        var policyCountry = country.enactPolicy(policy, committed: true).updatedCountry
        XCTAssertTrue(policyCountry.activePolicies.contains(where: {$0.name == policy.name }))
        
        var maxTries = 1000
        while policyCountry.activePolicies.contains(where: {$0.name == policy.name }) && maxTries >= 0 {
            if let result = policyCountry.tick(in: earth) {
                print(result)
            }
            maxTries -= 1
        }
            
        XCTAssertFalse(policyCountry.activePolicies.contains(where: {$0.name == policy.name }))
    }
    
    func testPolicyStaysAfterUpdate() {
        let country = netherlands
        
        let policy = Policy(name: "testpolicy", effects: [.extraEDI(percentage: 2)], baseCost: 0, policyCategory: .emissionTarget)
        
        var policyCountry = country.enactPolicy(policy).updatedCountry
        XCTAssertTrue((policyCountry.activePolicies.contains(policy)))
        
        print(policyCountry.tick(in: earth) ?? "")
        
        XCTAssertTrue((policyCountry.activePolicies.contains(policy)))
    }
}
