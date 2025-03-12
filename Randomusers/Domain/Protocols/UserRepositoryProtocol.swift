//
//  UserRepositoryProtocol.swift
//  Randomusers
//
//  Created by Wajih Benabdessalem on 3/11/25.
//

import Foundation

protocol UserRepositoryProtocol {
    func fetchUsers() async throws -> [User]
    func loadCachedUsers() async -> [User]?
}
