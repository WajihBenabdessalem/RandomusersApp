//
//  UserCell.swift
//  Randomusers
//
//  Created by Wajih Benabdessalem on 3/12/25.
//

import UIKit
import Combine

class UserCell: UITableViewCell {
    static let reuseIdentifier = "UserCell"
    
    /// UI Components
    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let emailLabel = UILabel()
    private let stackView = UIStackView()
    
    private var cancellables = Set<AnyCancellable>()
    private var imageLoadTask: Task<Void, Never>?
    
    /// Image cache
    private static let imageCache = NSCache<NSString, UIImage>()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageLoadTask?.cancel()
        avatarImageView.image = nil
        nameLabel.text = nil
        emailLabel.text = nil
    }
    
    private func setupViews() {
        /// Configure avatar image view
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 25
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        
        /// Configure labels
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        emailLabel.font = UIFont.systemFont(ofSize: 14)
        emailLabel.textColor = .gray
        
        /// Configure stack view
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .leading
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(emailLabel)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        /// Add subviews
        contentView.addSubview(avatarImageView)
        contentView.addSubview(stackView)
        
        /// Set constraints
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 50),
            avatarImageView.heightAnchor.constraint(equalToConstant: 50),
            
            stackView.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        /// Add accessory indicator
        accessoryType = .disclosureIndicator
    }
    
    func configure(with user: User) {
        nameLabel.text = user.name.fullName
        emailLabel.text = user.email
        /// Load avatar image with caching
        loadCachedImage(for: user.picture.medium)
    }
    
    private func loadCachedImage(for urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        /// Create a cache key from the URL string
        let cacheKey = NSString(string: urlString)
        
        /// Check if the image is already in the cache
        if let cachedImage = UserCell.imageCache.object(forKey: cacheKey) {
            // Use cached image
            self.avatarImageView.image = cachedImage
            return
        }
        
        /// If not in cache, load from network
        imageLoadTask = Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if !Task.isCancelled, let image = UIImage(data: data) {
                    /// Store in cache
                    UserCell.imageCache.setObject(image, forKey: cacheKey)
                    
                    /// Set the image (on main thread since we're updating UI)
                    await MainActor.run {
                        self.avatarImageView.image = image
                    }
                }
            } catch {
                print("Failed to load image: \(error)")
            }
        }
    }
}
