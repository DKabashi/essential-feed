import UIKit

public final class ErrorView: UIView {
    public var message: String?

    private let errorLabel = UILabel()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupErrorLabel()
    }
    
    private func setupView() {
        backgroundColor = .red
        heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
    
    private func setupErrorLabel() {
        addSubview(errorLabel)
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.text = message
        errorLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        errorLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        errorLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        errorLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public final class FeedViewController: UITableViewController {
    private var isViewIsAppearingCalled = false
    var tableModel = [FeedImageController]() {
        didSet { tableView.reloadData() }
    }

    public var refreshController: FeedRefreshViewController?
    public let errorView = ErrorView()

    public convenience init(refreshController: FeedRefreshViewController) {
        self.init()
        self.refreshController = refreshController
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupRefreshControl()
    }

    private func setupTableView() {
        tableView.prefetchDataSource = self
        tableView.register(FeedImageCell.self, forCellReuseIdentifier: "\(FeedImageCell.self)")
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
    }
    
    private func setupRefreshControl() {
        refreshControl = refreshController?.view
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        if !isViewIsAppearingCalled {
            refreshController?.refresh()
            isViewIsAppearingCalled = true
        }
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableModel[indexPath.row].view(in: tableView)
    }
    
    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // There is a bug in the line below
        //_ = tableModel[indexPath.row].view(in: tableView)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelTask(for: indexPath)
    }
}

extension FeedViewController: UITableViewDataSourcePrefetching {
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach {
            tableModel[$0.row].prefetch()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelTask)
    }
}

extension FeedViewController {
    private func cancelTask(for indexPath: IndexPath) {
        tableModel[indexPath.row].cancelTask()
    }
}

extension FeedViewController: FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel) {
        errorView.message = viewModel.message
    }
}

