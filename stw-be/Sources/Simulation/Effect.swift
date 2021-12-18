//
//  Effect.swift
//  
//
//  Created by Maarten Engels on 18/12/2021.
//

import Foundation

/// Defines an effect that changes countries.
public enum Effect: Codable {
    case changeEmissions(percentage: Double)
    case changeGDP(percentage: Double)
    
    /// A 'pretty' description of this effects consequences for a country, when applied.
    var description: String {
        switch self {
        case .changeEmissions(let percentage):
            return "\(percentage > 0 ? "Increases" : "Decreases") emissions by \(percentage)%"
        case .changeGDP(let percentage):
            return "\(percentage > 0 ? "Increases" : "Decreases") GDP by \(percentage)%"
        }
    }
    
    /// Applies the effect to a country.
    /// - Parameters:
    ///   - country: the `Country` to apply the effect to.
    ///   - earth: the `Earth` that provides context.
    /// - Returns: An updated `Country` with the effect applied.
    func applyEffect(to country: Country, in earth: Earth) -> Country {
        var updatedCountry = country
        
        switch self {
        case .changeEmissions(let percentage):
            updatedCountry.yearlyEmissions *= (1.0 + 0.01 * percentage)
        case .changeGDP(let percentage):
            updatedCountry.baseGDP *= (1.0 + 0.01 * percentage)
        }
        
        return updatedCountry
    }
    
    /// Reverses the effect for a country.
    /// - Parameters:
    ///   - country: the `Country` to reverse the effect in.
    ///   - earth: the `Earth` that provides context.
    /// - Returns: An updated `Country` with the effect reversed.
    func reverseEffect(on country: Country, in earth: Earth) -> Country {
        var updatedCountry = country
        
        switch self {
        case .changeEmissions(let percentage):
            updatedCountry.yearlyEmissions /= (1.0 + 0.01 * percentage)
        case .changeGDP(let percentage):
            updatedCountry.baseGDP /= (1.0 + 0.01 * percentage)
        }
        
        return updatedCountry
    }
}
