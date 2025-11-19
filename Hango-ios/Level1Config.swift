//
//  Level1Config.swift
//  Hango-ios
//
//  Created by SEUNGSOO HAN on 11/19/25.
//

import Foundation

// Model/HangeulTile.swift (하단에 추가)

struct Level1SyllableConfig {
    let consonant: String        // ㄱ
    let consonantRoman: String   // g
    let vowel: String            // ㅏ
    let vowelRoman: String       // a
    let syllable: String         // 가
    let syllableRoman: String    // ga
}

// 레벨1에서 사용할 자+모 조합
// 초성: ㄱ ㄴ ㄷ ㄹ ㅁ ㅂ ㅅ
// 중성: ㅏ ㅓ ㅗ ㅜ ㅡ ㅣ
let level1ValidPairs: [Level1SyllableConfig] = [
    // ㅏ (a)
    Level1SyllableConfig(consonant: "ㄱ", consonantRoman: "g", vowel: "ㅏ", vowelRoman: "a", syllable: "가", syllableRoman: "ga"),
    Level1SyllableConfig(consonant: "ㄴ", consonantRoman: "n", vowel: "ㅏ", vowelRoman: "a", syllable: "나", syllableRoman: "na"),
    Level1SyllableConfig(consonant: "ㄷ", consonantRoman: "d", vowel: "ㅏ", vowelRoman: "a", syllable: "다", syllableRoman: "da"),
    Level1SyllableConfig(consonant: "ㄹ", consonantRoman: "r", vowel: "ㅏ", vowelRoman: "a", syllable: "라", syllableRoman: "ra"),
    Level1SyllableConfig(consonant: "ㅁ", consonantRoman: "m", vowel: "ㅏ", vowelRoman: "a", syllable: "마", syllableRoman: "ma"),
    Level1SyllableConfig(consonant: "ㅂ", consonantRoman: "b", vowel: "ㅏ", vowelRoman: "a", syllable: "바", syllableRoman: "ba"),
    Level1SyllableConfig(consonant: "ㅅ", consonantRoman: "s", vowel: "ㅏ", vowelRoman: "a", syllable: "사", syllableRoman: "sa"),
    
    // ㅓ (eo)
    Level1SyllableConfig(consonant: "ㄱ", consonantRoman: "g", vowel: "ㅓ", vowelRoman: "eo", syllable: "거", syllableRoman: "geo"),
    Level1SyllableConfig(consonant: "ㄴ", consonantRoman: "n", vowel: "ㅓ", vowelRoman: "eo", syllable: "너", syllableRoman: "neo"),
    Level1SyllableConfig(consonant: "ㄷ", consonantRoman: "d", vowel: "ㅓ", vowelRoman: "eo", syllable: "더", syllableRoman: "deo"),
    Level1SyllableConfig(consonant: "ㄹ", consonantRoman: "r", vowel: "ㅓ", vowelRoman: "eo", syllable: "러", syllableRoman: "reo"),
    Level1SyllableConfig(consonant: "ㅁ", consonantRoman: "m", vowel: "ㅓ", vowelRoman: "eo", syllable: "머", syllableRoman: "meo"),
    Level1SyllableConfig(consonant: "ㅂ", consonantRoman: "b", vowel: "ㅓ", vowelRoman: "eo", syllable: "버", syllableRoman: "beo"),
    Level1SyllableConfig(consonant: "ㅅ", consonantRoman: "s", vowel: "ㅓ", vowelRoman: "eo", syllable: "서", syllableRoman: "seo"),
    
    // ㅗ (o)
    Level1SyllableConfig(consonant: "ㄱ", consonantRoman: "g", vowel: "ㅗ", vowelRoman: "o", syllable: "고", syllableRoman: "go"),
    Level1SyllableConfig(consonant: "ㄴ", consonantRoman: "n", vowel: "ㅗ", vowelRoman: "o", syllable: "노", syllableRoman: "no"),
    Level1SyllableConfig(consonant: "ㄷ", consonantRoman: "d", vowel: "ㅗ", vowelRoman: "o", syllable: "도", syllableRoman: "do"),
    Level1SyllableConfig(consonant: "ㄹ", consonantRoman: "r", vowel: "ㅗ", vowelRoman: "o", syllable: "로", syllableRoman: "ro"),
    Level1SyllableConfig(consonant: "ㅁ", consonantRoman: "m", vowel: "ㅗ", vowelRoman: "o", syllable: "모", syllableRoman: "mo"),
    Level1SyllableConfig(consonant: "ㅂ", consonantRoman: "b", vowel: "ㅗ", vowelRoman: "o", syllable: "보", syllableRoman: "bo"),
    Level1SyllableConfig(consonant: "ㅅ", consonantRoman: "s", vowel: "ㅗ", vowelRoman: "o", syllable: "소", syllableRoman: "so"),
    
    // ㅜ (u)
    Level1SyllableConfig(consonant: "ㄱ", consonantRoman: "g", vowel: "ㅜ", vowelRoman: "u", syllable: "구", syllableRoman: "gu"),
    Level1SyllableConfig(consonant: "ㄴ", consonantRoman: "n", vowel: "ㅜ", vowelRoman: "u", syllable: "누", syllableRoman: "nu"),
    Level1SyllableConfig(consonant: "ㄷ", consonantRoman: "d", vowel: "ㅜ", vowelRoman: "u", syllable: "두", syllableRoman: "du"),
    Level1SyllableConfig(consonant: "ㄹ", consonantRoman: "r", vowel: "ㅜ", vowelRoman: "u", syllable: "루", syllableRoman: "ru"),
    Level1SyllableConfig(consonant: "ㅁ", consonantRoman: "m", vowel: "ㅜ", vowelRoman: "u", syllable: "무", syllableRoman: "mu"),
    Level1SyllableConfig(consonant: "ㅂ", consonantRoman: "b", vowel: "ㅜ", vowelRoman: "u", syllable: "부", syllableRoman: "bu"),
    Level1SyllableConfig(consonant: "ㅅ", consonantRoman: "s", vowel: "ㅜ", vowelRoman: "u", syllable: "수", syllableRoman: "su"),
    
    // ㅡ (eu)
    Level1SyllableConfig(consonant: "ㄱ", consonantRoman: "g", vowel: "ㅡ", vowelRoman: "eu", syllable: "그", syllableRoman: "geu"),
    Level1SyllableConfig(consonant: "ㄴ", consonantRoman: "n", vowel: "ㅡ", vowelRoman: "eu", syllable: "느", syllableRoman: "neu"),
    Level1SyllableConfig(consonant: "ㄷ", consonantRoman: "d", vowel: "ㅡ", vowelRoman: "eu", syllable: "드", syllableRoman: "deu"),
    Level1SyllableConfig(consonant: "ㄹ", consonantRoman: "r", vowel: "ㅡ", vowelRoman: "eu", syllable: "르", syllableRoman: "reu"),
    Level1SyllableConfig(consonant: "ㅁ", consonantRoman: "m", vowel: "ㅡ", vowelRoman: "eu", syllable: "므", syllableRoman: "meu"),
    Level1SyllableConfig(consonant: "ㅂ", consonantRoman: "b", vowel: "ㅡ", vowelRoman: "eu", syllable: "브", syllableRoman: "beu"),
    Level1SyllableConfig(consonant: "ㅅ", consonantRoman: "s", vowel: "ㅡ", vowelRoman: "eu", syllable: "스", syllableRoman: "seu"),
    
    // ㅣ (i)
    Level1SyllableConfig(consonant: "ㄱ", consonantRoman: "g", vowel: "ㅣ", vowelRoman: "i", syllable: "기", syllableRoman: "gi"),
    Level1SyllableConfig(consonant: "ㄴ", consonantRoman: "n", vowel: "ㅣ", vowelRoman: "i", syllable: "니", syllableRoman: "ni"),
    Level1SyllableConfig(consonant: "ㄷ", consonantRoman: "d", vowel: "ㅣ", vowelRoman: "i", syllable: "디", syllableRoman: "di"),
    Level1SyllableConfig(consonant: "ㄹ", consonantRoman: "r", vowel: "ㅣ", vowelRoman: "i", syllable: "리", syllableRoman: "ri"),
    Level1SyllableConfig(consonant: "ㅁ", consonantRoman: "m", vowel: "ㅣ", vowelRoman: "i", syllable: "미", syllableRoman: "mi"),
    Level1SyllableConfig(consonant: "ㅂ", consonantRoman: "b", vowel: "ㅣ", vowelRoman: "i", syllable: "비", syllableRoman: "bi"),
    Level1SyllableConfig(consonant: "ㅅ", consonantRoman: "s", vowel: "ㅣ", vowelRoman: "i", syllable: "시", syllableRoman: "si")
]
