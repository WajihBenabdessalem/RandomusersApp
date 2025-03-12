//
//  MockUserRemoteDataSource.swift
//  Randomusers
//
//  Created by Wajih Benabdessalem on 3/12/25.
//

import Foundation

class MockUserRemoteDataSource: UserRemoteDataSource {
    var mockUsers: [User]?
    var mockError: Error?
    
    override func fetchUsers() async throws -> [User] {
        if let error = mockError {
            throw error
        }
        return mockUsers ?? []
    }
}
