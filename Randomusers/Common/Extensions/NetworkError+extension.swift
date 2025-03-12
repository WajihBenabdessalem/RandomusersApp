//
//  NetworkError+extension.swift
//  Randomusers
//
//  Created by Wajih Benabdessalem on 3/11/25.
//

import Foundation

extension NetworkError: Equatable {
    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.invalidResponse, .invalidResponse),
             (.noInternetConnection, .noInternetConnection),
             (.unknown, .unknown):
            return true
        case (.serverError(let lCode), .serverError(let rCode)):
            return lCode == rCode
        case (.requestFailed(let lError), .requestFailed(let rError)):
            return lError.localizedDescription == rError.localizedDescription
        case (.decodingFailed(let lError), .decodingFailed(let rError)):
            return lError.localizedDescription == rError.localizedDescription
        default:
            return false
        }
    }
}
