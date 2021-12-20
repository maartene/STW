//
//  Policy.swift
//  
//
//  Created by Maarten Engels on 20/12/2021.
//

import Foundation

/// A policy a Country can enact (or retract) to change how it performs in the world.
public struct Policy: Codable, Equatable {

    /// A descriptive name for this policy, working as a sort of "primary key".
    public let name: String
    
    /// The level for this policy. Higher levels make policy effects more profound.
    public var level: Int
    
    /// The way the policy affects a country, defined by an array of `Effect`s
    public let effects: [Effect]
    
    /// The cost for a 'lv 1' version of this Policy (in Country Points)
    public let baseCost: Int
    
    /// The cost in Country Points to go to the next level.
    public var upgradeCost: Int {
        baseCost * faculty(level)
    }
    
    /// Apply this policies effects to a `Country`.
    /// - Parameters:
    ///   - country: the country to apply the effects to.
    ///   - earth: the earth that provides context.
    /// - Returns: an updated country with the effects applied.
    func applyEffects(to country: Country, in earth: Earth) -> Country {
        var updatedCountry = country
        
        for effect in effects {
            updatedCountry = effect.applyEffect(to: updatedCountry, in: earth)
        }
        
        return updatedCountry
    }
    
    /// A string version that describes the various effects of this command.
    public func effectDescription() -> String {
        if effects.count > 0 {
            let effectDescriptions = effects.map { $0.description(level: level) }
            return effectDescriptions.joined(separator: "\n")
        } else {
            return "No effect"
        }
    }
}
