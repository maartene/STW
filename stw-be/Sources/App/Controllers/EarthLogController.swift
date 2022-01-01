//
//  EarthLogController.swift
//
//
//  Created by Maarten Engels on 17/12/2021.
//

import Fluent
import Vapor

struct EarthLogController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let earthModels = routes.grouped("logs")
        
        earthModels.group(":earthModelID") { earthModel in
            earthModel.get(use: getEarthLogs)
        }
    }
    
    func getEarthLogs(req: Request) async throws -> [EarthLog] {
        guard let earthModelIDString = req.parameters.get("earthModelID") else {
            throw Abort(.badRequest)
        }
        
        guard let earthModelID = UUID(uuidString: earthModelIDString) else {
            throw Abort(.notFound)
        }
        
        let messages = try await EarthLog.query(on: req.db).filter(\.$earthID, .equal, earthModelID).all().reversed()
        
        let numberToDrop = max(0, messages.count - 20)
        //print(numberToDrop)
        
        return Array(messages.dropLast(numberToDrop))
    }
}

