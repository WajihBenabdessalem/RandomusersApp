//
//  UserLocalDataSource.swift
//  Randomusers
//
//  Created by Wajih Benabdessalem on 3/12/25.
//

import Foundation

class UserLocalDataSource {
    private let userDefaults = UserDefaults.standard
    private let usersKey = "cached_users"
    
    func saveUsers(_ users: [User]) async {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(users)
            userDefaults.set(data, forKey: usersKey)
        } catch {
            print("Failed to save users: \(error)")
        }
    }
    
    func loadUsers() async -> [User]? {
        guard let data = userDefaults.data(forKey: usersKey) else {
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode([User].self, from: data)
        } catch {
            print("Failed to load users: \(error)")
            return nil
        }
    }
}
