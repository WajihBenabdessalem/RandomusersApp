//
//  UserRepository.swift
//  Randomusers
//
//  Created by Wajih Benabdessalem on 3/11/25.
//

import Foundation

class UserRepository: UserRepositoryProtocol {
    private let remoteDataSource: UserRemoteDataSource
    private let localDataSource: UserLocalDataSource
    
    init(remoteDataSource: UserRemoteDataSource = UserRemoteDataSource(),
         localDataSource: UserLocalDataSource = UserLocalDataSource()) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }
    
    func fetchUsers() async throws -> [User] {
        do {
            let users = try await remoteDataSource.fetchUsers()
            /// Cache the fetched users
            await localDataSource.saveUsers(users)
            return users
        } catch {
            throw error
        }
    }
    
    func loadCachedUsers() async -> [User]? {
        return await localDataSource.loadUsers()
    }
}
