//
//  CountryCommand.swift
//  
//
//  Created by Maarten Engels on 18/12/2021.
//

// TODO: need to change these to hard coded commands in seperate file 'allCommands' (like 'allPolicies')
// TODO: use Condition system (just like Policy), instead of 'prerequisites'.

import Foundation

/// Definition of all possible commands that can be performed by a country.
///
/// `Codable` conformance makes it easy to send and receive commands between backend and front-end.
public struct CountryCommand: Codable, Equatable {
    
    /// Errors associated with this command.
    public enum CountryCommandErrors: Error {
        
        /// The command cannot be found in the list of known commands.
        case commandNotFound
    }
    
    /// A descriptive name, that also acts as the primary key for the command.
    public let name: String
    
    /// A description of the command to show more information.
    public let description: String
    
    /// The various ways this command impacts `Country`s.
    public let effects: [Effect]
    
    /// If you want to override the default message that is shown when a `Country` executes a `CountryCommand`, set this property.
    public let customApplyMessage: String?
    
    /// The cost to execute this command, in Country points.
    public let cost: Int
    
    /// Various flags associated with this command.
    public let flags: [CountryCommandFlag]
    
    public let prerequisitesNames: [String]

    private enum CodingKeys: CodingKey {
        case name, description, effects, customApplyMessage, cost, flags, prerequisitesNames
    }
    
    /// Codable based encode function.
    /// Use this to convert the command to JSON
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(effects, forKey: .effects)
        try container.encode(customApplyMessage, forKey: .customApplyMessage)
        try container.encode(cost, forKey: .cost)
        try container.encode(flags, forKey: .flags)
        try container.encode(prerequisitesNames, forKey: .prerequisitesNames)
    }
    
    
    /// Codable based initiazer.
    /// Set's default values to keep JSON definition as short and simple as possible.
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        description = (try? values.decode(String.self, forKey: .description)) ?? name
        effects = try values.decode([Effect].self, forKey: .effects)
        customApplyMessage = (try? values.decode(String?.self, forKey: .customApplyMessage)) ?? nil
        cost = (try? values.decode(Int.self, forKey: .cost)) ?? 0
        flags = (try? values.decode([CountryCommandFlag].self, forKey: .flags)) ?? []
        prerequisitesNames = (try? values.decode([String].self, forKey: .prerequisitesNames)) ?? []
    }
    
    /// Memberwise initiazer
    /// - Parameters:
    ///   - name: the descriptive name to use for this command. Make sure it's unique!
    ///   - description: more information about the command
    ///   - effects: the ways the command impacts a country, defined in `Effect`s
    ///   - customApplyMessage: if you want to use a custom apply message, set this value to a string.
    ///   - cost: the cost of this command in Country codes. Set to '0' for a free command
    ///   - flags: any flags you want to set.
    init(name: String, description: String, effects: [Effect], cost: Int, customApplyMessage: String? = nil, flags: [CountryCommandFlag] = [], prerequisites: [String] = []) {
        self.name = name
        self.description = description
        self.effects = effects
        self.customApplyMessage = customApplyMessage
        self.cost = cost
        self.flags = flags
        self.prerequisitesNames = prerequisites
    }
    
    /// The 'database' of commands known in the game.
    private static var allCommands = loadCommands()
    
    /// Populates the 'database' of commands, from a game supplied JSON.
    /// - Returns: all the commands that are found in the datafile.
    private static func loadCommands() -> [CountryCommand] {
        do {
            let url = URL(fileURLWithPath: "Data/CountryCommands.json")
            let countryJSON = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let commands = try decoder.decode([CountryCommand].self, from: countryJSON)
            return commands
        } catch {
            fatalError("Failed to load commands: \(error)")
        }
    }
    
    /// Get a command from the 'database'.
    /// - Parameter name: the commands name.
    /// - Returns: the command (if found)
    public static func getCommand(_ name: String) throws -> CountryCommand {
        if let command = allCommands.first(where: { $0.name == name }) {
            return command
        }
        throw CountryCommandErrors.commandNotFound
    }
    
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
        
        return (updatedCountry, customApplyMessage ?? "\(name) succesfully applied.")
    }
    
    /// A string version that describes the various effects of this command.
    public var effectDescription: String {
        if effects.count > 0 {
            let effectDescriptions = effects.map { $0.description() }
            return effectDescriptions.joined(separator: "\n")
        } else {
            return "No effect"
        }
    }
}

/// Known flags for `CountryCommand`s
public enum CountryCommandFlag: Codable, Equatable {
    
    /// Mark this command as intended for debugging only.
    case debugModeOnly
}
