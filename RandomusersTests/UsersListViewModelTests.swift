//
//  UsersListViewModelTests.swift
//  RandomusersTests
//
//  Created by Wajih Benabdessalem on 3/12/25.
//

import XCTest
@testable import Randomusers

final class UsersListViewModelTests: XCTestCase {
    
    var mockUseCase: MockFetchUsersUseCase!
    var viewModel: UsersListVM!
    
    @MainActor
    override func setUp() {
        super.setUp()
        mockUseCase = MockFetchUsersUseCase()
        viewModel = UsersListVM(fetchUsersUseCase: mockUseCase)
    }
    
    @MainActor
    func testFetchUsersSuccess() async {
        // Given
        let mockUsers = createMockUsers(count: 10)
        mockUseCase.mockUsers = mockUsers
        
        // When
        await viewModel.fetchUsers()
        
        // Then
        XCTAssertEqual(viewModel.users.count, 10)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.apiError)
    }
    
    @MainActor
    func testFetchUsersFailure() async {
        // Given
        mockUseCase.mockError = NetworkError.serverError(500)
        
        // When
        await viewModel.fetchUsers()
        
        // Then
        XCTAssertTrue(viewModel.users.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.apiError, NetworkError.serverError(500).message)
    }
    
    @MainActor
    func testLoadMoreUsers() async {
        // Given
        let initialUsers = createMockUsers(count: 10)
        let moreUsers = createMockUsers(count: 10)
        mockUseCase.mockUsers = initialUsers
        mockUseCase.mockMoreUsers = moreUsers
        
        // When
        await viewModel.fetchUsers()
        await viewModel.loadMoreUsers()
        
        // Then
        XCTAssertEqual(viewModel.users.count, 20)
    }
    
    private func createMockUsers(count: Int) -> [User] {
        // Same mock user generator as other tests
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
