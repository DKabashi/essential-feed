import UIKit

public final class ErrorView: UIView {
    public var message: String?

    private let errorLabel = UILabel()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupErrorLabel()
    }
    
    private func setupView() {
        backgroundColor = .red
        heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
    
    private func setupErrorLabel() {
        addSubview(errorLabel)
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.text = message
        errorLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        errorLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        errorLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        errorLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
