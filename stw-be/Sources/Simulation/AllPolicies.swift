//
//  AllPolicies.swift
//  
//
//  Created by Maarten Engels on 28/12/2021.
//

import Foundation

/// A datastructure that holds all the policies known to the game.
struct AllPolicies {
    
    private static let all = getAllPolicies()
    
    /// Builds an array of all policies
    /// - Returns: an array of all policies
    private static func getAllPolicies() -> [Policy] {
        var result = [Policy]()
        
        // Reduction targets
        result.append(Policy(name: "Set emission reduction target", description: "Sets an  emission target (very modest at first). You can make it more stringent by levelling it up.", effects: [.changeEmissionsTowardsTarget(percentageReductionPerYear: 1, target: 10)], baseCost: 1, condition: .not(.hasActivePolicy(policyName: "Set emission reduction target")), policyCategory: .emissionTarget))
        
        // increase wealth
        result.append(Policy(name: "Subsidise fossil fuels", description: nil,
                             effects: [
                                .extraEmissions(percentage: 1), .extraGDP(percentage: 1)
                             ], baseCost: 1,
                             condition: .lessThanOrEqualWealth(ranking: .C), policyCategory: .economic))
        
        result.append(Policy(name: "Promote eco-tourism", description: nil,
                            effects: [
                                .extraEmissions(percentage: 0.1), .extraGDP(percentage: 1)
                            ], baseCost: 5, condition: .greaterThanOrEqualEDI(ranking: .C), policyCategory: .economic))
        
        result.append(Policy(name: "Promote high tech industry", description: nil,
                             effects: [.extraGDP(percentage: 1)], baseCost: 5, condition: .greaterThanOrEqualEDI(ranking: .A), policyCategory: .economic))
        
        result.append(Policy(name: "Accept foreign aid", description: nil,
                             effects: [.extraGDP(percentage: 1), .extraGini(points: 0.01)], baseCost: 5, condition: .lessThanOrEqualWealth(ranking: .E), policyCategory: .economic))
        
        // education
        result.append(Policy(name: "Free schools", description: nil, effects: [
            .extraGDP(percentage: -2), .extraEDI(percentage: 1)], baseCost: 5, condition: .greaterThanOrEqualBudget(ranking: .A), policyCategory: .education))
        
        result.append(Policy(name: "Private schools", effects: [.extraEDI(percentage: 2), .extraGini(points: 1)], baseCost: 10, condition:
                                    .and([.greaterThanOrEqualEDI(ranking: .D), .lessThanOrEqualEquality(ranking: .E)]), policyCategory: .education))
        
        result.append(Policy(name: "Ivy League Schools", effects: [.extraEDI(percentage: 5), .extraGini(points: 3)], baseCost: 25, condition:
                                    .and([.greaterThanOrEqualEDI(ranking: .C), .lessThanOrEqualEquality(ranking: .D)]), policyCategory: .education))
        
        // increase equality
        result.append(Policy(name: "Progressive tax system", description: "De sterkste schouders dragen de grootste lasten", effects: [.extraGini(points: -0.1)], baseCost: 25, condition: .lessThanOrEqualEquality(ranking: .D), policyCategory: .economic))
        
        result.append(Policy(name: "Universal Base Income", effects: [.extraGini(points: -0.5)], baseCost: 10, condition: .greaterThanOrEqualBudget(ranking: .C), policyCategory: .economic))
        
        // increases political points
        result.append(Policy(name: "Tax cuts", description: nil, effects: [.freePoints(points: 1), .extraGDP(percentage: -2)], baseCost: 1, condition: .greaterThanOrEqualBudget(ranking: .B), policyCategory: .political))
        
        result.append(Policy(name: "Enact police state", description: nil, effects: [.freePoints(points: 2), .extraGDP(percentage: -2), .extraGini(points: 0.2)], baseCost: 1, condition: .lessThanOrEqualBudget(ranking: .D), policyCategory: .political))
        
        result.append(Policy(name: "Propaganda", effects: [.freePoints(points: 1)], baseCost: 5, condition: .lessThanOrEqualEDI(ranking: .C), policyCategory: .political))
        
        // co2 storage
        result.append(Policy(name: "Build CO2 storage facility", description: nil, effects: [.extraEmissions(percentage: -1)], baseCost: 10,
                             condition: .and([.greaterThanOrEqualEDI(ranking: .A), .greaterThanOrEqualEmissionsPerCapita(ranking: .A)]),
                             policyCategory: .co2storage))
        
        
        return result
    }
    
    /// Returns a list of all policies that apply to a country, by evaluating the policies conditions.
    /// - Parameter country: the country to evaluate policies for
    /// - Returns: all `Policy` that apply to the country.
    public static func getPolicyFor(_ country: Country) -> [Policy] {
        all.filter {
            $0.condition.evaluate(for: country)
        }
    }
}
