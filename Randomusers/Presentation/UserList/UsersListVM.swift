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
    @Published var isLoading = false
    @Published var apiError: String? = nil
    @Published var isConnected = true
    
    /// Paging
    private var currentPage = 1
    private var hasMorePages = true
    private var isLoadingMore = false
    
    init(fetchUsersUseCase: FetchUsersUseCase = FetchUsersUseCase()) {
        self.fetchUsersUseCase = fetchUsersUseCase
        setupNetworkMonitoring()
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
    
    func fetchUsers() async {
        guard !isLoading else { return }
        
        isLoading = true
        apiError = nil
        
        do {
            users = try await fetchUsersUseCase.execute()
            currentPage = 1
            hasMorePages = true
        } catch let networkError as NetworkError {
            apiError = networkError.message
        } catch {
            apiError = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func loadMoreUsers() async {
        guard !isLoading && !isLoadingMore && hasMorePages && isConnected else { return }
        
        isLoadingMore = true
        
        do {
            let nextPage = currentPage + 1
            let newUsers = try await fetchUsersUseCase.loadMoreUsers(page: nextPage)
            if newUsers.isEmpty {
                hasMorePages = false
            } else {
                users.append(contentsOf: newUsers)
                currentPage = nextPage
            }
        } catch {
            print("Failed to load more users: \(error.localizedDescription)")
        }
        
        isLoadingMore = false
    }
    
    func shouldLoadMoreUsers(at index: Int) -> Bool {
        /// Loading more when user is looking at the last few items
        return index >= users.count - 3 && hasMorePages && !isLoadingMore && isConnected
    }
    
    func refreshUsers() async {
        await fetchUsers()
    }
}
