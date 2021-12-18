//
//  CountryCommand.swift
//  
//
//  Created by Maarten Engels on 18/12/2021.
//

import Foundation

/// Definition of all possible commands that can be performed by a country.
///
/// `Codable` conformance makes it easy to send and receive commands between backend and front-end.
public enum CountryCommand: Codable, Equatable {
    
    /// An example command without any real game impact.
    case exampleCommand(message: String)
}
