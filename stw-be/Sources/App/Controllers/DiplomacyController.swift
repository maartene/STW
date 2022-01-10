//
//  File.swift
//  
//
//  Created by Maarten Engels on 10/01/2022.
//

import Vapor
import Simulation
import Algorithms

struct DiplomacyController: RouteCollection {

    func boot(routes: RoutesBuilder) throws {
        let diplomacyGroup = routes.grouped("diplomacy")
        
        diplomacyGroup.get(use: getDiplomacySuggestions)
        diplomacyGroup.get("options", use: getDiplomacyOptions)
        diplomacyGroup.post(use: suggestDiplomacyOption)
        diplomacyGroup.post(":suggestionID", "accept", use: acceptDiplomaticSuggestion)
        diplomacyGroup.post(":suggestionID", "refuse", use: refuseDiplomaticSuggestion)
        diplomacyGroup.post(":suggestionID", "revoke", use: revokeDiplomaticSuggestion)
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
    
    struct DiplomacyOption: Content {
        let countryModel: CountryModel
        var policies: [Policy]
    }
    
    func getDiplomacyOptions(req: Request) async throws -> [DiplomacyOption] {
        let playerAndCountry = try await getCountryAndPlayer(req: req)
        
        let countryModel = playerAndCountry.countryModel
        
        // first, get all countries in the world
        let otherCountries = try await CountryModel.query(on: req.db).filter(\.$earthID, .equal, countryModel.earthID).all()
            .filter {
                $0.id != countryModel.id // Filter out only the other countries
                && $0.playerID != nil // and the countries that are claimed by a player
            }
        
        let suggestions = try await DiplomacySuggestion.query(on: req.db).filter(\.$ownerID, .equal, countryModel.id!).all()
        
        if suggestions.count >= 3 {
            return []
        }
        
        var diplomacyOptions = [DiplomacyOption]()
        otherCountries.forEach { otherCountry in
            otherCountry.country.enactablePolicies.forEach { enactablePolicy in
                if countryModel.country.enactablePolicies.contains(enactablePolicy) &&
                    suggestions.contains(where: { suggestion in
                        suggestion.targetID == otherCountry.id && suggestion.policy.name == enactablePolicy.name
                    }) == false
                {
                    if let index = diplomacyOptions.firstIndex(where: { $0.countryModel.id == otherCountry.id }) {
                        diplomacyOptions[index].policies.append(enactablePolicy)
                    } else {
                        diplomacyOptions.append(DiplomacyOption(countryModel: otherCountry, policies: [enactablePolicy]))
                    }
                }
            }
        }
        return diplomacyOptions
    }
    
    struct DiplomacySuggestionInput: Content {
        let targetID: UUID
        let policy: Policy
    }
    
    func suggestDiplomacyOption(req: Request) async throws -> String {
        //print(req.content)
        
        let playerAndCountry = try await getCountryAndPlayer(req: req)
        
        let suggestion = try req.content.decode(DiplomacySuggestionInput.self)

        guard let targetCountryModel = try await CountryModel.find(suggestion.targetID, on: req.db) else {
            req.logger.warning("Could not find countryModel with id: \(suggestion.targetID)")
            throw Abort(.notFound)
        }
                
        guard let ownerID = playerAndCountry.countryModel.id else {
            req.logger.error("Owner \(playerAndCountry.countryModel.id?.uuidString ?? "nil") was nil. This should not happen.")
            throw Abort(.internalServerError)
        }
        
        let diplomaticSuggestion = DiplomacySuggestion(ownerID: ownerID, ownerName: playerAndCountry.countryModel.country.name, targetID: suggestion.targetID, targetName: targetCountryModel.country.name, policy: suggestion.policy)
        
        try await diplomaticSuggestion.save(on: req.db)
        
        try await EarthLog.logMessage("\(diplomaticSuggestion.ownerName) sent a suggestion to \(diplomaticSuggestion.targetName) to commit to enact policy: '\(diplomaticSuggestion.policy.name)'.", for: playerAndCountry.countryModel.earthID, on: req.db)
        
        return "Your suggestion to enact policy \(suggestion.policy.name) to \(targetCountryModel.country.name) was sent succesfully."
    }
    
    struct DiplomacySuggestionOutputContainer: Content {
        let forYou: [DiplomacySuggestion]
        let byYou: [DiplomacySuggestion]
    }
    
    func getDiplomacySuggestions(req: Request) async throws -> DiplomacySuggestionOutputContainer {
        let playerAndCountry = try await getCountryAndPlayer(req: req)
        
        // find DiplomacySuggestions for this country
        let suggestionsForYou = try await DiplomacySuggestion.query(on: req.db).filter(\.$targetID, .equal, playerAndCountry.countryModel.id!).all()
        
        let suggestionsByYou = try await DiplomacySuggestion.query(on: req.db).filter(\.$ownerID, .equal, playerAndCountry.countryModel.id!).all()
        
        
        
        return DiplomacySuggestionOutputContainer(forYou: suggestionsForYou, byYou: suggestionsByYou)
    }
    
    func acceptDiplomaticSuggestion(req: Request) async throws -> String {
        let playerAndCountry = try await getCountryAndPlayer(req: req)
        
        guard let suggestionID = UUID(uuidString: req.parameters.get("suggestionID") ?? "unknown") else {
            throw Abort(.badRequest)
        }
        
        guard let suggestion = try await DiplomacySuggestion.find(suggestionID, on: req.db) else {
            req.logger.warning("Could not find suggestion with id: \(suggestionID)")
            throw Abort(.notFound)
        }
        
        guard let owningCountry = try await CountryModel.find(suggestion.ownerID, on: req.db) else {
            req.logger.warning("Could not find CountryModel with id: \(suggestion.targetID.uuidString)")
            throw Abort(.notFound)
        }
        
        guard let targetCountry = try await CountryModel.find(suggestion.targetID, on: req.db) else {
            req.logger.warning("Could not find CountryModel with id: \(suggestion.targetID.uuidString)")
            throw Abort(.notFound)
        }
        
        guard suggestion.targetID == playerAndCountry.countryModel.id else {
            req.logger.warning("Country \(playerAndCountry.countryModel.country.name) tried to accept a diplomatic suggestion intended for another country \(suggestion.targetName)")
            throw Abort(.badRequest)
        }
        
        let enactResultOwner = owningCountry.country.enactPolicy(suggestion.policy, committed: true)
        let enactResultTarget = targetCountry.country.enactPolicy(suggestion.policy, committed: true)
        
        if enactResultOwner.result && enactResultTarget.result {
            owningCountry.country = enactResultOwner.updatedCountry
            try await owningCountry.save(on: req.db)
            targetCountry.country = enactResultTarget.updatedCountry
            try await targetCountry.save(on: req.db)
            try await suggestion.delete(on: req.db)
            try await EarthLog.logMessage("\(suggestion.ownerName) and \(suggestion.targetName) committed to enact policy: '\(suggestion.policy.name)'.", for: owningCountry.earthID, on: req.db)
            return "Succesfully committed to enact \(suggestion.policy.name)."
        } else {
            return """
                Unable to fulfill the at this time.
                Sender: \(enactResultOwner.resultMessage)
                Target: \(enactResultTarget.resultMessage)
                You can try again later.
            """
        }
        
    }
    
    func refuseDiplomaticSuggestion(req: Request) async throws -> String {
        let playerAndCountry = try await getCountryAndPlayer(req: req)
        
        guard let suggestionID = UUID(uuidString: req.parameters.get("suggestionID") ?? "unknown") else {
            throw Abort(.badRequest)
        }
        
        guard let suggestion = try await DiplomacySuggestion.find(suggestionID, on: req.db) else {
            req.logger.warning("Could not find suggestion with id: \(suggestionID)")
            throw Abort(.notFound)
        }
        
        guard suggestion.targetID == playerAndCountry.countryModel.id else {
            req.logger.warning("Country \(playerAndCountry.countryModel.country.name) tried to refuse a diplomatic suggestion intended for another country \(suggestion.targetName)")
            throw Abort(.badRequest)
        }
        
        try await suggestion.delete(on: req.db)
        
        try await EarthLog.logMessage("\(suggestion.targetName) refused the suggestion to commit to enact policy: '\(suggestion.policy.name)'.", for: playerAndCountry.countryModel.earthID, on: req.db)
        
        return "Succesfully refused \(suggestion.ownerName)'s suggestion to commit to enact policy \(suggestion.policy.name)."
        
    }
    
    func revokeDiplomaticSuggestion(req: Request) async throws -> String {
        let playerAndCountry = try await getCountryAndPlayer(req: req)
        
        guard let suggestionID = UUID(uuidString: req.parameters.get("suggestionID") ?? "unknown") else {
            throw Abort(.badRequest)
        }
        
        guard let suggestion = try await DiplomacySuggestion.find(suggestionID, on: req.db) else {
            req.logger.warning("Could not find suggestion with id: \(suggestionID)")
            throw Abort(.notFound)
        }
        
        guard suggestion.ownerID == playerAndCountry.countryModel.id else {
            req.logger.warning("Country \(playerAndCountry.countryModel.country.name) tried to refuse a diplomatic suggestion owned by another country \(suggestion.targetName)")
            throw Abort(.badRequest)
        }
        
        try await suggestion.delete(on: req.db)
        
        try await EarthLog.logMessage("\(suggestion.ownerName) revoked the suggestion to commit to enact policy: '\(suggestion.policy.name)'.", for: playerAndCountry.countryModel.earthID, on: req.db)
        
        return "Succesfully revoked your suggestion for \(suggestion.targetName) to commit to enact policy \(suggestion.policy.name)."
        
    }
}
