import UIKit

public final class ErrorView: UIView {
    public var message: String? {
        get { return isVisible ? errorLabel.text : nil }
        set { setMessageAnimated(newValue) }
    }
    
    private let errorLabel = UILabel()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupErrorLabel()
    }
    
    private func setupView() {
        backgroundColor = .clear
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideMessageAnimated)))
    }
    
    private func setupErrorLabel() {
        addSubview(errorLabel)
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.text = nil
        errorLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        errorLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        errorLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        errorLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var isVisible: Bool {
        return alpha > 0
    }
    
    private func setMessageAnimated(_ message: String?) {
        if let message = message {
            showAnimated(message)
        } else {
            hideMessageAnimated()
        }
    }
    
    private func showAnimated(_ message: String) {
        errorLabel.text = message
        
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
            self.backgroundColor = .red
        }
    }
    
    @objc private func hideMessageAnimated() {
        UIView.animate(
            withDuration: 0.25,
            animations: {
                self.alpha = 0
                self.backgroundColor = .clear
            },
            completion: { completed in
                if completed { self.errorLabel.text = nil }
            })
    }
}
