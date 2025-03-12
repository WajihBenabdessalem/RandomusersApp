//
//  MockUserLocalDataSource.swift
//  Randomusers
//
//  Created by Wajih Benabdessalem on 3/12/25.
//

import Foundation

class MockUserLocalDataSource: UserLocalDataSource {
    var savedUsers: [User]?
    var saveCalled = false
    
    override func saveUsers(_ users: [User]) async {
        savedUsers = users
        saveCalled = true
    }
    
    override func loadUsers() async -> [User]? {
        return savedUsers
    }
}
