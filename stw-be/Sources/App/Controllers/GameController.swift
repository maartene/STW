//
//  GameController.swift
//  
//
//  Created by Maarten Engels on 17/12/2021.
//

import Fluent
import Vapor
import Simulation
import Foundation
import Algorithms

struct GameController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let game = routes.grouped("game")
        let protectedGame = game.grouped(UserToken.authenticator())
        
        try protectedGame.group("country") { gameGroup in
            gameGroup.get("hasCountry", use: hasCountry)
            gameGroup.get(use: getFullData)
            gameGroup.post(use: executeCommand)
            gameGroup.group("commands") { commandGroup in
                commandGroup.get(use: getAvailableCommands)
            }
            gameGroup.group("policies") { policyGroup in
                policyGroup.get(use: getPolicies)
                policyGroup.get("all", use: getAllPolicies)
                policyGroup.post(use: enactPolicy)
                policyGroup.post("revoke", use: revokePolicy)
                policyGroup.post("levelup", use: levelUpPolicy)
            }
            gameGroup.group("forecast") {forecastGroup in 
                forecastGroup.get(use: getForecast)
            }
            gameGroup.group("claim") { claimGroup in
                claimGroup.get(use: getUnclaimedCountries)
                claimGroup.post(use: claimCountry)
            }
            
            try gameGroup.register(collection: DiplomacyController())
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
    
    func getCountryAndPlayer(req: Request) async throws -> (player: Player, countryModel: CountryModel) {
        let player = try req.auth.require(Player.self)
        
        guard let countryModel = try await CountryModel.find(player.countryID, on: req.db) else {
            req.logger.warning("Could not find countryModel with id: \(player.countryID?.uuidString ?? "nil")")
            throw Abort(.notFound)
        }
        
        guard countryModel.playerID == player.id && player.countryID == countryModel.id && player.countryID != nil else {
            req.logger.warning("playerID in countryModel (\(countryModel.playerID?.uuidString ?? "nil") and player \(player.id?.uuidString ?? "nil") -or- countryID in player (\(player.countryID?.uuidString ?? "nil") and countryModel (\(countryModel.id?.uuidString ?? "nil") -or- countryID in player is nil (\(player.countryID?.uuidString ?? "nil") ")
            throw Abort(.badRequest)
        }
        
        return (player, countryModel)
    }
    
    func hasCountry(req: Request) async throws -> String {
        let player = try req.auth.require(Player.self)
        
        return (player.countryID != nil ? "true" : "false")
    }
    
    func getFullData(req: Request) async throws -> FullDataResponse {
        let countryModel = try await getCountryAndPlayer(req: req).countryModel
        
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
        let playerAndCountryModel = try await getCountryAndPlayer(req: req)
        
        let countryModel = playerAndCountryModel.countryModel
        
        let filteredCommands = countryModel.country.availableCommands
        
        return filteredCommands.map { CommandInfo($0) }
    }
    
    func executeCommand(req: Request) async throws -> String {
        let countryModel = try await getCountryAndPlayer(req: req).countryModel
        
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
        
        if result.result {
            try await EarthLog.logMessage("\(countryModel.country.name) executed command '\(command.name)'.", for: countryModel.earthID, on: req.db)
        }
        
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
    
    func getAllPolicies(req: Request) async throws -> [PolicyInfo] {
        return AllPolicies.all.map(PolicyInfo.init)
    }
    
    func getPolicies(req: Request) async throws -> CountryPolicyInfo {
        let countryModel = try await getCountryAndPlayer(req: req).countryModel
        
        let availablePolicies = countryModel.country.enactablePolicies.map { policy -> PolicyInfo in
            //print(policy)
            let newInfo = PolicyInfo(policy: policy)
            return newInfo
        }
        let activePolicies = countryModel.country.activePolicies.map { PolicyInfo(policy: $0) }
        
        return CountryPolicyInfo(availablePolicies: availablePolicies, activePolicies: activePolicies)
    }
    
    func enactPolicy(req: Request) async throws -> String {
        let countryModel = try await getCountryAndPlayer(req: req).countryModel
    
        let policy = try req.content.decode(Policy.self)
        
        guard countryModel.country.enactablePolicies.contains(policy) else {
            req.logger.warning("Received request to enact a policy that is not enactable by country \(countryModel.country.name): \(policy)")
            return "Mismatch between requested policy and policy as known by your country."
        }
        
        let result = countryModel.country.enactPolicy(policy)
        
        countryModel.country = result.updatedCountry
        try await countryModel.save(on: req.db)
        
        if result.result {
            try await EarthLog.logMessage("\(countryModel.country.name) enected policy '\(policy.name)'.", for: countryModel.earthID, on: req.db)
        }
        
        return result.resultMessage
        
    }
    
    func revokePolicy(req: Request) async throws -> String {
        let countryModel = try await getCountryAndPlayer(req: req).countryModel
        
        let policy = try req.content.decode(Policy.self)
        
        let result = countryModel.country.revokePolicy(policy)
        
        countryModel.country = result.updatedCountry
        try await countryModel.save(on: req.db)
        
        if result.result {
            try await EarthLog.logMessage("\(countryModel.country.name) revoked policy '\(policy.name)'.", for: countryModel.earthID, on: req.db)
        }
        
        return result.resultMessage
        
    }
    
    func levelUpPolicy(req: Request) async throws -> String {
        let countryModel = try await getCountryAndPlayer(req: req).countryModel
        
        let policy = try req.content.decode(Policy.self)
        
        let result = countryModel.country.levelUpPolicy(policy)
        
        countryModel.country = result.updatedCountry
        try await countryModel.save(on: req.db)
        
        if result.result {
            try await EarthLog.logMessage("\(countryModel.country.name) leveled up policy '\(policy.name)'.", for: countryModel.earthID, on: req.db)
        }
            
        return result.resultMessage
        
    }

    // MARK: Forecast
    struct Forecast: Content {
        let year: Int
        let currentTemperature: Double
        let currentTemperatureBAU: Double
        let currentConcentration: Double
        let countryEmissionsPerCapita: Double
        let countryWealthPerCapita: Double
        let countryGini: Double
        let countryEDI: Double
        let countryBudget: Double
    }
    
    func getForecast(req: Request) async throws -> [Forecast] {
        let countryModel = try await getCountryAndPlayer(req: req).countryModel

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
        let earthForecastsBAU = Earth().forecastSeries(to: forecastYear, yearlyEmissions: Earth.BASE_GLOBAL_EMISSIONS_2015)
        
        let last50yearsBAU = earthForecastsBAU[earthForecastsBAU.count - earthForecasts.count ..< earthForecastsBAU.count].map {$0}
        
        let countryForecasts = countryModel.country.forecastSeries(to: forecastYear, in: earthModel.earth)

        assert(earthForecasts.count == countryForecasts.count)
        assert(earthForecasts.count == last50yearsBAU.count)

        var result = [Forecast]()
        for i in 0 ..< earthForecasts.count {
            let earth = earthForecasts[i]
            let earthBUA = last50yearsBAU[i]
            assert(earth.currentYear == earthBUA.currentYear)
            let forecast = Forecast(
                year: earth.currentYear, 
                currentTemperature: earth.currentTemperature,
                currentTemperatureBAU: last50yearsBAU[i].currentTemperature,
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
    
    // MARK: Claim country
    func getUnclaimedCountries(req: Request) async throws -> [CountryModel] {
        let availableCountryModels = try await CountryModel.query(on: req.db).filter(\.$playerID, .equal, .none).all()
        
        // get a random selection of countryModels and return in descending order of yearly emissions
        let selection = availableCountryModels.randomSample(count: 20).sorted(by: { model1, model2 in
            model1.country.yearlyEmissions > model2.country.yearlyEmissions
        })
        
        return selection
    }
    
    func claimCountry(req: Request) async throws -> String {
        let player = try req.auth.require(Player.self)
        
        guard player.countryID == nil else {
            throw Player.PlayerError.playerAlreadyHasCountry
        }
        
        guard let requestedCountry = try? req.content.decode(CountryModel.self) else {
            throw Abort(.badRequest)
        }
        
        guard let countryModel = try await CountryModel.find(requestedCountry.id, on: req.db) else {
            throw Abort(.notFound)
        }
        
        guard countryModel.playerID == nil else {
            throw Abort(.badRequest)
        }
        
        player.countryID = countryModel.id
        countryModel.playerID = player.id
        
        try await player.save(on: req.db)
        try await countryModel.save(on: req.db)
        
        return "success"
        
    }
    
    // MARK: Diplomacy
    
}
