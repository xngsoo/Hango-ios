//
//  SyllablePageCell.swift
//  Hango-ios
//
//  Created by SEUNGSOO HAN on 11/19/25.
//

import UIKit

final class SyllablePageCell: UICollectionViewCell {
    
    static let reuseIdentifier = "SyllablePageCell"
    
    private let syllableLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 64, weight: .bold)
        label.textAlignment = .center
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let consonantTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Consonant (초성)"
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let consonantDetailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let vowelTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Vowel (중성)"
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let vowelDetailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let combinedTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Combined syllable"
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let combinedDetailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tipLabel: UILabel = {
        let label = UILabel()
        label.text = "Swipe left/right to review other syllables.\n좌우로 넘기면서 다른 음절도 복습해보세요."
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .tertiaryLabel
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .systemBackground
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        contentView.backgroundColor = AppTheme.Colors.hanjiBackground
        contentView.addSubview(syllableLabel)
        contentView.addSubview(consonantTitleLabel)
        contentView.addSubview(consonantDetailLabel)
        contentView.addSubview(vowelTitleLabel)
        contentView.addSubview(vowelDetailLabel)
        contentView.addSubview(combinedTitleLabel)
        contentView.addSubview(combinedDetailLabel)
        contentView.addSubview(tipLabel)
        
        NSLayoutConstraint.activate([
            // 가운데 큰 음절
            syllableLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            syllableLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -80),
            
            // Consonant/Base
            consonantTitleLabel.topAnchor.constraint(equalTo: syllableLabel.bottomAnchor, constant: 40),
            consonantTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            consonantTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            consonantDetailLabel.topAnchor.constraint(equalTo: consonantTitleLabel.bottomAnchor, constant: 4),
            consonantDetailLabel.leadingAnchor.constraint(equalTo: consonantTitleLabel.leadingAnchor),
            consonantDetailLabel.trailingAnchor.constraint(equalTo: consonantTitleLabel.trailingAnchor),
            
            // Vowel/Final
            vowelTitleLabel.topAnchor.constraint(equalTo: consonantDetailLabel.bottomAnchor, constant: 16),
            vowelTitleLabel.leadingAnchor.constraint(equalTo: consonantTitleLabel.leadingAnchor),
            vowelTitleLabel.trailingAnchor.constraint(equalTo: consonantTitleLabel.trailingAnchor),
            
            vowelDetailLabel.topAnchor.constraint(equalTo: vowelTitleLabel.bottomAnchor, constant: 4),
            vowelDetailLabel.leadingAnchor.constraint(equalTo: consonantTitleLabel.leadingAnchor),
            vowelDetailLabel.trailingAnchor.constraint(equalTo: consonantTitleLabel.trailingAnchor),
            
            // Combined
            combinedTitleLabel.topAnchor.constraint(equalTo: vowelDetailLabel.bottomAnchor, constant: 16),
            combinedTitleLabel.leadingAnchor.constraint(equalTo: consonantTitleLabel.leadingAnchor),
            combinedTitleLabel.trailingAnchor.constraint(equalTo: consonantTitleLabel.trailingAnchor),
            
            combinedDetailLabel.topAnchor.constraint(equalTo: combinedTitleLabel.bottomAnchor, constant: 4),
            combinedDetailLabel.leadingAnchor.constraint(equalTo: consonantTitleLabel.leadingAnchor),
            combinedDetailLabel.trailingAnchor.constraint(equalTo: consonantTitleLabel.trailingAnchor),
            
            // Tip
            tipLabel.topAnchor.constraint(greaterThanOrEqualTo: combinedDetailLabel.bottomAnchor, constant: 24),
            tipLabel.leadingAnchor.constraint(equalTo: consonantTitleLabel.leadingAnchor),
            tipLabel.trailingAnchor.constraint(equalTo: consonantTitleLabel.trailingAnchor),
            tipLabel.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        ])
    }
    
    func configure(with detail: LearnedSyllableDetail) {
        syllableLabel.text = detail.syllable

        if let base = detail.baseSyllable,
           let baseRoman = detail.baseSyllableRoman,
           let final = detail.finalConsonant,
           let finalRoman = detail.finalConsonantRoman {
            // Level3 표시 형식: 음절(초+중), 받침, 조합된 음절
            consonantTitleLabel.text = "Base syllable (초+중)"
            vowelTitleLabel.text = "Final consonant (받침)"
            combinedTitleLabel.text = "Combined syllable"
            
            consonantDetailLabel.text = "\(base)  (\(baseRoman))"
            vowelDetailLabel.text = "\(final)  (\(finalRoman))"
            combinedDetailLabel.text = "\(detail.syllable)  (\(detail.syllableRoman))"
        } else {
            // Level1/2 기존 형식: 초성, 중성, 조합된 음절
            consonantTitleLabel.text = "Consonant (초성)"
            vowelTitleLabel.text = "Vowel (중성)"
            combinedTitleLabel.text = "Combined syllable"
            
            consonantDetailLabel.text = "\(detail.consonant)  (\(detail.consonantRoman))"
            vowelDetailLabel.text = "\(detail.vowel)  (\(detail.vowelRoman))"
            combinedDetailLabel.text = "\(detail.syllable)  (\(detail.syllableRoman))"
        }
    }
}

