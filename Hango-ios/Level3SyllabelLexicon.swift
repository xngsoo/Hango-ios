//
//  Level3SyllabelLexicon.swift
//  Hango-ios
//
//  Created by SEUNGSOO HAN on 11/21/25.
//

import Foundation

enum Level3SyllableLexicon {
    static let frequentSyllables: Set<String> = {
        // 1) 번들에서 JSON 파일 위치 찾기
        guard let url = Bundle.main.url(
            forResource: "Level3List",
            withExtension: "json"
        ) else {
            assertionFailure("Level3List.json not found in bundle")
            return []
        }

        do {
            // 2) 파일 데이터 읽기
            let data = try Data(contentsOf: url)

            // 3) [String] 형태로 디코딩
            let list = try JSONDecoder().decode([String].self, from: data)

            // 4) Set으로 변환해서 반환
            return Set(list)
        } catch {
            print("⚠️ Failed to load Level3List.json: \(error)")
            return []
        }
    }()
}
