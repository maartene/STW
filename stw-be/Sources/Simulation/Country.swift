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
    
    // MARK: Data & Init
    
    /// The country name, as per ISO-3166
    ///
    /// License:
    /// This Data Package is made available under the Public Domain Dedication and License v1.0 whose full text can be found at: http://www.opendatacommons.org/licenses/pddl/1.0/
    public let name: String
    
    /// ISO-3166 2 letter country code
    ///
    /// Source: https://datahub.io/core/country-codes
    ///
    /// License:
    /// This Data Package is made available under the Public Domain Dedication and License v1.0 whose full text can be found at: http://www.opendatacommons.org/licenses/pddl/1.0/
    public let countryCode: String
    
    /// The countries base yearly emissions (in gigaton carbon) in 2015.
    ///
    /// Source: https://datahub.io/core/co2-fossil-by-nation (normalized to climate model)
    ///
    /// Citation:
    /// Boden, T.A., G. Marland, and R.J. Andres. 2013. Global, Regional, and National Fossil-Fuel CO2 Emissions. Carbon Dioxide Information Analysis Center, Oak Ridge National Laboratory, U.S. Department of Energy, Oak Ridge, Tenn., U.S.A. doi 10.3334/CDIAC/00001_V2013 _
    ///
    /// License: This Data Package is made available under the Public Domain Dedication and License v1.0 whose full text can be found at: http://www.opendatacommons.org/licenses/pddl/1.0/
    public var baseYearlyEmissions: Double
    
    /// The countries yearly emissions (in gigaton carbon).
    public var yearlyEmissions: Double
    
    /// The base GDP (in 1000 US$) in 2015
    ///
    /// Source: https://datahub.io/core/gdp
    ///
    /// License:
    /// This Data Package is made available under the Public Domain Dedication and License v1.0 whose full text can be found at: http://www.opendatacommons.org/licenses/pddl/1.0/
    public var baseGDP: Double
    
    // The current GDP (in 1000 US$)
    public var GDP: Double
    
    /// The current population of the country
    ///
    /// Source: https://datahub.io/core/population
    ///
    /// This Data Package is made available under the Public Domain Dedication and License v1.0 whose full text can be found at: http://www.opendatacommons.org/licenses/pddl/1.0/
    public var population: Int
    
    /// The current active policies
    public var activePolicies = [Policy]()
        
    /// The current available country points for the country - this is your main currency for enacting policies and levelling up.
    public var countryPoints = 1
    
    /// The budget surplus (positive values) or deficit (negative values) in % GDP
    ///
    /// Source: https://datahub.io/core/cash-surplus-deficit
    ///
    /// License:
    /// This Data Package is made available under the Public Domain Dedication and License v1.0 whose full text can be found at: http://www.opendatacommons.org/licenses/pddl/1.0/
    public var budgetSurplus: Double
    
    /// The amount of (in)equality in the country. Range: (0...1). Higher values indicate more inequality.
    ///
    /// Source: https://datahub.io/core/gini-index
    ///
    /// License:
    /// This Data Package is made available under the Public Domain Dedication and License v1.0 whose full text can be found at: http://www.opendatacommons.org/licenses/pddl/1.0/
    public var giniRating: Double
    
    /// The level of education in the country, as determined using the EDI. Range: (0...1). Higer values indicate better education.
    ///
    /// Source: http://www.unesco.org/new/en/archives/education/themes/leading-the-international-agenda/efareport/statistics/efa-development-index/edi-archive/ (Education For All Global Monitoring Report)
    public var educationDevelopmentIndex: Double
    
    /// Creates a new country.
    /// - Parameters:
    ///   - name: Country name
    ///   - countryCode: ISO 2 letter country code
    ///   - baseYearlyEmissions: The base yearly emissions (in gigaton carbon).
    ///   - baseGDP: The base GDP (in 1000 US$)
    ///   - population: The current population of the country
    ///   - budgetSurplus: The budget surplus (positive values) or deficit (negative values) in % GDP
    ///   - giniRating: The equality of the country, measured using the gini index.
    ///   - educationDevelopmentIndex: The level of education in the country, as determined using the EDI. Range: (0...1). Higer values indicate better education.
    public init(name: String, countryCode: String, baseYearlyEmissions: Double, baseGDP: Double, population: Int, budgetSurplus: Double, giniRating: Double, educationDevelopmentIndex: Double) {
        self.name = name
        self.countryCode = countryCode
        self.baseYearlyEmissions = baseYearlyEmissions
        self.baseGDP = baseGDP
        self.population = population
        self.GDP = baseGDP
        self.yearlyEmissions = baseYearlyEmissions
        //self.availableCommands = Self.defaultCommands()
        self.budgetSurplus = budgetSurplus
        self.giniRating = giniRating
        self.educationDevelopmentIndex = educationDevelopmentIndex
    }
    
    /// The amount of country points you get in each update.
    public var countryPointsPerTick: Int {
        let earth = Earth()
        
        var updatedCountry = self
        updatedCountry.tick(in: earth)
        return updatedCountry.countryPoints - countryPoints
    }
    
    // MARK: Update
    
    @discardableResult
    /// /// Updates the country
    /// - Parameter earth: the `Earth` context for the country.
    /// - Returns: If during the update messages are created, these are returned as a string.
    public mutating func tick(in earth: Earth) -> String? {
        countryPoints += 1
        
        // Get extra country points for each comitted policy.
        countryPoints += fib(committedPolicies.count)
        
        // Apply global warming effects.
        for effect in earth.currentEffectsOfTemperatureChange {
            self = effect.applyEffect(to: self, in: earth)
        }
        
        var resultMessages = [String]()
        // Apply policy effects
        for policy in activePolicies {
            if policy.condition.evaluate(for: self) {
                self = policy.applyEffects(to: self, in: earth)
            } else {
                self = self.revokePolicy(policy, force: true).updatedCountry
                resultMessages.append("Policy \(policy.name) is no longer valid for country \(self.name), so it is automatically revoked.")
            }
            
        }
        
        if resultMessages.count > 0 {
            return resultMessages.joined(separator: "\n")
        } else {
            return nil
        }
    }
    
    // MARK: Commands
    
    /// An array of all commands available to this country.
    public var availableCommands: [CountryCommand] {
        AllCommands.getCountryCommandsFor(self)
    }
    
    /// Execute a country command.
    /// - Parameters:
    ///   - command: the command to execute.
    ///   - earth: the earth this command is executed in.
    /// - Returns: an updated version of the country, with the effects of the command applied.
    public func executeCommand(_ command: CountryCommand, in earth: Earth) -> (result: Bool, updatedCountry: Country, resultMessage: String) {
        guard countryPoints >= command.cost else {
            return (false, self, "Not enough points to execute command \(command.name).")
        }
        
        var commandResult = command.applyEffect(to: self, in: earth)
        commandResult.updatedCountry.countryPoints -= command.cost
        
        return (true, commandResult.updatedCountry, commandResult.resultMessage)
    }
    
    // MARK: Policy
    
    /// The policies that can be enacted by this country, regardless of whether the are already enacted.
    public var availablePolicies: [Policy] {
        AllPolicies.getPolicyFor(self)
    }
    
    /// Policies that you commit too. Committed policies cannot be revoked, but bring extra country points.
    public var committedPolicies: [Policy] {
        activePolicies.filter { $0.committed }
    }
    
    /// The policies this country can enact.
    /// The available policies for this country, without the ones that are already enacted.
    public var enactablePolicies: [Policy] {
        availablePolicies.filter { policy in
            activePolicies.contains(where: { $0.name == policy.name }) == false
        }
    }
    
    /// Enact a `Policy`.
    /// - Parameter policy: the `Policy` to enact.
    /// - Parameter committed: wether you commit to this policy. Default: false
    /// - Returns: an updated country and a message indicating the result of the action.
    public func enactPolicy(_ policy: Policy, committed: Bool = false) -> (result: Bool, updatedCountry: Country, resultMessage: String) {
        guard policy.baseCost <= countryPoints else {
            return (false, self, "Not enough country points to enact policy \(policy.name).")
        }
        
        var updatedCountry = self
        
        let policiesInSameCategory = activePolicies.filter({$0.category == policy.category})
        
        if let limit = policy.category.policyLimit, policiesInSameCategory.count >= limit {
            return (false, self, "You already have the maximum (\(limit)) number of policies in the \(policy.category) category active.")
        }
        
        var updatedPolicy = policy
        updatedPolicy.committed = committed
        
        updatedCountry.countryPoints -= updatedPolicy.baseCost
        updatedCountry.activePolicies.append(updatedPolicy)

        return (true, updatedCountry, "Successfully enacted policy '\(updatedPolicy.name)'")
    }
    
    /// Revoke a `Policy`
    /// - Parameter policy: the `Policy` to revoke
    /// - Returns: an updated country and a message indicating the result of the action.
    public func revokePolicy(_ policy: Policy, force: Bool = false) -> (result: Bool, updatedCountry: Country, resultMessage: String) {
        guard policy.committed == false || force else {
            return (false, self, "You committed to policy '\(policy.name)'. It cannot be revoked.")
        }
        
        guard let index = activePolicies.firstIndex(where: {$0.name == policy.name }) else {
            return (false, self, "Policy '\(policy.name)' is not enacted.")
        }
        
        var updatedCountry = self
        updatedCountry.activePolicies.remove(at: index)
        return (true, updatedCountry, "Successfully revoked policy '\(policy.name)'")
    }
    
    /// Bring a `Policy` to a higher level.
    /// - Parameter policy: the `Policy` to level up.
    /// - Returns: an updated country and a message indicating the result of the action.
    ///
    /// Each extra level increases the impact the `Policy` has.
    public func levelUpPolicy(_ policy: Policy) -> (result: Bool, updatedCountry: Country, resultMessage: String) {
        guard let index = activePolicies.firstIndex(of: policy) else {
            return (false, self, "Policy '\(policy.name)' is not enacted.")
        }
        
        var updatedCountry = self
        
        guard policy.upgradeCost <= updatedCountry.countryPoints else {
            return (false, self, "Not enough point to upgrade '\(policy.name)'.")
        }
        
        updatedCountry.countryPoints -= policy.upgradeCost
        updatedCountry.activePolicies[index].level += 1
        
        return (true, updatedCountry, "Successfully upgraded policy '\(policy.name)'")
    }
    
    // MARK: Forecasts
    
    /// Forecasts what the country would look like in the year requested, in a constant earth.
    /// - Parameters:
    ///   - year: the year to forecast to
    ///   - earth: the (constant) earth to simulate in.
    /// - Returns: a forecasted country in the year `year`.
    public func forecast(to year: Int, in earth: Earth) -> Country {
        var forecastCountry = self
        for _ in earth.currentYear ..< year {
            for _ in 0 ..< 24 {
                forecastCountry.tick(in: earth)
            }
        }
        return forecastCountry
    }

    /// Forecasts what the country would look like in the year requested, in a constant earth.
    /// - Parameters:
    ///   - year: the year to forecast to
    ///   - earth: the (constant) earth to simulate in.
    /// - Returns: an array of forecasted `Country`s to the specified.
    ///
    /// Useful for creating a time series.
    public func forecastSeries(to year: Int, in earth: Earth) -> [Country] {
        assert(year >= earth.currentYear)
        
        var result = [Country]()
        var forecastCountry = self
        for _ in earth.currentYear ..< year {
            result.append(forecastCountry)
            for _ in 0 ..< 24 {
                forecastCountry.tick(in: earth)
            }
        }
        return result
    }
}
