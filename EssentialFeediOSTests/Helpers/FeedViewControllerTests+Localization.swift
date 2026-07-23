import XCTest
import EssentialFeediOS

extension FeedViewControllerTests {
    func localized(_ key: String) -> String {
        let table = "Feed"
        let bundle = Bundle(for: FeedViewController.self)
        let localizedTitle = bundle.localizedString(forKey: key, value: nil, table: table)
        
        if key == localizedTitle {
            XCTFail("Expected a value for key \(key), but got the key instead")
        }
       
        return localizedTitle
    }
}
