//
//  Effect.swift
//  
//
//  Created by Maarten Engels on 18/12/2021.
//

import Foundation

/// Defines an effect that changes countries.
public enum Effect: Codable, Equatable {
    
    case changeEmissions(percentage: Double)
    case changeGDP(percentage: Double)
    case freePoints(points: Int)
    
    /// A 'pretty' description of this effects consequences for a country, when applied.
    func description(level: Int = 1) -> String {
        switch self {
        case .changeEmissions(let percentage):
            return "\(percentage > 0 ? "Increases" : "Decreases") emissions by \(percentage * Double(level))%"
        case .changeGDP(let percentage):
            return "\(percentage * Double(level)  > 0 ? "Increases" : "Decreases") GDP by \(percentage * Double(level))%"
        case .freePoints(let points):
            return "Get free points: \(points)"
        }
    }
    
    /// Applies the effect to a country.
    /// - Parameters:
    ///   - country: the `Country` to apply the effect to.
    ///   - earth: the `Earth` that provides context.
    ///   - level: the effect level to apply.
    /// - Returns: An updated `Country` with the effect applied.
    ///
    /// `level` should only be set for policies > 1
    func applyEffect(to country: Country, in earth: Earth, level: Int = 1) -> Country {
        var updatedCountry = country
        
        switch self {
        case .changeEmissions(let percentage):
            updatedCountry.yearlyEmissions = updatedCountry.baseYearlyEmissions * (1.0 + 0.01 * percentage * Double(level))
        case .changeGDP(let percentage):
            updatedCountry.GDP = updatedCountry.baseGDP * (1.0 + 0.01 * percentage * Double(level))
        case .freePoints(let points):
            updatedCountry.countryPoints += points
        }
        
        return updatedCountry
    }
    
    /// Reverses the effect for a country.
    /// - Parameters:
    ///   - country: the `Country` to reverse the effect in.
    ///   - earth: the `Earth` that provides context.
    ///   - level: the effect level to apply (defaults to 1)
    /// - Returns: An updated `Country` with the effect reversed.
    /// `level` should only be set for policies > 1
    func reverseEffect(on country: Country, in earth: Earth, level: Int = 1) -> Country {
        var updatedCountry = country
        
        switch self {
        case .changeEmissions(let percentage):
            updatedCountry.yearlyEmissions /= (1.0 + 0.01 * percentage * Double(level))
        case .changeGDP(let percentage):
            updatedCountry.baseGDP /= (1.0 + 0.01 * percentage * Double(level))
        default:
            break;
        }
        
        return updatedCountry
    }
}
