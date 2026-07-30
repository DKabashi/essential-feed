import UIKit
import EssentialFeed

protocol FeedRefreshViewControllerDelegate {
    func didRequestFeedRefresh()
}

public final class FeedRefreshViewController: NSObject, LoadingView {
    public lazy var view: UIRefreshControl = loadView()
    private let delegate: FeedRefreshViewControllerDelegate
    
    init(delegate: FeedRefreshViewControllerDelegate) {
        self.delegate = delegate
    }
    
    @objc func refresh() {
        delegate.didRequestFeedRefresh()
    }
    
    public func display(_ viewModel: LoadingViewModel) {
        update(isRefreshing: viewModel.isLoading)
    }
    
    func loadView() -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
    
    private func update(isRefreshing: Bool) {
        if isRefreshing {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }
}
