import UIKit
import EssentialFeed

public class FeedViewController: UITableViewController {
    private var loader: FeedLoader?
    private var isViewIsAppearingCalled = false
    private var tableModel = [FeedImage]()

    public convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
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
        
        loader?.loadFeed { [weak self] result in
            self?.tableModel = (try? result.get()) ?? []
            self?.tableView.reloadData()
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
        
        return feedImageCell
    }
}
