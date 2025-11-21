//
//  Level3Config.swift
//  Hango-ios
//
//  Created by SEUNGSOO HAN on 11/21/25.
//

import Foundation

/// Level3 전용: 받침 학습용 syllable 구성 모델
/// - firstTile: baseSyllable (초성+중성, 예: "가")
/// - secondTile: finalConsonant (받침, 예: "ㄱ")
/// - 최종 음절: syllable (예: "각")
struct Level3SyllableConfig {
    let consonant: String
    let consonantRoman: String
    let vowel: String
    let vowelRoman: String
    let finalConsonant: String
    let finalConsonantRoman: String

    let baseSyllable: String
    let baseSyllableRoman: String

    let syllable: String
    let syllableRoman: String
}

// MARK: - Level3 자음/모음/받침 세트

private let level3Consonants: [(sym: String, roman: String)] = [
    ("ㄱ","g"), ("ㄴ","n"), ("ㄷ","d"),
    ("ㄹ","r"), ("ㅁ","m"), ("ㅂ","b"),
    ("ㅅ","s"), ("ㅇ",""), ("ㅈ","j"),
    ("ㅊ","ch"), ("ㅋ","k"), ("ㅌ","t"),
    ("ㅍ","p"), ("ㅎ","h")
]

private let level3Vowels: [(sym: String, roman: String)] = [
    ("ㅏ","a"),  ("ㅓ","eo"), ("ㅗ","o"),  ("ㅜ","u"),  ("ㅢ","ui"),
    ("ㅐ","ae"), ("ㅔ","e"),
    ("ㅑ","ya"), ("ㅕ","yeo"), ("ㅛ","yo"), ("ㅠ","yu"),
    ("ㅒ","yae"), ("ㅖ","ye"),
    ("ㅘ","wa"), ("ㅙ","wae"), ("ㅚ","oe"),
    ("ㅝ","wo"), ("ㅞ","we"), ("ㅟ","wi")
]

// 받침 학습용 기본 종성 세트 (7개)
private let level3FinalConsonants: [(sym: String, roman: String)] = [
    ("ㄱ", "k"), ("ㄴ", "n"), ("ㄷ", "t"), ("ㄹ", "l"),
    ("ㅁ", "m"), ("ㅂ", "p"), ("ㅇ", "ng")
]

// MARK: - 합성 헬퍼

private let level3ChoseongTable: [String] = [
    "ㄱ","ㄲ","ㄴ","ㄷ","ㄸ","ㄹ","ㅁ","ㅂ","ㅃ","ㅅ",
    "ㅆ","ㅇ","ㅈ","ㅉ","ㅊ","ㅋ","ㅌ","ㅍ","ㅎ"
]

private let level3JungseongTable: [String] = [
    "ㅏ","ㅐ","ㅑ","ㅒ","ㅓ","ㅔ","ㅕ","ㅖ","ㅗ",
    "ㅘ","ㅙ","ㅚ","ㅛ","ㅜ","ㅝ","ㅞ","ㅟ","ㅠ",
    "ㅡ","ㅢ","ㅣ"
]

private let level3JongseongTable: [String] = [
    "",   "ㄱ","ㄲ","ㄳ","ㄴ","ㄵ","ㄶ","ㄷ","ㄹ","ㄺ",
    "ㄻ","ㄼ","ㄽ","ㄾ","ㄿ","ㅀ","ㅁ","ㅂ","ㅄ","ㅅ",
    "ㅆ","ㅇ","ㅈ","ㅊ","ㅋ","ㅌ","ㅍ","ㅎ"
]

// 접근 수준을 공개(internal)로 변경하여 컨트롤러 등에서 사용할 수 있게 함
func composeLevel3BaseSyllable(consonant: String, vowel: String) -> String {
    guard let cIndex = level3ChoseongTable.firstIndex(of: consonant),
          let vIndex = level3JungseongTable.firstIndex(of: vowel) else {
        return consonant + vowel
    }
    let base = 0xAC00
    let syllableIndex = cIndex * 21 * 28 + vIndex * 28 // jongseong 0
    guard let scalar = UnicodeScalar(base + syllableIndex) else {
        return consonant + vowel
    }
    return String(Character(scalar))
}

// 접근 수준을 공개(internal)로 변경하여 컨트롤러 등에서 사용할 수 있게 함
func composeLevel3Syllable(consonant: String, vowel: String, finalConsonant: String) -> String {
    guard let cIndex = level3ChoseongTable.firstIndex(of: consonant),
          let vIndex = level3JungseongTable.firstIndex(of: vowel),
          let fIndex = level3JongseongTable.firstIndex(of: finalConsonant) else {
        return consonant + vowel + finalConsonant
    }
    let base = 0xAC00
    let syllableIndex = cIndex * 21 * 28 + vIndex * 28 + fIndex
    guard let scalar = UnicodeScalar(base + syllableIndex) else {
        return consonant + vowel + finalConsonant
    }
    return String(Character(scalar))
}

private func composeLevel3Roman(
    consonantRoman: String,
    vowelRoman: String,
    finalConsonantRoman: String
) -> (base: String, full: String) {
    let base = consonantRoman + vowelRoman
    return finalConsonantRoman.isEmpty ? (base, base) : (base, base + finalConsonantRoman)
}

private func combineLevel3(
    _ c: (String,String),
    _ v: (String,String),
    _ f: (String,String)
) -> Level3SyllableConfig {
    let (cs, cr) = c
    let (vs, vr) = v
    let (fs, fr) = f

    let baseSyllable = composeLevel3BaseSyllable(consonant: cs, vowel: vs)
    let fullSyllable = composeLevel3Syllable(consonant: cs, vowel: vs, finalConsonant: fs)
    let (baseRoman, fullRoman) = composeLevel3Roman(
        consonantRoman: cr,
        vowelRoman: vr,
        finalConsonantRoman: fr
    )

    return Level3SyllableConfig(
        consonant: cs, consonantRoman: cr,
        vowel: vs, vowelRoman: vr,
        finalConsonant: fs, finalConsonantRoman: fr,
        baseSyllable: baseSyllable, baseSyllableRoman: baseRoman,
        syllable: fullSyllable, syllableRoman: fullRoman
    )
}

// MARK: - 국립국어원 빈도 기반 화이트리스트
//
// 국립국어원의 음절 빈도 자료에서 상위 750개 정도의
// 실제 사용 빈도가 높은 음절만을 화이트리스트로 두고,
// Level3에서 생성되는 최종 음절(syllable: 초+중+종)을
// 이 목록에 포함되는지 여부로 1차 검증한다.
//
// ⚠️ 실제 서비스에서는 아래 배열을 국립국어원 빈도 데이터에서
// 뽑아온 750개 음절로 교체해야 한다.
// 여기서는 구조만 보여주기 위해 예시 몇 개만 넣어 둔다.

/// 국립국어원 빈도 기반 상위 음절 750개(예시)
/// - 실제 프로젝트에서는 별도 JSON/Plist로 관리한 뒤
///   런타임에 로딩하는 것을 권장
let level3FrequentSyllables: Set<String> = Level3SyllableLexicon.frequentSyllables

/// 추가로 반드시 제외할 완성 음절을 직접 지정하고 싶다면 여기에 추가
/// (이상한 비속어, 학습 단계에서 아직 다루고 싶지 않은 음절 등)
let manualFullBlacklist: Set<String> = []

// MARK: - Level3 대표 유효 조합
//
// 첫 번째 타일: baseSyllable (초성+중성)
// 두 번째 타일: finalConsonant (받침)
// → 보드에는 희귀 base와 희귀 full을 모두 제외하고 채움
//
let level3ValidPairs: [Level3SyllableConfig] = {
    var pairs: [Level3SyllableConfig] = []

    for c in level3Consonants {
        for v in level3Vowels {
            for f in level3FinalConsonants {
                let config = combineLevel3(c, v, f)

                // 1) 최종 음절(초+중+종)이 국립국어원 빈도 기반 상위 음절에 포함되는지 검증
                guard level3FrequentSyllables.contains(config.syllable) else {
                    continue
                }

                // 2) 강제로 제외하고 싶은 음절이 있으면 manualFullBlacklist로 필터링
                if manualFullBlacklist.contains(config.syllable) {
                    continue
                }

                pairs.append(config)
            }
        }
    }
    return pairs
}()
