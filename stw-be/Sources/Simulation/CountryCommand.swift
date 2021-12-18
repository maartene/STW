//
//  CountryCommand.swift
//  
//
//  Created by Maarten Engels on 18/12/2021.
//

import Foundation

/// Definition of all possible commands that can be performed by a country.
///
/// `Codable` conformance makes it easy to send and receive commands between backend and front-end.
public enum CountryCommand: Codable, Equatable {
    
    /// An example command without any real game impact.
    case exampleCommand(message: String)
    case subsidiseFossilFuels
    
    
    /// Applies this command's effects to a country in a world.
    /// - Parameters:
    ///   - country: the country to apply the effects to.
    ///   - earth: the earth that provides context for the country.
    /// - Returns: A tuple of an `updatedCountry: Country` and a `resultMessage: String`.
    func applyEffect(to country: Country, in earth: Earth) -> (updatedCountry: Country, resultMessage: String) {
        var updatedCountry = country
        
        for effect in effects {
            updatedCountry = effect.applyEffect(to: updatedCountry, in: earth)
        }
        
        return (updatedCountry, effectResultDescription)
    }
    
    /// Reverses this command's effects in a country in a world.
    /// - Parameters:
    ///   - country: the country to reverse the effects in.
    ///   - earth: the earth that provides context for the country.
    /// - Returns: A tuple of an `updatedCountry: Country` and a `resultMessage: String`.
    func reverseEffect(on country: Country, in earth: Earth) -> (updatedCountry: Country, resultMessage: String) {
        var updatedCountry = country
        
        for effect in effects {
            updatedCountry = effect.reverseEffect(on: updatedCountry, in: earth)
        }
        
        return (updatedCountry, "Reversed the effect of \(name).")
    }
    
    /// A string version that describes the various effects of this command.
    public var effectDescription: String {
        if effects.count > 0 {
            let effectDescriptions = effects.map { $0.description }
            return effectDescriptions.joined(separator: "\n")
        } else {
            return "No effect"
        }
    }
    
    
    /// An array of `Effect` that this command performs when applied.
    var effects: [Effect] {
        switch self {
        case .exampleCommand:
            return []
        case .subsidiseFossilFuels:
            return [
                .changeGDP(percentage: 1),
                .changeEmissions(percentage: 2)
            ]
        }
    }
    
    /// A descriptive name for the command
    public var name: String {
        switch self {
        case .exampleCommand:
            return "Example Command"
        case .subsidiseFossilFuels:
            return "Subsidise fossil fuels"
        }
    }
    
    /// A descriptive name for the result of this command when applied.
    var effectResultDescription: String {
        switch self {
        case .exampleCommand(let message):
            return "Received an example command with message: \(message)"
        case .subsidiseFossilFuels:
            return "Your country is now subsidising fossil fuels."
        }
    }
}
