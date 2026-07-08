import UIKit
import EssentialFeed

public protocol FeedImageDataLoader {
    func loadImageData(from url: URL)
    func cancelImageDataLoad(for url: URL)
}

public class FeedViewController: UITableViewController {
    private var feedLoader: FeedLoader?
    private var imageLoader: FeedImageDataLoader?
    private var isViewIsAppearingCalled = false
    private var tableModel = [FeedImage]()

    public convenience init(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) {
        self.init()
        self.feedLoader = feedLoader
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        if !isViewIsAppearingCalled {
            load()
            isViewIsAppearingCalled = true
        }
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        
        feedLoader?.loadFeed { [weak self] result in
            if let feed = try? result.get() {
                self?.tableModel = feed
                self?.tableView.reloadData()
            }
            self?.refreshControl?.endRefreshing()
        }
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = tableModel[indexPath.row]
        
        let feedImageCell = FeedImageCell()
        feedImageCell.locationLabel.isHidden = item.location == nil
        feedImageCell.locationLabel.text = item.location
        feedImageCell.descriptionLabel.text = item.description
        
        imageLoader?.loadImageData(from: item.url)
        
        return feedImageCell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let item = tableModel[indexPath.row]
        
        imageLoader?.cancelImageDataLoad(for: item.url)
    }
}
