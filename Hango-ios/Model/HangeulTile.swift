//
//  HangeulTile.swift
//  Hango-ios
//
//  Created by SEUNGSOO HAN on 11/19/25.
//

import Foundation

enum HangeulTileType {
    case consonant      // 자음
    case vowel          // 모음
}

struct HangeulTile {
    let id: UUID = UUID()
    let symbol: String              // "ㄱ", "ㅏ" 같은 실제 표시 문자열
    let type: HangeulTileType
    var isRemoved: Bool = false
}

struct LearnedSyllableDetail {
    let consonant: String
    let consonantRoman: String
    let vowel: String
    let vowelRoman: String
    let syllable: String
    let syllableRoman: String
}
