//
//  AllCommands.swift
//  
//
//  Created by Maarten Engels on 31/12/2021.
//

import Foundation

/// A data structure that holds all known commands in the game.
struct AllCommands {
    
    /// All known commands
    private static let all = getAllCommands()
    
    /// Builds an array of all policies
    /// - Returns: an array of all policies
    private static func getAllCommands() -> [CountryCommand] {
        var result = [CountryCommand]()
        
        result.append(CountryCommand(name: "Example command", description: "It does nothing!", effects: [], cost: 0))
        result.append(CountryCommand(name: "Free points", description: "Free lunch!", effects: [.freePoints(points: 10)], cost: 0))
        result.append(CountryCommand(name: "Climate conference", description: "Better luck next time", effects: [], cost: 100))
        
        return result
    }
    
    /// Gets all the commands a country can execute.
    /// - Parameter country: the `country` for which we want to get the commands back.
    /// - Returns: An array of commands.
    ///
    /// Note: the returned array of `CountryCommand`s is filtered on the condition that the command has.
    public static func getCountryCommandsFor(_ country: Country) -> [CountryCommand] {
        all.filter { $0.condition.evaluate(for: country) }
    }
}
