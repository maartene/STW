//
//  EarthModel.swift
//  
//
//  Created by Maarten Engels on 17/12/2021.
//

import Foundation
import Vapor
import Fluent
import Simulation

/// The `EarthModel` is a wrapper for an `Earth` that can be loaded and saved to the database.
final class EarthModel: Content, Model {
    static let schema = "earth_model"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "earth")
    var earth: Earth
    
    init() {
        self.earth = Earth()
    }
}
