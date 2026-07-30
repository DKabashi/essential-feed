import UIKit

public class FeedImageCell: UITableViewCell {
    public let descriptionLabel = UILabel()
    public let imageContainer = UIView()
    public let feedImageView = UIImageView()
    public let locationStackView = UIStackView()
    public let locationLabel = UILabel()

    private let locationIconImageView = UIImageView()
    private let containerStackView = UIStackView()
    private let locationImageContainerView = UIView()
    
    // TODO: Add retry button in ui
    private(set) public lazy var feedImageRetryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var onRetry: (() -> Void)?
    var onReuse: (() -> Void)?
    
    @objc private func retryButtonTapped() {
        onRetry?()
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        onReuse?()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupContainerStackView()
        setupLocationStackView()
        setupLocationImageView()
        setupLocationLabel()
        setupImageContainer()
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
        locationStackView.distribution = .fill
    }
    
    private func setupLocationImageView() {
        locationStackView.addArrangedSubview(locationImageContainerView)
        locationImageContainerView.translatesAutoresizingMaskIntoConstraints = false
        locationIconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        locationImageContainerView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        locationImageContainerView.widthAnchor.constraint(equalToConstant: 30).isActive = true

        locationImageContainerView.addSubview(locationIconImageView)
        locationIconImageView.centerXAnchor.constraint(equalTo: locationImageContainerView.centerXAnchor).isActive = true
        locationIconImageView.centerYAnchor.constraint(equalTo: locationImageContainerView.centerYAnchor).isActive = true
        
        locationIconImageView.image = UIImage(systemName: "pin.square.fill")
        locationIconImageView.contentMode = .scaleAspectFit
        locationIconImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        locationIconImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    private func setupLocationLabel() {
        locationStackView.addArrangedSubview(locationLabel)
    }
    
    private func setupImageContainer() {
        containerStackView.addArrangedSubview(imageContainer)
        imageContainer.translatesAutoresizingMaskIntoConstraints = false
        imageContainer.widthAnchor.constraint(equalTo: containerStackView.widthAnchor).isActive = true
        imageContainer.heightAnchor.constraint(equalTo: containerStackView.widthAnchor).isActive = true
        
        setupFeedImageView()
    }
    
    private func setupFeedImageView() {
        imageContainer.addSubview(feedImageView)
        feedImageView.translatesAutoresizingMaskIntoConstraints = false
        feedImageView.contentMode = .scaleAspectFill
        feedImageView.layer.cornerRadius = 22
        feedImageView.clipsToBounds = true
        feedImageView.topAnchor.constraint(equalTo: imageContainer.topAnchor).isActive = true
        feedImageView.bottomAnchor.constraint(equalTo: imageContainer.bottomAnchor).isActive = true
        feedImageView.leadingAnchor.constraint(equalTo: imageContainer.leadingAnchor).isActive = true
        feedImageView.trailingAnchor.constraint(equalTo: imageContainer.trailingAnchor).isActive = true
    }
    
    private func setupDescriptionLabel() {
        containerStackView.addArrangedSubview(descriptionLabel)
        descriptionLabel.numberOfLines = 6
    }
}
