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
        label.font = .systemFont(ofSize: 104, weight: .bold)
        label.textAlignment = .center
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        label.adjustsFontSizeToFitWidth = false
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
        label.numberOfLines = 1
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
        label.numberOfLines = 1
        return label
    }()
    
    // 소리 버튼 (syllableLabel과 설명 라벨들 사이, 오른쪽 정렬)
    private let soundButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "speaker.wave.2.fill")
        button.setImage(image, for: .normal)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.accessibilityLabel = "Play pronunciation"
        return button
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
        label.numberOfLines = 1
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
    
    // 상단 안전 영역 ~ 소리 버튼 사이의 중간점을 위한 가이드
    private let topGuide = UILayoutGuide()
    private let bottomGuide = UILayoutGuide()
    private let midGuide = UILayoutGuide()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .systemBackground
        setupLayout()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        contentView.backgroundColor = AppTheme.Colors.hanjiBackground
        
        // 레이아웃 가이드 추가
        contentView.addLayoutGuide(midGuide)
        
        contentView.addSubview(syllableLabel)
        contentView.addSubview(soundButton)
        contentView.addSubview(consonantTitleLabel)
        contentView.addSubview(consonantDetailLabel)
        contentView.addSubview(vowelTitleLabel)
        contentView.addSubview(vowelDetailLabel)
        contentView.addSubview(combinedTitleLabel)
        contentView.addSubview(combinedDetailLabel)
        contentView.addSubview(tipLabel)
        
        // Tip
        NSLayoutConstraint.activate([
            tipLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tipLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tipLabel.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        // Combined
        NSLayoutConstraint.activate([
            combinedDetailLabel.bottomAnchor.constraint(equalTo: tipLabel.topAnchor, constant: -64),
            combinedDetailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            combinedTitleLabel.bottomAnchor.constraint(equalTo: combinedDetailLabel.topAnchor, constant: -4),
            combinedTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24)
        ])
        
        // Vowel/Final
        NSLayoutConstraint.activate([
            vowelDetailLabel.bottomAnchor.constraint(equalTo: combinedTitleLabel.topAnchor, constant: -24),
            vowelDetailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            vowelTitleLabel.bottomAnchor.constraint(equalTo: vowelDetailLabel.topAnchor, constant: -4),
            vowelTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24)
        ])
        
        // Consonant/Base
        NSLayoutConstraint.activate([
            consonantDetailLabel.bottomAnchor.constraint(equalTo: vowelTitleLabel.topAnchor, constant: -24),
            consonantDetailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            consonantTitleLabel.bottomAnchor.constraint(equalTo: consonantDetailLabel.topAnchor, constant: -4),
            consonantTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24)
        ])
        
        // 소리 버튼
        NSLayoutConstraint.activate([
            soundButton.bottomAnchor.constraint(equalTo: consonantTitleLabel.topAnchor, constant: -24),
            soundButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24)
        ])
        
        // midGuide: safeArea top ↔ soundButton top 사이 중앙 가이드
        NSLayoutConstraint.activate([
            midGuide.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
            midGuide.bottomAnchor.constraint(equalTo: soundButton.topAnchor)
        ])
        
        // 완성된 음절
        NSLayoutConstraint.activate([
            syllableLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            syllableLabel.centerYAnchor.constraint(equalTo: midGuide.centerYAnchor)
        ])
        

//        NSLayoutConstraint.activate([
//            combinedTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            combinedTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            combinedTitleLabel.bottomAnchor.constraint(equalTo: combinedDetailLabel.topAnchor, constant: -4),
//
//            combinedDetailLabel.leadingAnchor.constraint(equalTo: consonantTitleLabel.leadingAnchor),
//            combinedDetailLabel.trailingAnchor.constraint(equalTo: consonantTitleLabel.trailingAnchor),
//            combinedDetailLabel.bottomAnchor.constraint(equalTo: tipLabel.topAnchor, constant: -20)
//        ])
//
//        // Vowel/Final
//        NSLayoutConstraint.activate([
//            vowelTitleLabel.bottomAnchor.constraint(equalTo: vowelDetailLabel.topAnchor, constant: -20),
//            vowelTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            vowelTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//
//            vowelDetailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            vowelDetailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            vowelDetailLabel.bottomAnchor.constraint(equalTo: combinedTitleLabel.topAnchor, constant: -20)
//        ])
//
//        // 소리 버튼: 상단 오른쪽(큰 음절 아래에 올 것이므로 상단 기준으로 배치)
//        NSLayoutConstraint.activate([
//            soundButton.bottomAnchor.constraint(equalTo: vowelTitleLabel.topAnchor, constant: 4),
//            soundButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
//            soundButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
//        ])
//
         // Consonant/Base
//        NSLayoutConstraint.activate([
//            consonantTitleLabel.bottomAnchor.constraint(equalTo: consonantDetailLabel.topAnchor, constant: -4),
//            consonantTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
//            consonantTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
//
//            consonantDetailLabel.bottomAnchor.constraint(equalTo: soundButton.topAnchor, constant: -20),
//            consonantDetailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            consonantDetailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//        ])
//
//        // syllableLabel
//        NSLayoutConstraint.activate([
//            syllableLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor),
//            syllableLabel.bottomAnchor.constraint(equalTo: soundButton.topAnchor)
//        ])
    }
    
    private func setupActions() {
        // 현재 요구사항: 동작 없이 버튼만 생성
        // 향후 발음 재생 로직 연결 시 addTarget 구현
        // soundButton.addTarget(self, action: #selector(didTapSound), for: .touchUpInside)
    }
    
    @objc private func didTapSound() {
        // 향후 발음 재생 구현 예정
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

#if canImport(SwiftUI) && DEBUG
import SwiftUI

/// UICollectionViewCell를 SwiftUI에서 미리보기용으로 감싸는 래퍼
private struct SyllablePageCellPreviewWrapper: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        // 셀 생성
        let cell = SyllablePageCell(frame: CGRect(x: 0, y: 0, width: 390, height: 700))
        
        // 예시 데이터 구성 (필요에 맞게 수정 가능)
        let sampleDetail = LearnedSyllableDetail(
            baseSyllable: "ㄱ",
            baseSyllableRoman: "g",
            finalConsonant: "ㅏ",
            finalConsonantRoman: "a",
            consonant: "각",
            consonantRoman: "gak",
            vowel: "가",
            vowelRoman: "ga",
            syllable: "ㄱ",
            syllableRoman: "k"
        )
        
        cell.configure(with: sampleDetail)
        
        // 오토레이아웃 계산을 위해 레이아웃 강제 업데이트
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        return cell.contentView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // 미리보기에서는 동적 업데이트 불필요
    }
}

struct SyllablePageCell_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SyllablePageCellPreviewWrapper()
                .previewLayout(.fixed(width: 390, height: 700))
                .previewDisplayName("SyllablePageCell - Level3 Example")
            
            SyllablePageCellPreviewWrapper()
                .previewLayout(.sizeThatFits)
                .previewDisplayName("SyllablePageCell - Fitting")
        }
        .background(Color(.systemBackground))
    }
}
#endif
