//
//  Condition.swift
//  
//
//  Created by Maarten Engels on 28/12/2021.
//

import Foundation

public indirect enum Condition: Codable, Equatable {
    case empty
    
    case or([Condition])
    case and([Condition])
    
    case lessThanOrEqualWealth(ranking: Rating)
    case greaterThanOrEqualWealth(ranking: Rating)
    case greaterThanOrEqualEDI(ranking: Rating)
    case greaterThanOrEqualEmissionsPerCapita(ranking: Rating)
    case greaterThanOrEqualBudget(ranking: Rating)
    case lessThanOrEqualBudget(ranking: Rating)
    case lessThanOrEqualEquality(ranking: Rating)
    
    case hasActivePolicy(policyName: String)
    
    func evaluate(for country: Country) -> Bool {
        switch self {
        case .empty:
            return true
        case .or(let conditions):
            for condition in conditions {
                if condition.evaluate(for: country) {
                    return true
                }
            }
            return false
            
        case .and(let conditions):
            for condition in conditions {
                if condition.evaluate(for: country) == false {
                    return false
                }
            }
            return true
            
        case .lessThanOrEqualWealth(let ranking):
            return Rating.wealthRatingFor(country) <= ranking
            
        case .greaterThanOrEqualWealth(let ranking):
            return Rating.wealthRatingFor(country) >= ranking
            
        case .greaterThanOrEqualEDI(let ranking):
            return Rating.ediRatingFor(country) >= ranking
            
        case .greaterThanOrEqualEmissionsPerCapita(let ranking):
            return Rating.emissionPerCapitaRatingFor(country) >= ranking
            
        case .greaterThanOrEqualBudget(let ranking):
            return Rating.budgetSurplusRatingFor(country) >= ranking
            
        case .lessThanOrEqualBudget(let ranking):
            return Rating.budgetSurplusRatingFor(country) <= ranking
            
        case .lessThanOrEqualEquality(let ranking):
            return Rating.equalityRatingFor(country) <= ranking
            
        case .hasActivePolicy(let policyName):
            return country.activePolicies.contains(where: { $0.name == policyName })
        }
    }
}
