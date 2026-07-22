import UIKit

public class FeedImageCell: UITableViewCell {
    public let locationLabel = UILabel()
    public let descriptionLabel = UILabel()
    public let imageContainer = UIView()
    public let feedImageView = UIImageView()
    private let locationIconImageView = UIImageView()
    private let locationStackView = UIStackView()
    private let containerStackView = UIStackView()
    
    // TODO: Add retry button in ui
    private(set) public lazy var feedImageRetryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var onRetry: (() -> Void)?
    
    @objc private func retryButtonTapped() {
        onRetry?()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupContainerStackView()
        setupLocationStackView()
        setupLocationIconImageView()
        setupLocationLabel()
        setupFeedImageView()
        setupDescriptionLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: UI Setup

public extension FeedImageCell {
    private func setupContainerStackView() {
        contentView.addSubview(containerStackView)
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        containerStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        containerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        containerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        containerStackView.axis = .vertical
        containerStackView.spacing = 10
        containerStackView.isLayoutMarginsRelativeArrangement = true
        containerStackView.directionalLayoutMargins = .init(top: 5, leading: 0, bottom: 0, trailing: 0)
    }
    
    private func setupLocationStackView() {
        containerStackView.addArrangedSubview(locationStackView)
        locationStackView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        locationStackView.axis = .horizontal
        locationStackView.alignment = .center
        locationStackView.spacing = 6
    }
    
    private func setupLocationIconImageView() {
        locationStackView.addArrangedSubview(locationIconImageView)
        locationIconImageView.image = UIImage(named: "pin")
        locationIconImageView.contentMode = .scaleAspectFit
        locationIconImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        locationIconImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    private func setupLocationLabel() {
        locationStackView.addArrangedSubview(locationLabel)
    }
    
    private func setupFeedImageView() {
        containerStackView.addArrangedSubview(feedImageView)
        feedImageView.contentMode = .scaleAspectFill
        feedImageView.layer.cornerRadius = 22
        feedImageView.clipsToBounds = true
        feedImageView.widthAnchor.constraint(equalTo: containerStackView.widthAnchor).isActive = true
        feedImageView.heightAnchor.constraint(equalTo: containerStackView.widthAnchor).isActive = true
    }
    
    private func setupDescriptionLabel() {
        containerStackView.addArrangedSubview(descriptionLabel)
        descriptionLabel.numberOfLines = 6
    }
}
