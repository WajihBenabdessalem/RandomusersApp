//
//  ErrorHandler.swift
//  Randomusers
//
//  Created by Wajih Benabdessalem on 3/11/25.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingFailed(Error)
    case noInternetConnection
    case serverError(Int)
    case unknown
    
    var message: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .requestFailed(let error):
            return "Request failed: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid server response"
        case .decodingFailed(let error):
            return "Failed to decode data: \(error.localizedDescription)"
        case .noInternetConnection:
            return "No internet connection available"
        case .serverError(let code):
            return "Server error with code: \(code)"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}
