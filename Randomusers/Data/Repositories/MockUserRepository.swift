//
//  MockUserRepository.swift
//  Randomusers
//
//  Created by Wajih Benabdessalem on 3/12/25.
//

import Foundation

class MockUserRepository: UserRepositoryProtocol {
    var mockUsers: [User]?
    var cachedUsers: [User]?
    var mockError: Error?
    
    func fetchUsers(page: Int) async throws -> [User] {
        if let error = mockError {
            throw error
        }
        return mockUsers ?? []
    }
    
    func loadCachedUsers() async -> [User]? {
        return cachedUsers
    }
}
