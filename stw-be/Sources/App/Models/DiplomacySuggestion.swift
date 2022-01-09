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
    
    @Field(key: "target_id")
    var targetID: UUID
    
    @Field(key: "policy")
    var policy: Policy
    
    init() {}
    
    init(id: UUID? = nil, ownerID: UUID, targetID: UUID, policy: Policy) {
        self.id = id
        self.ownerID = ownerID
        self.targetID = targetID
        self.policy = policy
    }
}

