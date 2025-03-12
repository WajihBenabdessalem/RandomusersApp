//
//  UserRemoteDataSource.swift
//  Randomusers
//
//  Created by Wajih Benabdessalem on 3/12/25.
//

import Foundation

class UserRemoteDataSource {
    private let networkService: NetworkService
    private let baseURL = "https://randomuser.me/api/?results=10"
    
    init(networkService: NetworkService = NetworkService()) {
        self.networkService = networkService
    }
    
    func fetchUsers() async throws -> [User] {
        if !NetworkMonitor.shared.isConnected {
            throw NetworkError.noInternetConnection
        }
        
        let response: UserResponse = try await networkService.fetch(from: baseURL)
        return response.results
    }
}
