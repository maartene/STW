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
public struct Country {
    
    /// assumed reduction in carbon emissions per thousand US$ (in gigaton).
    public static let EMISSION_REDUCTION_PER_THOUSAND_USDOLLAR = 0.000001
    
    
    /// assumed extraction of carbon per thousand US$ (i.e. net negative emissions) in gigaton carbon.
    public static let CARBON_SCRUBBED_PER_THOUSAND_USDOLLAR = 0.0000005
    
    public let name: String
    
    /// ISO 2 letter country code
    public let countryCode: String
    
    /// The countries yearly emissions (in gigaton carbon).
    public var yearlyEmissions: Double
    
    /// The base GDP (in 1000 US$)
    public var baseGDP: Double
    
    /// The current population of the country
    public var population: Int
    
    /// The current active commands
    public var activeCommands = [CountryCommand]()
    
//    /// The amount the country is investing in emission reduction (in 1000 US$)
//    public var emissionReductionSpent: Double = 0
    
    
//    /// The amount of emission reduction, compared to the base emissions, (in gigatonnes Carbon)
//    public var emissionReduction: Double {
//        var spent = emissionReductionSpent
//
//        if spent * Self.EMISSION_REDUCTION_PER_THOUSAND_USDOLLAR <= yearlyEmissions {
//            return spent * Self.EMISSION_REDUCTION_PER_THOUSAND_USDOLLAR
//        } else {    // if we're spending more than we have emissions to reduce, we'll assume to 'scrum' carbon from the atmosphere at a rate of
//            spent -= yearlyEmissions / Self.EMISSION_REDUCTION_PER_THOUSAND_USDOLLAR
//            return yearlyEmissions + spent * Self.CARBON_SCRUBBED_PER_THOUSAND_USDOLLAR
//        }
//    }
    
//    /// The actual carbon this country emits per year (in gigatonnes carbon), taking emission reduction into account.
//    public var yearlyEmissions: Double {
//        yearlyEmissions - emissionReduction
//    }
    
    /// Returns the net GDP this country has to spend, after 'paying' for damages caused by temperature increase.
    /// - Parameter earth: the simulated earth this country is a part of.
    /// - Returns: the GDP for this country in 1000 US$ (taking damages of temperature change into account).
    ///
    /// This function assumes a flat net impact of temperature change for each country. We know this is not correct and will improve this function to take geographical and economic differences into account.
    public func getCorrectedGDP(_ earth: Earth) -> Double {
        baseGDP * (1.0 - earth.currentCostOfTemperatureChange / 100.0)
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
        self.yearlyEmissions = baseYearlyEmissions
        self.baseGDP = baseGDP
        self.population = population
    }
    
    
    /// Execute a country command.
    /// - Parameters:
    ///   - command: the command to execute.
    ///   - earth: the earth this command is executed in.
    /// - Returns: an updated version of the country, with the effects of the command applied.
    public func executeCommand(_ command: CountryCommand, in earth: Earth) -> (updatedCountry: Country, resultMessage: String) {
        guard activeCommands.contains(command) == false else {
            return (self, "\(command.name) is already active.")
        }
        
        var result = command.applyEffect(to: self, in: earth)
        result.updatedCountry.activeCommands.append(command)
        return result
    }
    
    /// Reverse a country command.
    /// - Parameters:
    ///   - command: the command to reverse.
    ///   - earth: the earth this command is executed in.
    /// - Returns: an updated version of the country, with the effects of the command reversed.
    public func reverseCommand(_ command: CountryCommand, in earth: Earth) -> (updatedCountry: Country, resultMessage: String) {
        guard activeCommands.contains(command) else {
            return (self, "\(command.name) is not active.")
        }
        
        var result = command.reverseEffect(on: self, in: earth)
        result.updatedCountry.activeCommands.removeAll(where: {$0 == command})
        return result
    }
    
    /// An array of all commands available to this country.
    public var availableCommands: [CountryCommand] {
        [
            .exampleCommand(message: "Hello!"),
            .subsidiseFossilFuels
        ]
    }
}

extension Country: Codable { }
