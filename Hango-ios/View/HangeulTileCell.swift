//
//  HangeulTileCell.swift
//  Hango-ios
//
//  Created by SEUNGSOO HAN on 11/19/25.
//

import UIKit

class HangeulTileCell: UICollectionViewCell {
    
    static let reuseIdentifier: String = "HangeulTileCell"
    
    private let symbolLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        contentView.backgroundColor = .white
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        contentView.addSubview(symbolLabel)
        NSLayoutConstraint.activate([
            symbolLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            symbolLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // 재사용 시 항상 초기 상태로 복원
        contentView.alpha = 1.0
        contentView.backgroundColor = .white
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        isUserInteractionEnabled = true
        symbolLabel.text = nil
    }
    
    func configure(with tile: HangeulTile) {
        if tile.isRemoved {
            // 제거된 타일은 보이지 않게 처리
            contentView.alpha = 0.0
            contentView.layer.borderColor = UIColor.clear.cgColor
            symbolLabel.text = nil
            isUserInteractionEnabled = false
        } else {
            // 정상 타일은 초기 상태를 확실히 보장
            contentView.alpha = 1.0
            contentView.backgroundColor = .white // 선택 잔상 제거
            contentView.layer.borderColor = UIColor.lightGray.cgColor
            isUserInteractionEnabled = true
            symbolLabel.text = tile.symbol
        }
    }
    
    func setSelectedAppearance(_ selected: Bool, type: HangeulTileType) {
        guard contentView.alpha > 0.0 else { return } // 제거된 셀은 무시
        if selected {
            switch type {
            case .consonant:
                contentView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
            case .vowel:
                contentView.backgroundColor = UIColor.systemPink.withAlphaComponent(0.2)
            }
        } else {
            contentView.backgroundColor = .white
        }
    }
    
    func playWrongAnimation() {
        let animation = CAKeyframeAnimation(keyPath: "position.x")
        animation.values = [0, -5, 5, -5, 5, 0]
        animation.keyTimes = [0, 0.1, 0.3, 0.5, 0.7, 1]
        animation.duration = 0.25
        animation.isAdditive = true
        layer.add(animation, forKey: "shake")
    }
    
    
}
