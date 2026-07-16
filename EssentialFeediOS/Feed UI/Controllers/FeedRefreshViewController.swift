import UIKit

public final class FeedRefreshViewController: NSObject {
    public lazy var view: UIRefreshControl = binded(UIRefreshControl())
    private let viewModel: FeedViewModel
    
    init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
    }
    
    @objc func refresh() {
        viewModel.loadFeed()
    }
    
    func binded(_ refreshControl: UIRefreshControl) -> UIRefreshControl {
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        viewModel.onChange = { [weak self] model in
            if model.isLoading {
                self?.view.beginRefreshing()
            } else {
                self?.view.endRefreshing()
            }
        }
        
        return refreshControl
    }
}
