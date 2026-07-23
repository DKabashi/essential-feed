import UIKit

extension UIImageView {
    func setImageWithFadeAnimation(_ newImage: UIImage?) {
        image = newImage
        
        guard newImage != nil else { return }
        alpha = 0
        
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
}
