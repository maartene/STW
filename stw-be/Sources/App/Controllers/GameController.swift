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
            gameGroup.group("commands") { commandGroup in
                commandGroup.get(use: getAvailableCommands)
            }
            gameGroup.group("policies") { policyGroup in
                policyGroup.get(use: getPolicies)
                policyGroup.post(use: enactPolicy)
                policyGroup.post("revoke", use: revokePolicy)
                policyGroup.post("levelup", use: levelUpPolicy)
            }
        }
    }
    
    // MARK: Basic data
    struct FullDataResponse: Content {
        let countryID: UUID
        let earthID: UUID
        let countryName: String
        let currentYear: Int
        let currentTemperature: Double
        let yearlyEmissions: Double
        let netGDP: Double
        let population: Int
        let countryPoints: Int
        let countryPointsPerTick: Int
        let forecastNetGDP: Double
        let forecastYearlyEmissions: Double
        let forecastPopulation: Int
        let forecastYear: Int
        
        init(countryModel: CountryModel, earthModel: EarthModel) {
            self.countryID = countryModel.id!
            self.earthID = earthModel.id!
            self.countryName = countryModel.country.name
            self.currentYear = earthModel.earth.currentYear
            self.currentTemperature = earthModel.earth.currentTemperature
            self.yearlyEmissions = countryModel.country.yearlyEmissions
            self.netGDP = countryModel.country.getCorrectedGDP(earthModel.earth)
            self.population = countryModel.country.population
            self.countryPoints = countryModel.country.countryPoints
            self.countryPointsPerTick = countryModel.country.countryPointsPerTick
            let forecastYear = earthModel.earth.currentYear + 50
            let forecast = countryModel.country.forecast(to: forecastYear, in: earthModel.earth)
            self.forecastNetGDP = forecast.getCorrectedGDP(earthModel.earth)
            self.forecastYearlyEmissions = forecast.yearlyEmissions
            self.forecastPopulation = forecast.population
            self.forecastYear = forecastYear
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
    
    // MARK: Commands
    struct CommandInfo: Content {
        let command: CountryCommand
        let effectDescription: String
        
        init(_ command: CountryCommand) {
            self.command = command
            self.effectDescription = command.effectDescription
        }
    }
    
    func getAvailableCommands(req: Request) async throws -> [CommandInfo] {
        guard let countryModel = try await CountryModel.find(req.parameters.get("countryModelID"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        let debugMode = Environment.get("DEBUG_MODE")?.uppercased() == "TRUE"
        var filteredCommands = countryModel.country.availableCommands
        
        if debugMode == false {
            filteredCommands = filteredCommands.filter {
                $0.flags.contains(.debugModeOnly) == false
            }
        }
        
        return filteredCommands.map { CommandInfo($0) }
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
    
    // MARK: Policies
    struct PolicyInfo: Content {
        let policy: Policy
        let effectDescription: String
        let upgradeCost: Int
        
        init(policy: Policy) {
            self.policy = policy
            self.effectDescription = policy.effectDescription()
            self.upgradeCost = policy.upgradeCost
        }
    }
    
    struct CountryPolicyInfo: Content {
        let availablePolicies: [PolicyInfo]
        let activePolicies: [PolicyInfo]
    }
    
    func getPolicies(req: Request) async throws -> CountryPolicyInfo {
        guard let countryModel = try await CountryModel.find(req.parameters.get("countryModelID"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        let availablePolicies = countryModel.country.enactablePolicies.map { PolicyInfo(policy: $0) }
        let activePolicies = countryModel.country.activePolicies.map { PolicyInfo(policy: $0) }
        
        return CountryPolicyInfo(availablePolicies: availablePolicies, activePolicies: activePolicies)
    }
    
    func enactPolicy(req: Request) async throws -> String {
        guard let countryModel = try await CountryModel.find(req.parameters.get("countryModelID"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        let policy = try req.content.decode(Policy.self)
        
        let result = countryModel.country.enactPolicy(policy)
        
        countryModel.country = result.updatedCountry
        try await countryModel.save(on: req.db)
        
        return result.resultMessage
        
    }
    
    func revokePolicy(req: Request) async throws -> String {
        guard let countryModel = try await CountryModel.find(req.parameters.get("countryModelID"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        let policy = try req.content.decode(Policy.self)
        
        let result = countryModel.country.revokePolicy(policy)
        
        countryModel.country = result.updatedCountry
        try await countryModel.save(on: req.db)
        
        return result.resultMessage
        
    }
    
    func levelUpPolicy(req: Request) async throws -> String {
        guard let countryModel = try await CountryModel.find(req.parameters.get("countryModelID"), on: req.db) else {
            req.logger.warning("Could not find countryModel with id: \(req.parameters.get("countryModelID") ?? "unknown")")
            throw Abort(.notFound)
        }
        
        let policy = try req.content.decode(Policy.self)
        
        let result = countryModel.country.levelUpPolicy(policy)
        
        countryModel.country = result.updatedCountry
        try await countryModel.save(on: req.db)
        
        return result.resultMessage
        
    }
}
