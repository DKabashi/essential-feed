import UIKit
import EssentialFeed

public class FeedViewController: UITableViewController {
    private var loader: FeedLoader?
    private var isViewIsAppearingCalled = false

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
        
        loader?.loadFeed { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }
}
