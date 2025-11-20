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
    let consonant: String           // 초성 자음 기호 (ㄱ)
    let consonantRoman: String      // 초성 자음 로마자 (g)
    let vowel: String               // 중성 모음 기호 (ㅏ)
    let vowelRoman: String          // 중성 모음 로마자 (a)
    let finalConsonant: String      // 종성(받침) 자음 기호 (ㄱ)
    let finalConsonantRoman: String // 종성 로마자 (k)

    let baseSyllable: String        // 초성+중성 음절 (가)
    let baseSyllableRoman: String   // (ga)

    let syllable: String            // 초성+중성+종성 음절 (각)
    let syllableRoman: String       // (gak)
}

// MARK: - Level3 자음/모음/받침 세트

// Level2와 동일한 자음 세트 (14개 평음)
// ㄱㄴㄷㄹㅁㅂㅅㅇㅈㅊㅋㅌㅍㅎ
private let level3Consonants: [(sym: String, roman: String)] = [
    ("ㄱ","g"), ("ㄴ","n"), ("ㄷ","d"),
    ("ㄹ","r"), ("ㅁ","m"), ("ㅂ","b"),
    ("ㅅ","s"), ("ㅇ",""), ("ㅈ","j"),
    ("ㅊ","ch"), ("ㅋ","k"), ("ㅌ","t"),
    ("ㅍ","p"), ("ㅎ","h")
]

// Level2와 동일한 모음 세트
// ㅏ ㅓ ㅗ ㅜ ㅢ ㅐ ㅔ ㅑ ㅕ ㅛ ㅠ ㅒ ㅖ ㅘ ㅙ ㅚ ㅝ ㅞ ㅟ
private let level3Vowels: [(sym: String, roman: String)] = [
    ("ㅏ","a"),  ("ㅓ","eo"), ("ㅗ","o"),  ("ㅜ","u"),  ("ㅢ","ui"),
    ("ㅐ","ae"), ("ㅔ","e"),
    ("ㅑ","ya"), ("ㅕ","yeo"), ("ㅛ","yo"), ("ㅠ","yu"),
    ("ㅒ","yae"), ("ㅖ","ye"),
    ("ㅘ","wa"), ("ㅙ","wae"), ("ㅚ","oe"),
    ("ㅝ","wo"), ("ㅞ","we"), ("ㅟ","wi")
]

// 받침 학습용 기본 종성 세트 (7개)
// ㄱ ㄴ ㄷ ㄹ ㅁ ㅂ ㅇ  → 종성값 체계 기준
private let level3FinalConsonants: [(sym: String, roman: String)] = [
    ("ㄱ", "k"),
    ("ㄴ", "n"),
    ("ㄷ", "t"),
    ("ㄹ", "l"),
    ("ㅁ", "m"),
    ("ㅂ", "p"),
    ("ㅇ", "ng")
]

// MARK: - 합성 헬퍼

/// 유니코드 표준 테이블
private let level3ChoseongTable: [String] = [
    "ㄱ","ㄲ","ㄴ","ㄷ","ㄸ","ㄹ","ㅁ","ㅂ","ㅃ","ㅅ",
    "ㅆ","ㅇ","ㅈ","ㅉ","ㅊ","ㅋ","ㅌ","ㅍ","ㅎ"
]

private let level3JungseongTable: [String] = [
    "ㅏ","ㅐ","ㅑ","ㅒ","ㅓ","ㅔ","ㅕ","ㅖ","ㅗ",
    "ㅘ","ㅙ","ㅚ","ㅛ","ㅜ","ㅝ","ㅞ","ㅟ","ㅠ",
    "ㅡ","ㅢ","ㅣ"
]

// 종성(받침) 테이블 (유니코드 순서, index 0은 받침 없음)
private let level3JongseongTable: [String] = [
    "",   "ㄱ","ㄲ","ㄳ","ㄴ","ㄵ","ㄶ","ㄷ","ㄹ","ㄺ",
    "ㄻ","ㄼ","ㄽ","ㄾ","ㄿ","ㅀ","ㅁ","ㅂ","ㅄ","ㅅ",
    "ㅆ","ㅇ","ㅈ","ㅊ","ㅋ","ㅌ","ㅍ","ㅎ"
]

/// 초성+중성 (받침 없음) 음절 합성
private func composeLevel3BaseSyllable(consonant: String, vowel: String) -> String {
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

/// 초성+중성+종성 음절 합성
private func composeLevel3Syllable(consonant: String, vowel: String, finalConsonant: String) -> String {
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

/// 로마자 합성: (초성+중성) + 종성
/// 예: g + a + k → "gak"
private func composeLevel3Roman(
    consonantRoman: String,
    vowelRoman: String,
    finalConsonantRoman: String
) -> (base: String, full: String) {
    let base = consonantRoman + vowelRoman
    if finalConsonantRoman.isEmpty {
        return (base, base)
    } else {
        return (base, base + finalConsonantRoman)
    }
}

/// Level3용 한 쌍 구성 (base syllable + 받침)
private func combineLevel3(
    _ c: (String,String),
    _ v: (String,String),
    _ f: (String,String)
) -> Level3SyllableConfig {
    let (cs, cr) = c         // 초성
    let (vs, vr) = v         // 중성
    let (fs, fr) = f         // 종성

    let baseSyllable = composeLevel3BaseSyllable(consonant: cs, vowel: vs)
    let fullSyllable = composeLevel3Syllable(consonant: cs, vowel: vs, finalConsonant: fs)
    let (baseRoman, fullRoman) = composeLevel3Roman(
        consonantRoman: cr,
        vowelRoman: vr,
        finalConsonantRoman: fr
    )

    return Level3SyllableConfig(
        consonant: cs,
        consonantRoman: cr,
        vowel: vs,
        vowelRoman: vr,
        finalConsonant: fs,
        finalConsonantRoman: fr,
        baseSyllable: baseSyllable,
        baseSyllableRoman: baseRoman,
        syllable: fullSyllable,
        syllableRoman: fullRoman
    )
}

/// Level3에서 실제 학습에 사용할, 자주 쓰이는 받침 음절 화이트리스트
/// (필요시 추후에 계속 추가/조정 가능)
private let level3AllowedFullSyllables: Set<String> = [
    // ㄱ 받침
    "각","간","갇","갈","감","갑","갓","강","갔","곡",
    "국","군","굴","궁","굿","국","극","긋",
    "먹","막","맥","먹","먹","목","묵","믹",
    "밖","박","밖","복","북","뷱",
    "악","앉","앗","약","역","역","욕","육","익",
    
    // ㄴ 받침
    "간","건","견","견","긴","견","곤","군","근","긴",
    "난","날","남","낭",
    "돈","던","든","딘",
    "문","민","만","면","몬","몬","분","번","본","빤",
    "산","선","손","순","신","쓴","쓴","씬",
    "안","언","언","온","운","은","인","논","칸","춘","윤",
    
    // ㄷ 받침 (t 발음)
    "같","곧","곧","굳","깃","깃",
    "낫","낟","닫","닫","닫","댓","댓",
    "맛","멋","못","믿","밭","붓","빛","옷","있","짓","콧","햇",
    "돋","솓",
    
    // ㄹ 받침
    "갈","걸","골","굴","길","결","걸","멀","물","밀","발","벌","빌","불","살","설","솔","술","실","쌀","열","얼","을","일","잘","절","철","칼","털","팔","할","출",
    
    // ㅁ 받침
    "감","곰","굼","금","김","남","넘","놈","눔","늠","담","덤","돔","듬","팀","밤","봄","붐","빔","삼","섬","솜","숨","슴","심","쌈","앎","엄","옴","움","음","임","잠","점","점","짐","참","춤","힘","맘","둠","캄",
    
    // ㅂ 받침
    "갑","값","겁","겁","곱","굽","급","깁","냅","넙","놉","눕","답","덥","돕","둡","립","맙","멉","몹","밉","법","볍","볍","볶","섭","숍","습","십","씹","업","옆","옆","옵","웁","입","잎","좁","첩","컵","탑","협","합","욥","붑","솝",
    
    // ㅇ 받침
    "강","갱","공","궁","긍","광","괭","굉","굵","당","댕","동","둥","등","딩","땅","땡","똥","똥","망","멍","몽","뭉","밍","방","뱅","봉","붕","빙","쌍","생","송","숭","승","싱","쑹","쌍","생","성","셍","송","숭","승","싱",
    "앙","엉","엉","영","옹","웅","응","잉","양","얍","엽","용","욤","웅","윙","잉","쟁","정","종","중","증","징","청","창","챙","총","충","칭","캉","쿵","킹","탕","탱","통","퉁","팡","펭","퐁","풍","핑","항","행","홍","훙","힝","융","덩",
    // --- 3단계 화이트리스트 추가 항목 ---
    "몰","쿰","융","옥","덜","괜","판","눙","눅","핵","덕",
    "벅","곡","훅","윰","팜","핸","햄","올","범","갭","갤",
    "돌","섹","셉","셀","검","밥","압","알","명","천","캅",
    "먼","멈","욘","냉"
]

// MARK: - Level3 대표 유효 조합
//
// 첫 번째 타일: baseSyllable (초성+중성)
// 두 번째 타일: finalConsonant (받침)
// → 매칭에 성공하면 full syllable(초+중+종)을 만들어서 학습에 사용
//
let level3ValidPairs: [Level3SyllableConfig] = {
    var pairs: [Level3SyllableConfig] = []

    for c in level3Consonants {
        for v in level3Vowels {
            // base(가, 너, 보 등)가 너무 많을 수 있으니,
            // 이후 보드 구성 쪽에서 일부 샘플링해서 사용해도 됨.
            for f in level3FinalConsonants {
                let config = combineLevel3(c, v, f)

                // 화이트리스트에 포함된 실제 사용 음절만 사용
                guard level3AllowedFullSyllables.contains(config.syllable) else {
                    continue
                }

                pairs.append(config)
            }
        }
    }

    return pairs
}()
