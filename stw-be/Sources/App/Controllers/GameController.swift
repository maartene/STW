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
}
