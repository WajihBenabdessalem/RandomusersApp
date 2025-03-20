//
//  AppCoordinator.swift
//  Randomusers
//
//  Created by Wajih Benabdessalem on 3/12/25.
//

import UIKit

// MARK: - Coordinators

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get }
    
    func start() async
}

protocol UsersCoordinatorDelegate: AnyObject {
    func didFinish(coordinator: Coordinator)
}

class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    @MainActor
    func start() {
        let usersCoordinator = UsersCoordinator(navigationController: navigationController)
        usersCoordinator.delegate = self
        childCoordinators.append(usersCoordinator)
        usersCoordinator.start()
    }
}

extension AppCoordinator: UsersCoordinatorDelegate {
    func didFinish(coordinator: Coordinator) {
        if let index = childCoordinators.firstIndex(where: { $0 === coordinator }) {
            childCoordinators.remove(at: index)
        }
    }
}

// MARK: - UsersCoordinator

class UsersCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    weak var delegate: UsersCoordinatorDelegate?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    @MainActor
    func start() {
        let viewModel = UsersListVM()
        let viewController = UsersListVC(viewModel: viewModel)
        
        viewController.didSelectUser = { [weak self] user in
            self?.showUserDetail(for: user)
        }
        navigationController.pushViewController(viewController, animated: false)
    }
    
    @MainActor
    func showUserDetail(for user: User) {
        let viewModel = UserDetailVM(user: user)
        let viewController = UserDetailVC(viewModel: viewModel)
        
        viewController.didNavigateBack = { [weak self] in
            guard let self = self else { return }
            
            if self.navigationController.viewControllers.count == 1 {
                self.delegate?.didFinish(coordinator: self)
            }
        }
        
        navigationController.pushViewController(viewController, animated: true)
    }
}
