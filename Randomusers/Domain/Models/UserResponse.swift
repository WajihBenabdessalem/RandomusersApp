//
//  UserResponse.swift
//  Randomusers
//
//  Created by Wajih Benabdessalem on 3/11/25.
//

import Foundation

struct UserResponse: Codable {
    let results: [User]
    let info: Info
}

struct Info: Codable {
    let seed: String
    let results: Int
    let page: Int
    let version: String
}

struct User: Codable {
    let id: ID
    let name: Name
    let email: String
    let phone: String
    let cell: String
    let picture: Picture
    let location: Location
    let dob: DateInfo
    let registered: DateInfo
    let nat: String
    let gender: String
    
    struct ID: Codable {
        let name: String?
        let value: String?
    }
}

struct Name: Codable {
    let title: String
    let first: String
    let last: String
    
    var fullName: String {
        return "\(title) \(first) \(last)"
    }
}

struct Picture: Codable {
    let large: String
    let medium: String
    let thumbnail: String
}

struct Location: Codable {
    let street: Street
    let city: String
    let state: String
    let country: String
    let postcode: CodableValue
    let coordinates: Coordinates
    let timezone: Timezone
    
    struct Street: Codable {
        let number: Int
        let name: String
    }
}

struct Coordinates: Codable {
    let latitude: String
    let longitude: String
}

struct Timezone: Codable {
    let offset: String
    let description: String
}

struct DateInfo: Codable {
    let date: String
    let age: Int
}

/// Helper to handle mixed types for postcode (can be Int or String)
enum CodableValue: Codable {
    case string(String)
    case int(Int)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else if let intValue = try? container.decode(Int.self) {
            self = .int(intValue)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode postcode")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .string(let value):
            try container.encode(value)
        case .int(let value):
            try container.encode(value)
        }
    }
    
    var stringValue: String {
        switch self {
        case .string(let value):
            return value
        case .int(let value):
            return String(value)
        }
    }
}
