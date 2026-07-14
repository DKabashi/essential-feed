import UIKit
import EssentialFeed

public final class FeedViewController: UITableViewController {
    private var imageLoader: FeedImageDataLoader?
    private var isViewIsAppearingCalled = false
    private var tableModel = [FeedImage]() {
        didSet { tableView.reloadData() }
    }
    private var feedImageControllers = [IndexPath: FeedImageController]()

    public var refreshController: FeedRefreshViewController?
    
    public convenience init(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) {
        self.init()
        self.imageLoader = imageLoader
        self.refreshController = FeedRefreshViewController(feedLoader: feedLoader)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        tableView.prefetchDataSource = self
        refreshControl = refreshController?.view
        refreshController?.onRefresh = { [weak self] feed in
            self?.tableModel = feed
        }
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
        return cellController(forRowAt: indexPath).createView()
    }
    
    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let controller = feedImageControllers[indexPath]
        controller?.loadImage()
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        removeCellController(for: indexPath)
    }
}

extension FeedViewController: UITableViewDataSourcePrefetching {
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach {
            cellController(forRowAt: $0).prefetch()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(removeCellController)
    }
}

extension FeedViewController {
    private func cellController(forRowAt indexPath: IndexPath) -> FeedImageController {
        let item = tableModel[indexPath.row]
        let feedImageController = FeedImageController(model: item, imageLoader: imageLoader!)
        feedImageControllers[indexPath] = feedImageController
        return feedImageController
    }
    
    private func removeCellController(for indexPath: IndexPath) {
        feedImageControllers[indexPath] = nil
    }
}

