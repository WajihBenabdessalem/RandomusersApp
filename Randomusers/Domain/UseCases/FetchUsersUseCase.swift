//
//  FetchUsersUseCase.swift
//  Randomusers
//
//  Created by Wajih Benabdessalem on 3/12/25.
//

import Foundation

class FetchUsersUseCase {
    private let repository: UserRepositoryProtocol
    
    init(repository: UserRepositoryProtocol = UserRepository()) {
        self.repository = repository
    }
    
    func execute() async throws -> [User] {
        /// Trying to fetch from network first
        do {
            return try await repository.fetchUsers(page: 1)
        } catch NetworkError.noInternetConnection {
            /// If no internet, i am trying to load from cache
            if let cachedUsers = await repository.loadCachedUsers(), !cachedUsers.isEmpty {
                return cachedUsers
            } else {
                throw NetworkError.noInternetConnection
            }
        } catch {
            /// For other errors, also i am trying to load from cache as fallback
            if let cachedUsers = await repository.loadCachedUsers(), !cachedUsers.isEmpty {
                return cachedUsers
            } else {
                throw error
            }
        }
    }
    
    func loadMoreUsers(page: Int) async throws -> [User] {
        return try await repository.fetchUsers(page: page)
    }
}
