//
//  DiplomacySuggestion.swift
//  
//
//  Created by Maarten Engels on 09/01/2022.
//

import Vapor
import Fluent
import Simulation
import Foundation

final class DiplomacySuggestion: Content, Model {
    static let schema = "diplomacy_suggestions"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "owner_id")
    var ownerID: UUID
    
    @Field(key: "owner_name")
    var ownerName: String
    
    @Field(key: "target_id")
    var targetID: UUID
    
    @Field(key: "target_name")
    var targetName: String
    
    @Field(key: "policy")
    var policy: Policy
    
    init() {}
    
    init(id: UUID? = nil, ownerID: UUID, ownerName: String, targetID: UUID, targetName: String, policy: Policy) {
        self.id = id
        self.ownerID = ownerID
        self.ownerName = ownerName
        self.targetID = targetID
        self.targetName = targetName
        self.policy = policy
    }
}

