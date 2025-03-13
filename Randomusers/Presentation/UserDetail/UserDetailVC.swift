//
//  UserDetailVC.swift
//  Randomusers
//
//  Created by Wajih Benabdessalem on 3/12/25.
//

import UIKit

class UserDetailVC: UIViewController {
    private let viewModel: UserDetailVM
    private let scrollView = UIScrollView()
    private let contentView = UIStackView()
    private let avatarImageView = UIImageView()
    private var imageLoadTask: Task<Void, Never>?
    
    init(viewModel: UserDetailVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureWithViewModel()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        imageLoadTask?.cancel()
    }
    
    private func setupUI() {
        title = viewModel.fullName
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never

        /// Configure scrollView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        
        /// Configure contentView
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.axis = .vertical
        contentView.spacing = 24
        contentView.alignment = .center
        contentView.isLayoutMarginsRelativeArrangement = true
        contentView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        /// Configure avatar image view
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 75
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: 150),
            avatarImageView.heightAnchor.constraint(equalToConstant: 150)
        ])
        
        /// Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addArrangedSubview(avatarImageView)
        
        /// Set constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func configureWithViewModel() {
        /// Load avatar image
        imageLoadTask = Task {
            if let url = viewModel.pictureURL {
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    if !Task.isCancelled {
                        avatarImageView.image = UIImage(data: data)
                    }
                } catch {
                    print("Failed to load profile image: \(error)")
                    avatarImageView.image = UIImage(systemName: "person.circle.fill")
                }
            }
        }
        
        /// Add all user information
        let fields: [(String, String)] = [
            ("Name", viewModel.fullName),
            ("Email", viewModel.email),
            ("Phone", viewModel.phone),
            ("Cell", viewModel.cell),
            ("Gender", viewModel.gender),
            ("Nationality", viewModel.nationality),
            ("Address", viewModel.address),
            ("Postcode", viewModel.postcode),
            ("Date of Birth", viewModel.dateOfBirth),
            ("Registration Date", viewModel.registrationDate)
        ]
        
        for (title, value) in fields {
            let fieldView = createInfoField(title: title, value: value)
            contentView.addArrangedSubview(fieldView)
            
            NSLayoutConstraint.activate([
                fieldView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                fieldView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
            ])
        }
    }
    
    private func createInfoField(title: String, value: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .gray
        
        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.text = value
        valueLabel.font = UIFont.systemFont(ofSize: 17)
        valueLabel.numberOfLines = 0
        
        container.addSubview(titleLabel)
        container.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            valueLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
}
