//
//  Rating.swift
//  
//
//  Created by Maarten Engels on 28/12/2021.
//

import Foundation

public enum Rating: Comparable, Codable {
    case undefined, F, E, D, C, B, A, S
    
    public var stringValue: String {
        switch self {
        case .S:
            return "S"
        case .A:
            return "A"
        case .B:
            return "B"
        case .C:
            return "C"
        case .D:
            return "D"
        case .E:
            return "D"
        case .F:
            return "D"
        case .undefined:
            return "undefined"
        }
    }
    
    public static func wealthRatingFor(_ country: Country) -> Rating {
        let wealthPerCapita = country.GDP / Double(country.population) / 365.0
        
        switch wealthPerCapita {
        case 0 ..< 3.2:
            return F
        case 3.2 ..< 5.5:
            return E
        case 5.5 ..< 15:
            return D
        case 15 ..< 40:
            return C
        case 40 ..< 120:
            return B
        case 120 ..< 200:
            return A
        case 200 ..< Double.infinity:
            return S
            
        default:
            return undefined
        }
    }
    
    public static func budgetSurplusRatingFor(_ country: Country) -> Rating {
        switch country.budgetSurplus {
        case -Double.infinity ..< -10:
            return F
        case -10 ..< -5:
            return D
        case -5 ..< -2.5:
            return C
        case -2.5 ..< 0:
            return B
        case 0 ..< 5:
            return A
        case 5 ..< Double.infinity:
            return S
            
        default:
            return undefined
        }
    }
    
    // 37,5 is average
    public static func equalityRatingFor(_ country: Country) -> Rating {
        switch country.giniRating {
        case 50 ..< Double.infinity:
            return F
        case 45 ..< 50:
            return E
        case 40 ..< 45:
            return D
        case 37.5 ..< 40:
            return C
        case 30 ..< 37.5:
            return B
        case 25 ..< 30:
            return A
        case 0 ..< 25:
            return S
            
        default:
            return undefined
        }
    }
    
    // average 0.899
    public static func ediRatingFor(_ country: Country) -> Rating {
        switch country.educationDevelopmentIndex {
        case 0 ..< 0.6:
            return F
        case 0.6 ..< 0.7:
            return E
        case 0.7 ..< 0.8:
            return D
        case 0.8 ..< 0.9:
            return C
        case 0.9 ..< 0.95:
            return B
        case 0.95 ..< 0.99:
            return A
        case 0.99 ..< Double.infinity:
            return S
            
        default:
            return undefined
        }
    }
    
    public static func emissionPerCapitaRatingFor(_ country: Country) -> Rating {
        let emissionsPerCapita = country.yearlyEmissions * 1_000_000_000 / Double(country.population)
        
        switch emissionsPerCapita {
        case -Double.infinity ..< -4:
            return S
        case -4 ..< 0:
            return A
        case 0 ..< 1:
            return B
        case 1 ..< 2:
            return C
        case 2 ..< 5:
            return D
        case 5 ..< 10:
            return E
        case 10 ..< Double.infinity:
            return F
            
        default:
            return undefined
        }
        
    }
}


