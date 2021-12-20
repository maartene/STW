//
//  Country.swift
//  
//
//  Created by Maarten Engels on 23/11/2021.
//

import Foundation

/// A country describes a country on an earth.
///
/// Countries impact the earth by emitting carbon emissions.
/// It is the main object players can interact with, by deciding where to invest to lower/increase emissions.
/// `Codable` conformance helps change these from and to JSON
public struct Country: Codable {
    
    /// assumed reduction in carbon emissions per thousand US$ (in gigaton).
    public static let EMISSION_REDUCTION_PER_THOUSAND_USDOLLAR = 0.000001
    
    
    /// assumed extraction of carbon per thousand US$ (i.e. net negative emissions) in gigaton carbon.
    public static let CARBON_SCRUBBED_PER_THOUSAND_USDOLLAR = 0.0000005
    
    
    /// The country name, as per ISO
    public let name: String
    
    /// ISO 2 letter country code
    public let countryCode: String
    
    /// The countries base yearly emissions (in gigaton carbon) in 2015.
    public var baseYearlyEmissions: Double
    
    /// The countries yearly emissions (in gigaton carbon).
    public var yearlyEmissions: Double
    
    /// The base GDP (in 1000 US$) in 2015
    public var baseGDP: Double
    
    // The current GDP (in 1000 US$)
    public var GDP: Double
    
    /// The current population of the country
    public var population: Int
    
    /// The current active policies
    public var activePolicies = [Policy]()
    
    /// The current available country points for the country - this is your main currency for enacting policies and levelling up.
    public var countryPoints = 1
    
    /// Returns the net GDP this country has to spend, after 'paying' for damages caused by temperature increase.
    /// - Parameter earth: the simulated earth this country is a part of.
    /// - Returns: the GDP for this country in 1000 US$ (taking damages of temperature change into account).
    ///
    /// This function assumes a flat net impact of temperature change for each country. We know this is not correct and will improve this function to take geographical and economic differences into account.
    public func getCorrectedGDP(_ earth: Earth) -> Double {
        GDP * (1.0 - earth.currentCostOfTemperatureChange / 100.0)
    }
    
    /// Creates a new country.
    /// - Parameters:
    ///   - name: Country name
    ///   - countryCode: ISO 2 letter country code
    ///   - baseYearlyEmissions: The base yearly emissions (in gigaton carbon).
    ///   - baseGDP: The base GDP (in 1000 US$)
    ///   - population: The current population of the country
    public init(name: String, countryCode: String, baseYearlyEmissions: Double, baseGDP: Double, population: Int) {
        self.name = name
        self.countryCode = countryCode
        self.baseYearlyEmissions = baseYearlyEmissions
        self.baseGDP = baseGDP
        self.population = population
        self.GDP = baseGDP
        self.yearlyEmissions = baseYearlyEmissions
        //self.availableCommands = Self.defaultCommands()
    }
    
    
    /// Execute a country command.
    /// - Parameters:
    ///   - command: the command to execute.
    ///   - earth: the earth this command is executed in.
    /// - Returns: an updated version of the country, with the effects of the command applied.
    public func executeCommand(_ command: CountryCommand, in earth: Earth) -> (updatedCountry: Country, resultMessage: String) {
        let result = command.applyEffect(to: self, in: earth)
        return result
    }
        
    public var countryPointsPerTick: Int {
        let earth = Earth()
        
        var updatedCountry = self
        updatedCountry.tick(in: earth)
        return updatedCountry.countryPoints - countryPoints
    }
    
    /// Updates the country
    /// - Parameter earth: the `Earth` context for the country.
    public mutating func tick(in earth: Earth) {
        countryPoints += 1
        
        for policy in activePolicies {
            self = policy.applyEffects(to: self, in: earth)
        }
    }
    
    /// An array of all commands available to this country.
    public var availableCommands: [CountryCommand] {
        Self.defaultCommands()
    }
    
    /// The policies that can be enacted by this country, regardless of whether the are already enacted.
    public var availablePolicies: [Policy] {
        [
            Policy(name: "Subsidise fossil fuels", level: 1, effects: [.changeEmissions(percentage: 2), .changeGDP(percentage: 1)], baseCost: 1),
            Policy(name: "Subsidise green energy", level: 1, effects: [.changeEmissions(percentage: -1), .changeGDP(percentage: -1)], baseCost: 3)
        ]
    }
    
    /// The policies this country can enact.
    /// The available policies for this country, without the ones that are already enacted.
    public var enactablePolicies: [Policy] {
        availablePolicies.filter { policy in
            activePolicies.contains(where: { $0.name == policy.name }) == false
        }
    }
    
    /// Gets a default list of commands.
    /// - Returns: The default list of commands every country can execute.
    private static func defaultCommands() -> [CountryCommand] {
        do {
            var result = [CountryCommand]()
            result.append(try CountryCommand.getCommand("Example command"))
            result.append(try CountryCommand.getCommand("Free points"))
            return result
        } catch {
            fatalError("Unable to create defeault list of commands: \(error).")
        }
    }
    
    /// Enact a `Policy`.
    /// - Parameter policy: the `Policy` to enact.
    /// - Returns: an updated country and a message indicating the result of the action.
    public func enactPolicy(_ policy: Policy) -> (updatedCountry: Country, resultMessage: String) {
        guard policy.baseCost <= countryPoints else {
           return (self, "Not enough country points to enact policy \(policy).")
        }
        
        var updatedCountry = self
        updatedCountry.countryPoints -= policy.baseCost
        updatedCountry.activePolicies.append(policy)
        return (updatedCountry, "Successfully enacted policy '\(policy.name)'")
    }
    
    /// Revoke a `Policy`
    /// - Parameter policy: the `Policy` to revoke
    /// - Returns: an updated country and a message indicating the result of the action.
    public func revokePolicy(_ policy: Policy) -> (updatedCountry: Country, resultMessage: String) {
        guard let index = activePolicies.firstIndex(of: policy) else {
            return (self, "Policy '\(policy.name)' is not enacted.")
        }
        
        var updatedCountry = self
        updatedCountry.activePolicies.remove(at: index)
        return (updatedCountry, "Successfully revoked policy '\(policy.name)'")
    }
    
    /// Bring a `Policy` to a higher level.
    /// - Parameter policy: the `Policy` to level up.
    /// - Returns: an updated country and a message indicating the result of the action.
    ///
    /// Each extra level increases the impact the `Policy` has.
    public func levelUpPolicy(_ policy: Policy) -> (updatedCountry: Country, resultMessage: String) {
        guard let index = activePolicies.firstIndex(of: policy) else {
            return (self, "Policy '\(policy.name)' is not enacted.")
        }
        
        var updatedCountry = self
        
        guard policy.upgradeCost <= updatedCountry.countryPoints else {
            return (self, "Not enough point to upgrade '\(policy.name)'.")
        }
        
        updatedCountry.countryPoints -= policy.upgradeCost
        updatedCountry.activePolicies[index].level += 1
        
        return (updatedCountry, "Successfully upgraded policy '\(policy.name)'")
    }
}
