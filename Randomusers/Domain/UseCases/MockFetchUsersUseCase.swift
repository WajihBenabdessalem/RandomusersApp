//
//  MockFetchUsersUseCase.swift
//  Randomusers
//
//  Created by Wajih Benabdessalem on 3/12/25.
//

import Foundation

class MockFetchUsersUseCase: FetchUsersUseCase {

    var mockUsers: [User]?
    var mockMoreUsers: [User]?
    var mockError: Error?
    
    override func execute() async throws -> [User] {
        if let error = mockError {
            throw error
        }
        return mockUsers ?? []
    }
    
    override func loadMoreUsers(page: Int) async throws -> [User] {
        if let error = mockError {
            throw error
        }
        return mockMoreUsers ?? []
    }
}
