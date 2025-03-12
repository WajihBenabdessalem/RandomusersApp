//
//  UserRepositoryTests.swift
//  RandomusersTests
//
//  Created by Wajih Benabdessalem on 3/12/25.
//

import XCTest
@testable import Randomusers

final class UserRepositoryTests: XCTestCase {
    
    var mockRemoteDataSource: MockUserRemoteDataSource!
    var mockLocalDataSource: MockUserLocalDataSource!
    var repository: UserRepository!
    
    override func setUp() {
        super.setUp()
        mockRemoteDataSource = MockUserRemoteDataSource()
        mockLocalDataSource = MockUserLocalDataSource()
        repository = UserRepository(remoteDataSource: mockRemoteDataSource, localDataSource: mockLocalDataSource)
    }
    
    func testFetchUsersSuccess() async throws {
        // Given
        let mockUsers = createMockUsers(count: 10)
        mockRemoteDataSource.mockUsers = mockUsers
        
        // When
        let users = try await repository.fetchUsers()
        
        // Then
        XCTAssertEqual(users.count, 10)
        XCTAssertEqual(users[0].name.first, "John")
        
        // Verify users were cached
        XCTAssertTrue(mockLocalDataSource.saveCalled)
    }
    
    func testFetchUsersFailure() async {
        // Given
        mockRemoteDataSource.mockError = NetworkError.serverError(500)
        
        // When/Then
        do {
            _ = try await repository.fetchUsers()
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertEqual(error as? NetworkError, NetworkError.serverError(500))
            XCTAssertFalse(mockLocalDataSource.saveCalled)
        }
    }
    
    func testLoadCachedUsers() async {
        // Given
        let mockUsers = createMockUsers(count: 5)
        mockLocalDataSource.savedUsers = mockUsers
        
        // When
        let cachedUsers = await repository.loadCachedUsers()
        
        // Then
        XCTAssertEqual(cachedUsers?.count, 5)
        XCTAssertEqual(cachedUsers?[0].name.first, "John")
    }
    
    private func createMockUsers(count: Int) -> [User] {
        var users: [User] = []
        
        for i in 0..<count {
            let user = User(
                id: User.ID(name: "SSN", value: "123-\(i)"),
                name: Name(title: "Mr", first: "John", last: "Doe\(i)"),
                email: "john.doe\(i)@example.com",
                phone: "123-456-789\(i)",
                cell: "987-654-321\(i)",
                picture: Picture(
                    large: "https://example.com/large\(i).jpg",
                    medium: "https://example.com/medium\(i).jpg",
                    thumbnail: "https://example.com/thumbnail\(i).jpg"
                ),
                location: Location(
                    street: Location.Street(number: 123, name: "Main St"),
                    city: "New York",
                    state: "NY",
                    country: "USA",
                    postcode: .int(10001),
                    coordinates: Coordinates(latitude: "40.7128", longitude: "-74.0060"),
                    timezone: Timezone(offset: "-4:00", description: "Eastern Time")
                ),
                dob: DateInfo(date: "1990-01-01T00:00:00.000Z", age: 33),
                registered: DateInfo(date: "2010-01-01T00:00:00.000Z", age: 13),
                nat: "US",
                gender: "male"
            )
            users.append(user)
        }
        
        return users
    }
}
