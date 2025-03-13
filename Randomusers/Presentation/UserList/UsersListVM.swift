//
//  UsersListVM.swift
//  Randomusers
//
//  Created by Wajih Benabdessalem on 3/12/25.
//

import Foundation
import Combine

@MainActor
class UsersListVM {
    private let fetchUsersUseCase: FetchUsersUseCase
    private var cancellables = Set<AnyCancellable>()
    
    /// Published properties
    @Published var users: [User] = []
    @Published var filteredUsers: [User] = []
    @Published var isLoading = false
    @Published var apiError: String? = nil
    @Published var isConnected = true
    @Published var isLoadingMore = false
    @Published var searchText: String = ""
    
    /// Paging
    private var currentPage = 1
    private var hasMorePages = true
    private var allUsers: [User] = []
    
    init(fetchUsersUseCase: FetchUsersUseCase = FetchUsersUseCase()) {
        self.fetchUsersUseCase = fetchUsersUseCase
        setupNetworkMonitoring()
        setupSearchBinding()
    }
    
    private func setupNetworkMonitoring() {
        NetworkMonitor.shared.statusPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] isConnected in
                self?.isConnected = isConnected
                if isConnected && self?.users.isEmpty == true {
                    Task {
                        await self?.fetchUsers()
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupSearchBinding() {
        /// Observe searchText changes and filter users accordingly
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] searchText in
                self?.filterUsers(searchText: searchText)
            }
            .store(in: &cancellables)
    }
    
    private func filterUsers(searchText: String) {
        if searchText.isEmpty {
            filteredUsers = allUsers
        } else {
            filteredUsers = allUsers.filter { user in
                // Modify this based on your User model properties
                user.name.fullName.localizedCaseInsensitiveContains(searchText) ||
                user.email.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    func fetchUsers() async {
        guard !isLoading else { return }
        
        isLoading = true
        apiError = nil
        defer { isLoading = false }

        do {
            allUsers = try await fetchUsersUseCase.execute()
            filterUsers(searchText: searchText)
            currentPage = 1
            hasMorePages = true
        } catch let networkError as NetworkError {
            apiError = networkError.message
        } catch {
            apiError = error.localizedDescription
        }
    }
    
    func loadMoreUsers() async {
        guard !isLoading && !isLoadingMore && hasMorePages && isConnected else { return }
        
        isLoadingMore = true
        defer { isLoadingMore = false }

        do {
            let nextPage = currentPage + 1
            let newUsers = try await fetchUsersUseCase.loadMoreUsers(page: nextPage)
            if newUsers.isEmpty {
                hasMorePages = false
            } else {
                allUsers.append(contentsOf: newUsers)
                filterUsers(searchText: searchText)
                currentPage = nextPage
            }
        } catch {
            print("Failed to load more users: \(error.localizedDescription)")
        }
    }
    
    func shouldLoadMoreUsers(at index: Int) -> Bool {
        /// Loading more when user is looking at the last few items
        return index >= filteredUsers.count - 3 && hasMorePages && !isLoadingMore && isConnected && searchText.isEmpty
    }
    
    func refreshUsers() async {
        await fetchUsers()
    }
}
