//
//  UsersListVC.swift
//  Randomusers
//
//  Created by Wajih Benabdessalem on 3/12/25.
//

import UIKit
import Combine

class UsersListVC: UIViewController {
    private let viewModel: UsersListVM
    private var cancellables = Set<AnyCancellable>()
    
    // UI Components
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let errorView = UIView()
    private let errorLabel = UILabel()
    private let retryButton = UIButton(type: .system)
    private let offlineView = UIView()
    private let offlineLabel = UILabel()
    
    var didSelectUser: ((User) -> Void)?
    
    init(viewModel: UsersListVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        
        Task {
            await viewModel.fetchUsers()
        }
    }
    
    private func setupUI() {
        title = "Users List"
        view.backgroundColor = .systemBackground
        
        /// Configure navigation bar
        navigationController?.navigationBar.prefersLargeTitles = true
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshButtonTapped))
        navigationItem.rightBarButtonItem = refreshButton
        
        /// Configure tableView
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UserCell.self, forCellReuseIdentifier: UserCell.reuseIdentifier)
        tableView.rowHeight = 70
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16 + 50 + 16, bottom: 0, right: 0)
        
        /// Configure refreshControl
        refreshControl.addTarget(self, action: #selector(refreshDataPulled), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        /// Configure activityIndicator
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        
        /// Configure error view
        errorView.translatesAutoresizingMaskIntoConstraints = false
        errorView.isHidden = true
        errorView.backgroundColor = .systemBackground
        
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        errorLabel.textColor = .systemRed
        
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        retryButton.setTitle("Retry", for: .normal)
        retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        
        errorView.addSubview(errorLabel)
        errorView.addSubview(retryButton)
        
        /// Configure offline view
        offlineView.translatesAutoresizingMaskIntoConstraints = false
        offlineView.backgroundColor = .systemYellow.withAlphaComponent(0.9)
        offlineView.isHidden = true
        
        offlineLabel.translatesAutoresizingMaskIntoConstraints = false
        offlineLabel.text = "You are offline. Displaying cached data."
        offlineLabel.textAlignment = .center
        offlineLabel.textColor = .black
        offlineLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        
        offlineView.addSubview(offlineLabel)
        
        /// Add subviews
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        view.addSubview(errorView)
        view.addSubview(offlineView)
        
        /// Set constraints for tableView and activityIndicator
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            errorView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            errorLabel.leadingAnchor.constraint(equalTo: errorView.leadingAnchor, constant: 20),
            errorLabel.trailingAnchor.constraint(equalTo: errorView.trailingAnchor, constant: -20),
            errorLabel.centerYAnchor.constraint(equalTo: errorView.centerYAnchor, constant: -30),
            
            retryButton.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
            retryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 20),
            
            offlineView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            offlineView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            offlineView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            offlineView.heightAnchor.constraint(equalToConstant: 40),
            
            offlineLabel.leadingAnchor.constraint(equalTo: offlineView.leadingAnchor, constant: 10),
            offlineLabel.trailingAnchor.constraint(equalTo: offlineView.trailingAnchor, constant: -10),
            offlineLabel.centerYAnchor.constraint(equalTo: offlineView.centerYAnchor)
        ])
    }
    
    private func setupBindings() {
        /// Bind users for table updates
        viewModel.$users
            .receive(on: RunLoop.main)
            .sink { [weak self] users in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        /// Bind loading state
        viewModel.$isLoading
            .receive(on: RunLoop.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.activityIndicator.startAnimating()
                    self?.tableView.isHidden = true
                    self?.errorView.isHidden = true
                } else {
                    self?.activityIndicator.stopAnimating()
                    self?.tableView.isHidden = false
                    self?.refreshControl.endRefreshing()
                }
            }
            .store(in: &cancellables)
        
        /// Bind error state
        viewModel.$apiError
            .receive(on: RunLoop.main)
            .sink { [weak self] error in
                if let error = error, self?.viewModel.users.isEmpty == true {
                    self?.errorLabel.text = error
                    self?.errorView.isHidden = false
                    self?.tableView.isHidden = true
                } else {
                    self?.errorView.isHidden = true
                }
            }
            .store(in: &cancellables)
        
        /// Bind network connectivity
        viewModel.$isConnected
            .receive(on: RunLoop.main)
            .sink { [weak self] isConnected in
                if !isConnected && self?.viewModel.users.isEmpty == false {
                    self?.offlineView.isHidden = false
                } else {
                    self?.offlineView.isHidden = true
                }
            }
            .store(in: &cancellables)
    }
    
    @objc private func refreshButtonTapped() {
        Task {
            await viewModel.refreshUsers()
        }
    }
    
    @objc private func refreshDataPulled() {
        Task {
            await viewModel.refreshUsers()
        }
    }
    
    @objc private func retryButtonTapped() {
        Task {
            await viewModel.fetchUsers()
        }
    }
}

// MARK: - UITableView DataSource & Delegate
extension UsersListVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.reuseIdentifier, for: indexPath) as? UserCell else {
            return UITableViewCell()
        }
        
        let user = viewModel.users[indexPath.row]
        cell.configure(with: user)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let user = viewModel.users[indexPath.row]
        didSelectUser?(user)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if viewModel.shouldLoadMoreUsers(at: indexPath.row) {
            Task {
                await viewModel.loadMoreUsers()
            }
        }
    }
}
