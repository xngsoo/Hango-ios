//
//  Level4ViewController.swift
//  Hango-ios
//
//  Created by SEUNGSOO HAN on 11/19/25.
//

import UIKit

final class Level4ViewController: UIViewController {

    private let infoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppTheme.Fonts.displayLarge()
        label.textColor = AppTheme.Colors.ink
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "Level 4\n(Coming soon)"
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        AppTheme.applyNavigationBarAppearance()
        view.backgroundColor = AppTheme.Colors.hanjiBackground
        title = "Level 4"

        view.addSubview(infoLabel)
        NSLayoutConstraint.activate([
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            infoLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

}
