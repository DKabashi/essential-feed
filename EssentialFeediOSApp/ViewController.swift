import UIKit

class FeedCellView: UITableViewCell {
    private let locationLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let locationIconImageView = UIImageView()
    private let feedImageView = UIImageView()
    private let locationStackView = UIStackView()
    private let containerStackView = UIStackView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupContainerStackView()
        setupLocationStackView()
        setupLocationIconImageView()
        setupLocationLabel()
        setupFeedImageView()
        setupDescriptionLabel()
    }
    
    func updateLocationLabel(with text: String) {
        locationLabel.text = text
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupContainerStackView() {
        contentView.addSubview(containerStackView)
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        containerStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        containerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        containerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
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
        locationIconImageView.image = UIImage(systemName: "mappin.and.ellipse")
        locationIconImageView.contentMode = .scaleAspectFit
        locationIconImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        locationIconImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    private func setupLocationLabel() {
        locationStackView.addArrangedSubview(locationLabel)
    }
    
    private func setupFeedImageView() {
        containerStackView.addArrangedSubview(feedImageView)
        feedImageView.image = UIImage(named: "dummy-image")
        feedImageView.contentMode = .scaleAspectFill
        feedImageView.widthAnchor.constraint(equalTo: containerStackView.widthAnchor).isActive = true
        feedImageView.heightAnchor.constraint(equalToConstant: 300).isActive = true
    }
    
    private func setupDescriptionLabel() {
        containerStackView.addArrangedSubview(descriptionLabel)
        descriptionLabel.text = "Description brrr brrr"
    }
}

class ViewController: UITableViewController {
    let data = ["Link", "Zelda", "Ganon"]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.register(FeedCellView.self, forCellReuseIdentifier: "\(FeedCellView.self)")
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(FeedCellView.self)", for: indexPath) as! FeedCellView
        cell.updateLocationLabel(with: data[indexPath.row])
        return cell
    }
}
