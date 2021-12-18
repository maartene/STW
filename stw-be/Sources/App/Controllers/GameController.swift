//
//  GameController.swift
//  
//
//  Created by Maarten Engels on 17/12/2021.
//

import Fluent
import Vapor
import Simulation

struct GameController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let game = routes.grouped("game")
        
        game.group(":countryModelID") { gameGroup in
            gameGroup.get(use: getFullData)
            gameGroup.post(use: executeCommand)
            gameGroup.post("reverse", use: reverseCommand)
            gameGroup.group("commands") { commandGroup in
                commandGroup.get(use: getAvailableCommands)
            }
        }
    }
    
    struct FullDataResponse: Content {
        let countryID: UUID
        let earthID: UUID
        let countryName: String
        let currentYear: Int
        let currentTemperature: Double
        let yearlyEmissions: Double
        let netGDP: Double
        let population: Int
        
        init(countryModel: CountryModel, earthModel: EarthModel) {
            self.countryID = countryModel.id!
            self.earthID = earthModel.id!
            self.countryName = countryModel.country.name
            self.currentYear = earthModel.earth.currentYear
            self.currentTemperature = earthModel.earth.currentTemperature
            self.yearlyEmissions = countryModel.country.yearlyEmissions
            self.netGDP = countryModel.country.getCorrectedGDP(earthModel.earth)
            self.population = countryModel.country.population
        }
    }
    
    func getFullData(req: Request) async throws -> FullDataResponse {
        guard let countryModel = try await CountryModel.find(req.parameters.get("countryModelID"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        guard let earthModel = try await EarthModel.find(countryModel.earthID, on: req.db) else {
            throw Abort(.notFound)
        }
        
        let response = FullDataResponse(countryModel: countryModel, earthModel: earthModel)
        
        return response
    }
    
    struct CommandInfo: Content {
        let command: CountryCommand
        let name: String
        let commandEffectDescription: String
        let isActive: Bool
        
        init(_ command: CountryCommand, isActive: Bool) {
            self.command = command
            self.name = command.name
            self.commandEffectDescription = command.effectDescription
            self.isActive = isActive
        }
    }
    
    func getAvailableCommands(req: Request) async throws -> [CommandInfo] {
        guard let countryModel = try await CountryModel.find(req.parameters.get("countryModelID"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        return countryModel.country.availableCommands.map { command in
            CommandInfo(command, isActive: countryModel.country.activeCommands.contains(command))
        }
    }
    
    func executeCommand(req: Request) async throws -> String {
        guard let countryModel = try await CountryModel.find(req.parameters.get("countryModelID"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        guard let earthModel = try await EarthModel.find(countryModel.earthID, on: req.db) else {
            throw Abort(.notFound)
        }
        
        let command = try req.content.decode(CountryCommand.self)
        
        // We need to verify that the command that was send from the client is an actual command from the countries list of available commands. This is particularly relevant for commands with associated values that might be tampered with from the client side.
        guard countryModel.country.availableCommands.contains(command) else {
            throw Abort(.badRequest)
        }
        
        let result = countryModel.country.executeCommand(command, in: earthModel.earth)
        
        countryModel.country = result.updatedCountry
        try await countryModel.save(on: req.db)
        
        return result.resultMessage
    }
    
    func reverseCommand(req: Request) async throws -> String {
        guard let countryModel = try await CountryModel.find(req.parameters.get("countryModelID"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        guard let earthModel = try await EarthModel.find(countryModel.earthID, on: req.db) else {
            throw Abort(.notFound)
        }
        
        let command = try req.content.decode(CountryCommand.self)
        
        // We need to verify that the command that was send from the client is an actual command from the countries list of active commands. This is particularly relevant for commands with associated values that might be tampered with from the client side.
        guard countryModel.country.activeCommands.contains(command) else {
            throw Abort(.badRequest)
        }
        
        let result = countryModel.country.reverseCommand(command, in: earthModel.earth)
        
        countryModel.country = result.updatedCountry
        try await countryModel.save(on: req.db)
        
        return result.resultMessage
    }
}
