//
//  HangeulTile.swift
//  Hango-ios
//
//  Created by SEUNGSOO HAN on 11/19/25.
//

import Foundation

enum HangeulTileType {
    case consonant      // 자음 (Level3에서는 baseSyllable 슬롯 재사용)
    case vowel          // 모음 (Level3에서는 finalConsonant 슬롯 재사용)
}

struct HangeulTile {
    let id: UUID = UUID()
    let symbol: String              // "ㄱ", "ㅏ" 같은 실제 표시 문자열 (Level3에선 "가", "ㄱ" 등)
    let type: HangeulTileType
    var isRemoved: Bool = false
}

// 공통 리뷰용 모델
// - Level1/2: consonant/vowel/syllable* 필드 사용
// - Level3: baseSyllable/finalConsonant/syllable* 필드 사용
struct LearnedSyllableDetail {
    // Level1/2용
    let consonant: String
    let consonantRoman: String
    let vowel: String
    let vowelRoman: String
    let syllable: String
    let syllableRoman: String

    // Level3용 (옵셔널)
    let baseSyllable: String?
    let baseSyllableRoman: String?
    let finalConsonant: String?
    let finalConsonantRoman: String?

    // 편의 이니셜라이저 (Level1/2)
    init(consonant: String, consonantRoman: String,
         vowel: String, vowelRoman: String,
         syllable: String, syllableRoman: String) {
        self.consonant = consonant
        self.consonantRoman = consonantRoman
        self.vowel = vowel
        self.vowelRoman = vowelRoman
        self.syllable = syllable
        self.syllableRoman = syllableRoman

        self.baseSyllable = nil
        self.baseSyllableRoman = nil
        self.finalConsonant = nil
        self.finalConsonantRoman = nil
    }

    // 편의 이니셜라이저 (Level3)
    init(baseSyllable: String, baseSyllableRoman: String,
         finalConsonant: String, finalConsonantRoman: String,
         consonant: String, consonantRoman: String,
         vowel: String, vowelRoman: String,
         syllable: String, syllableRoman: String) {

        // Level1/2 필드도 채워두면 일관된 정렬/표시에 활용 가능
        self.consonant = consonant
        self.consonantRoman = consonantRoman
        self.vowel = vowel
        self.vowelRoman = vowelRoman
        self.syllable = syllable
        self.syllableRoman = syllableRoman

        self.baseSyllable = baseSyllable
        self.baseSyllableRoman = baseSyllableRoman
        self.finalConsonant = finalConsonant
        self.finalConsonantRoman = finalConsonantRoman
    }
}

