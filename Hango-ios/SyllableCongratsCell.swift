import UIKit

final class SyllableCongratsCell: UICollectionViewCell {
    static let reuseIdentifier = "SyllableCongratsCell"
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.numberOfLines = 0
        l.font = .systemFont(ofSize: 24, weight: .bold)
        l.textColor = .label
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let backButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Back to Main", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    private var action: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .systemBackground
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            backButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            backButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
        
        backButton.addTarget(self, action: #selector(tapBack), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func configure(message: String, buttonTitle: String, onTap: @escaping () -> Void) {
        titleLabel.text = message
        backButton.setTitle(buttonTitle, for: .normal)
        action = onTap
    }
    
    @objc private func tapBack() {
        action?()
    }
}
