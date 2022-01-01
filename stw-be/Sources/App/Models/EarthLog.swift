//
//  EarthLog.swift
//  
//
//  Created by Maarten Engels on 01/01/2022.
//

import Vapor
import Fluent
import Simulation

final class EarthLog: Content, Model {
    static let schema = "earth_logs"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "earthID")
    var earthID: UUID
    
    @Field(key: "message")
    var message: String
    
    @Field(key: "time_stamp")
    var timeStamp: Date
    
    init() {}
    
    init(earthID: UUID, message: String) {
        self.earthID = earthID
        self.message = message
        self.timeStamp = Date()
    }
    
    static func logMessage(_ message: String, for earthID: UUID, on db: Database) async throws {
        let earthLog = EarthLog(earthID: earthID, message: message)
        try await earthLog.save(on: db)
        
    }
}
