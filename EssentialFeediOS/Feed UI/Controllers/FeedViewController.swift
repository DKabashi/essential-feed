import UIKit

public final class FeedViewController: UITableViewController {
    private var isViewIsAppearingCalled = false
    var tableModel = [FeedImageController]() {
        didSet { tableView.reloadData() }
    }

    public var refreshController: FeedRefreshViewController?
    
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
        _ = tableModel[indexPath.row].view(in: tableView)
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

