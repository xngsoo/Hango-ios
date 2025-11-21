//
//  Level2Config.swift
//  Hango-ios
//
//  Created by SEUNGSOO HAN on 11/19/25.
//

import Foundation

// Level2 전용 syllable 구성 모델
struct Level2SyllableConfig {
    let consonant: String
    let consonantRoman: String
    let vowel: String
    let vowelRoman: String
    let syllable: String
    let syllableRoman: String
}

// 평음(초성) 14개
// 표기는 학습 편의용 간단 표기
private let level2Consonants: [(sym: String, roman: String)] = [
    ("ㄱ","g"), ("ㄴ","n"), ("ㄷ","d"),
    ("ㄹ","r"), ("ㅁ","m"), ("ㅂ","b"),
    ("ㅅ","s"), ("ㅇ",""), ("ㅈ","j"),
    ("ㅊ", "ch"), ("ㅋ", "k"), ("ㅌ","t"),
    ("ㅍ", "p"), ("ㅎ", "h")
]

// 단모음 + 기본 이중모음 (Level2 전용)
// ㅏ ㅓ ㅗ ㅜ ㅢ ㅐ ㅔ ㅑ ㅕ ㅛ ㅠ ㅒ ㅖ ㅘ ㅙ ㅚ ㅝ ㅞ ㅟ ㅢ
private let level2Vowels: [(sym: String, roman: String)] = [
    ("ㅏ","a"),  ("ㅓ","eo"), ("ㅗ","o"),  ("ㅜ","u"),  ("ㅢ","ui"),
    ("ㅐ","ae"), ("ㅔ","e"),
    ("ㅑ","ya"), ("ㅕ","yeo"), ("ㅛ","yo"), ("ㅠ","yu"),
    ("ㅒ","yae"), ("ㅖ","ye"),
    ("ㅘ","wa"), ("ㅙ","wae"), ("ㅚ","oe"),
    ("ㅝ","wo"), ("ㅞ","we"), ("ㅟ","wi")
]

// Level1 구성 요약 (비교 및 빈도 가중용)
private let level1ConsonantsSet: Set<String> = ["ㄱ","ㄴ","ㄷ","ㄹ","ㅁ","ㅂ","ㅅ"]
private let level1VowelsSet: Set<String> = ["ㅏ","ㅓ","ㅗ","ㅜ","ㅡ","ㅣ"]

// Level2에서 새로 추가된 자음/모음
private let newlyAddedConsonants: [(sym: String, roman: String)] =
    level2Consonants.filter { !level1ConsonantsSet.contains($0.sym) }
private let newlyAddedVowels: [(sym: String, roman: String)] =
    level2Vowels.filter { !level1VowelsSet.contains($0.sym) }

// 대표 조합을 생성하는 헬퍼
private func combine(_ c: (String,String), _ v: (String,String)) -> Level2SyllableConfig {
    let (cs, cr) = c
    let (vs, vr) = v
    // 초성+중성으로만 음절 구성 (받침 없음)
    // iOS에서 한글 합성은 유니코드 조합을 직접 만들 수도 있으나, 여기서는 미리 정의된 대표 음절을 생성
    // 간단화: cs+vs를 실제 가능한 표준 음절로 매핑
    let syllable = composeSyllable(consonant: cs, vowel: vs)
    let roman = composeRoman(consonantRoman: cr, vowelRoman: vr)
    return Level2SyllableConfig(consonant: cs, consonantRoman: cr,
                                vowel: vs, vowelRoman: vr,
                                syllable: syllable, syllableRoman: roman)
}

// 간단 로마자 결합
private func composeRoman(consonantRoman: String, vowelRoman: String) -> String {
    return consonantRoman + vowelRoman
}

// 초성+중성으로 가능한 표준 음절을 생성
// 유니코드 한글 음절 조합 규칙(초성 19, 중성 21, 종성 28)에 맞게 인덱스를 계산
private func composeSyllable(consonant: String, vowel: String) -> String {
    // 유니코드 표준 초성 테이블 (19개)
    let fullChoseong = [
        "ㄱ","ㄲ","ㄴ","ㄷ","ㄸ","ㄹ","ㅁ","ㅂ","ㅃ","ㅅ",
        "ㅆ","ㅇ","ㅈ","ㅉ","ㅊ","ㅋ","ㅌ","ㅍ","ㅎ"
    ]
    // 유니코드 표준 중성 테이블 (21개)
    let jungseong = [
        "ㅏ","ㅐ","ㅑ","ㅒ","ㅓ","ㅔ","ㅕ","ㅖ","ㅗ",
        "ㅘ","ㅙ","ㅚ","ㅛ","ㅜ","ㅝ","ㅞ","ㅟ","ㅠ",
        "ㅡ","ㅢ","ㅣ"
    ]

    guard let cIndex = fullChoseong.firstIndex(of: consonant),
          let vIndex = jungseong.firstIndex(of: vowel) else {
        // 매칭 실패 시 간단 결합 문자열로 fallback
        return consonant + vowel
    }

    let base = 0xAC00
    let syllableIndex = cIndex * 21 * 28 + vIndex * 28 // jongseong 0
    guard let scalar = UnicodeScalar(base + syllableIndex) else {
        return consonant + vowel
    }
    return String(Character(scalar))
}

// Level2의 대표 유효 조합
// - Level1 항목도 포함하되, 새로 추가된 자음/모음의 비중을 높임
// - 아래 배열은 “대표” 조합이며, 실제 보드 구성 시 중복 샘플링으로 빈도 가중
let level2ValidPairs: [Level2SyllableConfig] = {
    var pairs: [Level2SyllableConfig] = []

    // 1) Level1 기본 자음 × Level1 기본 모음: 기본 학습 유지 (저빈도)
    for c in level2Consonants where level1ConsonantsSet.contains(c.sym) {
        for v in level2Vowels where level1VowelsSet.contains(v.sym) {
            pairs.append(combine(c, v))
        }
    }

    // 2) 새로 추가된 자음 × Level1 기본 모음: 가중치 높게
    for c in newlyAddedConsonants {
        for v in level2Vowels where level1VowelsSet.contains(v.sym) {
            // 같은 조합을 여러 번 넣어 빈도 가중
            pairs.append(combine(c, v))
            pairs.append(combine(c, v))
        }
    }

    // 3) Level1 기본 자음 × 새로 추가된 모음: 가중치 높게
    for c in level2Consonants where level1ConsonantsSet.contains(c.sym) {
        for v in newlyAddedVowels {
            pairs.append(combine(c, v))
            pairs.append(combine(c, v))
        }
    }

    // 4) 새로 추가된 자음 × 새로 추가된 모음: 최상 가중
    for c in newlyAddedConsonants {
        for v in newlyAddedVowels {
            pairs.append(combine(c, v))
            pairs.append(combine(c, v))
            pairs.append(combine(c, v))
        }
    }

    // 중복 제거는 하지 않음: 의도적으로 빈도 가중을 유지
    return pairs
}()
