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
            gameGroup.group("forecast") {forecastGroup in 
                forecastGroup.get(use: getForecast)
            }
        }
    }
    
    // MARK: Basic data
    struct FullDataResponse: Content {
        let countryID: UUID
        let earthID: UUID
        let countryName: String
        let countryCode: String
        let currentYear: Int
        let currentTemperature: Double
        let yearlyEmissions: Double
        let netGDP: Double
        let population: Int
        let countryPoints: Int
        let countryPointsPerTick: Int
        let budgetSurplus: Double
        let giniRating: Double
        let educationDevelopmentIndex: Double
        let wealthRating: String
        let budgetSurplusRating: String
        let giniRatingRating: String
        let educationDevelopmentIndexRating: String
        let emissionPerCapitaRating: String
        let earthEffectsDescription: String
        
        init(countryModel: CountryModel, earthModel: EarthModel) {
            self.countryID = countryModel.id!
            self.earthID = earthModel.id!
            self.countryName = countryModel.country.name
            self.countryCode = countryModel.country.countryCode
            self.currentYear = earthModel.earth.currentYear
            self.currentTemperature = earthModel.earth.currentTemperature
            self.yearlyEmissions = countryModel.country.yearlyEmissions
            self.netGDP = countryModel.country.GDP
            self.population = countryModel.country.population
            self.countryPoints = countryModel.country.countryPoints
            self.countryPointsPerTick = countryModel.country.countryPointsPerTick
            self.budgetSurplus = countryModel.country.budgetSurplus
            self.giniRating = countryModel.country.giniRating
            self.educationDevelopmentIndex = countryModel.country.educationDevelopmentIndex
            self.wealthRating = Rating.wealthRatingFor(countryModel.country).stringValue
            self.budgetSurplusRating = Rating.budgetSurplusRatingFor(countryModel.country).stringValue
            self.giniRatingRating = Rating.equalityRatingFor(countryModel.country).stringValue
            self.educationDevelopmentIndexRating = Rating.ediRatingFor(countryModel.country).stringValue
            self.emissionPerCapitaRating = Rating.emissionPerCapitaRatingFor(countryModel.country).stringValue
            self.earthEffectsDescription = earthModel.earth.effectDescription
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
        let conditionDescription: String
        let upgradeCost: Int
        
        init(policy: Policy) {
            self.policy = policy
            self.effectDescription = policy.effectDescription()
            self.conditionDescription = policy.condition.conditionDescription
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
        
        let availablePolicies = countryModel.country.enactablePolicies.map { policy -> PolicyInfo in
            //print(policy)
            let newInfo = PolicyInfo(policy: policy)
            return newInfo
        }
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

    // MARK: Forecast
    struct Forecast: Content {
        let year: Int
        let currentTemperature: Double
        let currentConcentration: Double
        let countryEmissionsPerCapita: Double
        let countryWealthPerCapita: Double
        let countryGini: Double
        let countryEDI: Double
        let countryBudget: Double
    }
    
    func getForecast(req: Request) async throws -> [Forecast] {
        guard let countryModel = try await CountryModel.find(req.parameters.get("countryModelID"), on: req.db) else {
            req.logger.warning("Could not find countryModel with id: \(req.parameters.get("countryModelID") ?? "unknown")")
            throw Abort(.notFound)
        }

        guard let earthModel = try await EarthModel.find(countryModel.earthID, on: req.db) else {
            req.logger.warning("Could not find earthModel with id: \(countryModel.earthID)")
            throw Abort(.notFound)
        }

        let startYear = earthModel.earth.currentYear
        let forecastYear = startYear + 50

        let countries = try await CountryModel.query(on: req.db).filter(\.$earthID, .equal, earthModel.id!).all()
        let emissions = countries.map { $0.country.yearlyEmissions }
        let totalEmissions = emissions.reduce(0, +)

        let earthForecasts = earthModel.earth.forecastSeries(to: forecastYear, yearlyEmissions: totalEmissions)
        let countryForecasts = countryModel.country.forecastSeries(to: forecastYear, in: earthModel.earth)

        assert(earthForecasts.count == countryForecasts.count)

        var result = [Forecast]()
        for i in 0 ..< earthForecasts.count {
            let earth = earthForecasts[i]
            let forecast = Forecast(
                year: earth.currentYear, 
                currentTemperature: earth.currentTemperature, 
                currentConcentration: earth.currentConcentration, 
                countryEmissionsPerCapita: countryForecasts[i].yearlyEmissions / Double(countryForecasts[i].population),
                countryWealthPerCapita: countryForecasts[i].GDP * 1000.0 / Double(countryForecasts[i].population) / 365.0,
                countryGini: countryForecasts[i].giniRating,
                countryEDI: countryForecasts[i].educationDevelopmentIndex,
                countryBudget: countryForecasts[i].budgetSurplus
            )
            result.append(forecast)
        }

        return result
    }
}
