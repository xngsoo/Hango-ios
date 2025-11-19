import UIKit

final class MainViewController: UIViewController {
    
    private let stack = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Select Level"
        view.backgroundColor = .systemBackground
        setupUI()
    }
    
    private func setupUI() {
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        let buttons = (1...5).map { level -> UIButton in
            let b = UIButton(type: .system)
            b.setTitle("Level \(level)", for: .normal)
            b.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
            b.backgroundColor = .secondarySystemBackground
            b.layer.cornerRadius = 10
            b.tag = level
            b.heightAnchor.constraint(equalToConstant: 56).isActive = true
            b.addTarget(self, action: #selector(didTapLevel(_:)), for: .touchUpInside)
            return b
        }
        
        buttons.forEach { stack.addArrangedSubview($0) }
        
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func didTapLevel(_ sender: UIButton) {
        if sender.tag == 1 {
            let vc = GameViewController()
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let alert = UIAlertController(title: "Coming soon",
                                          message: "Level \(sender.tag) is not available yet.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
}
