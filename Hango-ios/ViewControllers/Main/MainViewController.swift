//
//  MainViewController.swift
//  Hango-ios
//
//  Created by SEUNGSOO HAN on 11/19/25.
//

import UIKit

final class MainViewController: UIViewController {

    private let stack = UIStackView()
    private let levels = ["Level 1", "Level 2", "Level 3", "Level 4", "Level 5"]

    override func viewDidLoad() {
        super.viewDidLoad()
        AppTheme.applyNavigationBarAppearance()
        view.backgroundColor = AppTheme.Colors.hanjiBackground
        title = "Hango"

        setupStack()
        setupLevelButtons()
    }

    private func setupStack() {
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupLevelButtons() {
        for (index, title) in levels.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.setTitleColor(AppTheme.Colors.danBlue, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
            button.backgroundColor = AppTheme.Colors.surface
            button.layer.cornerRadius = AppTheme.Metrics.cornerRadius
            button.heightAnchor.constraint(equalToConstant: 56).isActive = true
            button.tag = index + 1
            button.addTarget(self, action: #selector(didTapLevel(_:)), for: .touchUpInside)
            stack.addArrangedSubview(button)
        }
    }

    @objc private func didTapLevel(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            navigationController?.pushViewController(Level1ViewController(), animated: true)
        case 2:
            navigationController?.pushViewController(Level2ViewController(), animated: true)
        case 3:
            navigationController?.pushViewController(Level3ViewController(), animated: true)
        case 4:
            navigationController?.pushViewController(Level4ViewController(), animated: true)
        case 5:
            navigationController?.pushViewController(Level5ViewController(), animated: true)
        default:
            break
        }
    }

}
