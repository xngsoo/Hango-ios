//
//  GameViewController.swift
//  Hango-ios
//
//  Created by SEUNGSOO HAN on 11/19/25.
//

import UIKit

/// 메인 게임 화면
class GameViewController: UIViewController {

    // 상단 상태 라벨
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 28, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private var collectionView: UICollectionView!
    private let numberOfColumns: Int = 6
    private let numberOfRowsMax: Int = 10
    
    // 전체 타일 배열 (그리드 순서대로)
    private var tiles: [HangeulTile] = []
    // 현재 선택된 인덱스 (최대 2개)
    private var selectedIndexPaths: [IndexPath] = []
    
    private var numberOfRows: Int {
        guard !tiles.isEmpty else { return 0 }
        return Int(ceil(Double(tiles.count) / Double(numberOfColumns)))
    }
    
    // 경로 오버레이 뷰 + 레이어
    private let pathOverlayView = UIView()
    private let pathLayer = CAShapeLayer()
    
    // 조합한 음절 저장
    // key: 음절 (가), value: 상세 정보
    private var learnedSyllables: [String: LearnedSyllableDetail] = [:]
    
    // 최대 타일 개수
    private var maxTilesCount: Int {
        return numberOfColumns * numberOfRowsMax
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "Level 1"
        
        setupStatusLabel()
        setupCollectionView()
        setupPathOverlay()
        setupLevel1Tiles()
    }

    private func setupStatusLabel() {
        view.addSubview(statusLabel)
        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 8
        layout.minimumLineSpacing = 8

        let sidePadding: CGFloat = 16
        let totalSpacing = CGFloat(numberOfColumns - 1) * layout.minimumInteritemSpacing
        let itemWidth = (view.bounds.width - sidePadding * 2 - totalSpacing) / CGFloat(numberOfColumns)
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(HangeulTileCell.self, forCellWithReuseIdentifier: HangeulTileCell.reuseIdentifier)

        view.addSubview(collectionView)

        // 한글 타일 그리드를 화면 하단에 붙이기 위해, 컬렉션뷰 높이를 10행 기준으로 고정하고
        // 하단 safe area에 붙인다.
        let rows = numberOfRowsMax
        let gridHeight = itemWidth * CGFloat(rows)
            + layout.minimumLineSpacing * CGFloat(rows - 1)

        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: sidePadding),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -sidePadding),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            collectionView.heightAnchor.constraint(equalToConstant: gridHeight),
            collectionView.topAnchor.constraint(greaterThanOrEqualTo: statusLabel.bottomAnchor, constant: 16)
        ])
    }
    
    private func setupPathOverlay() {
        // 중복 추가 방지: 이미 superview에 붙어 있다면 레이어 상태만 초기화
        if pathOverlayView.superview == nil {
            pathOverlayView.translatesAutoresizingMaskIntoConstraints = false
            pathOverlayView.backgroundColor = .clear
            pathOverlayView.isUserInteractionEnabled = false
            
            view.addSubview(pathOverlayView)
            
            NSLayoutConstraint.activate([
                pathOverlayView.topAnchor.constraint(equalTo: collectionView.topAnchor),
                pathOverlayView.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
                pathOverlayView.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
                pathOverlayView.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor)
            ])
            
            pathLayer.strokeColor = UIColor.systemYellow.cgColor
            pathLayer.lineWidth = 4
            pathLayer.lineJoin = .round
            pathLayer.lineCap = .round
            pathLayer.fillColor = UIColor.clear.cgColor
            pathLayer.opacity = 0.0
            
            pathOverlayView.layer.addSublayer(pathLayer)
        } else {
            // 이미 존재하면 상태 초기화만
            pathLayer.path = nil
            pathLayer.opacity = 0.0
        }
    }

    private func setupLevel1Tiles() {
        tiles = generateRandomBoard()
        collectionView.reloadData()
        
        // 시작하자마자 조합 불가인 경우 바로 클리어 안내 (이론상 드묾)
        checkLevelClear()
    }
    
    /// 6 x 10 보드를 랜덤으로 채우는 함수
    /// - level1ValidPairs를 기반으로 자/모 타일을 섞어서 maxTilesCount 개까지 채운다.
    private func generateRandomBoard() -> [HangeulTile] {
        var pool: [HangeulTile] = []
        
        // 1) 우선 각 조합당 1세트씩 넣기 (자 + 모)
        for pair in level1ValidPairs {
            pool.append(HangeulTile(symbol: pair.consonant, type: .consonant))
            pool.append(HangeulTile(symbol: pair.vowel, type: .vowel))
        }
        
        // 2) 보드 칸 수(60개)를 채울 때까지 랜덤하게 추가로 채우기
        var index = 0
        while pool.count < maxTilesCount {
            let pair = level1ValidPairs[index % level1ValidPairs.count]
            pool.append(HangeulTile(symbol: pair.consonant, type: .consonant))
            pool.append(HangeulTile(symbol: pair.vowel, type: .vowel))
            index += 1
        }
        
        // 3) 섞고, 딱 60개만 남기기
        pool.shuffle()
        if pool.count > maxTilesCount {
            pool = Array(pool.prefix(maxTilesCount))
        }
        
        return pool
    }
}

extension GameViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tiles.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: HangeulTileCell.reuseIdentifier,
            for: indexPath
        ) as? HangeulTileCell else {
            return UICollectionViewCell()
        }
        
        let tile = tiles[indexPath.item]
        cell.configure(with: tile)
        
        // 선택 표시 갱신
        let isSelected = selectedIndexPaths.contains(indexPath)
        cell.setSelectedAppearance(isSelected, type: tile.type)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        handleSelect(at: indexPath)
    }

    private func handleSelect(at indexPath: IndexPath) {
        // 이미 제거된 타일은 무시
        guard tiles[indexPath.item].isRemoved == false else { return }
        
        // 이미 선택된 셀을 다시 누르면 해제
        if let idx = selectedIndexPaths.firstIndex(of: indexPath) {
            selectedIndexPaths.remove(at: idx)
            collectionView.reloadItems(at: [indexPath])
            updateSelectionStatusForCurrentSelection()
            return
        }
        
        // 최대 두 개까지만 선택
        if selectedIndexPaths.count >= 2 {
            // 이전 선택 초기화 후 새로 선택
            let old = selectedIndexPaths
            selectedIndexPaths.removeAll()
            selectedIndexPaths.append(indexPath)
            collectionView.reloadItems(at: old + [indexPath])
            updateSelectionStatusForCurrentSelection()
            return
        }
        
        selectedIndexPaths.append(indexPath)

        // 선택된 타일 정보 디버그 출력
        if let first = selectedIndexPaths.first, selectedIndexPaths.count == 1 {
            let item = first.item
            let tile = tiles[item]
            let pos = position(for: item)
            let typeText = (tile.type == .consonant) ? "자음" : "모음"
            print("🟡 첫번째 선택한 타일: \(tile.symbol) [\(typeText)] [\(pos.row + 1), \(pos.col + 1)], index=\(item + 1)")
        } else if selectedIndexPaths.count == 2 {
            let second = selectedIndexPaths[1]
            let item = second.item
            let tile = tiles[item]
            let pos = position(for: item)
            let typeText = (tile.type == .consonant) ? "자음" : "모음"
            print("🔵 두번째 선택한 타일: \(tile.symbol) [\(typeText)] [\(pos.row + 1), \(pos.col + 1)], index=\(item + 1)")
        }

        collectionView.reloadItems(at: [indexPath])
        updateSelectionStatusForCurrentSelection()
        
        if selectedIndexPaths.count == 2 {
            checkPair()
        }
    }

    // 선택 상태에 따라 statusLabel을 갱신
    private func updateSelectionStatusForCurrentSelection() {
        switch selectedIndexPaths.count {
        case 0:
            // 선택이 없을 때는 비워둔다.
            statusLabel.text = ""
        case 1:
            let idx = selectedIndexPaths[0].item
            let tile = tiles[idx]
            statusLabel.text = tile.symbol
        case 2:
            let firstTile = tiles[selectedIndexPaths[0].item]
            let secondTile = tiles[selectedIndexPaths[1].item]
            statusLabel.text = "\(firstTile.symbol)  +  \(secondTile.symbol)"
        default:
            break
        }
    }

    private func checkPair() {
        guard selectedIndexPaths.count == 2 else { return }
        
        let firstIndex = selectedIndexPaths[0]
        let secondIndex = selectedIndexPaths[1]
        
        let firstTile = tiles[firstIndex.item]
        let secondTile = tiles[secondIndex.item]
        
        // 타입 조합 상태
        let isCV = (firstTile.type == .consonant && secondTile.type == .vowel)
        let isSameType = (firstTile.type == secondTile.type)
        
        // 1️⃣ 자+자 / 모+모 → 애초에 음절 후보도 아님
        if isSameType {
            let combination = "\(firstTile.symbol)+\(secondTile.symbol)"
            if firstTile.type == .consonant {
                print("❌ 실패: 자음+자음 결합 허용되지 않음 -> \(combination)")
            } else {
                print("❌ 실패: 모음+모음 결합 허용되지 않음 -> \(combination)")
            }
            // 타입 조합 자체가 잘못된 경우 (Consonant + vowel only)
            playWrongFeedback()
            return
        }
        
        // 2️⃣ 여기까지 왔으면 "자음 하나, 모음 하나"인 조합 (C+V 또는 V+C)
        //    → 자/모를 순서와 무관하게 찾아둔다
        let consonantTile: HangeulTile
        let vowelTile: HangeulTile
        let consonantIndex: IndexPath
        let vowelIndex: IndexPath
        
        if firstTile.type == .consonant {
            consonantTile = firstTile
            consonantIndex = firstIndex
            vowelTile = secondTile
            vowelIndex = secondIndex
        } else {
            consonantTile = secondTile
            consonantIndex = secondIndex
            vowelTile = firstTile
            vowelIndex = firstIndex
        }
        
        // 3️⃣ level1ValidPairs에 정의된 유효 자+모 조합인지 확인
        guard let pair = level1ValidPairs.first(where: {
            $0.consonant == consonantTile.symbol && $0.vowel == vowelTile.symbol
        }) else {
            let combination = "\(consonantTile.symbol) + \(vowelTile.symbol)"
            print("❌ 실패: 허용되지 않은 자음+모음 조합 —> \(combination)")
            // 자+모이긴 한데, 이 게임 레벨에서 허용한 조합은 아님
            playWrongFeedback()
            return
        }
        
        // 4️⃣ 블락 여부 먼저 확인 (순서와 무관하게)
        guard let gridPath = findPath(consonantIndex, vowelIndex) else {
            let combination = "\(consonantTile.symbol) + \(vowelTile.symbol)"
            let posC = position(for: consonantIndex.item)
            let posV = position(for: vowelIndex.item)
            print("❌ 실패: 경로 막힘 —> \(combination) C[row=\(posC.row), col=\(posC.col)], V[row=\(posV.row), col=\(posV.col)]")
            // 길이 아예 안 나오면 → 막힌 상태라고 안내
            playBlockedFeedback()
            return
        }
        
        // 5️⃣ 여기까지 왔으면:
        //    - 자/모 조합도 유효하고
        //    - 실제로 연결 가능한 길도 있음
        //    마지막으로 "사용자가 선택한 순서"를 체크한다.
        guard isCV else {
            let combination = "\(firstTile.symbol)+\(secondTile.symbol)"
            print("❌ 실패: 모음+자음 순서 —> 먼저 자음, 그 다음 모음을 선택해야 함. 선택: \(combination)")
            // 모음→자음 순서로 선택한 경우
            playWrongOrderFeedback()
            return
        }
        
        // 6️⃣ 모든 조건 통과 → 정답 처리
        showConnectionPath(gridPath: gridPath) { [weak self] in
            guard let self = self else { return }
            self.handleCorrectPair(firstIndex: firstIndex,
                                   secondIndex: secondIndex,
                                   pair: pair)
        }
    }
    
    private func playBlockedFeedback() {
        // 선택된 셀 살짝 흔들기 (같이 재사용)
        let cells = selectedIndexPaths.compactMap { collectionView.cellForItem(at: $0) as? HangeulTileCell }
        cells.forEach { $0.playWrongAnimation() }

        let message = "Path is blocked."
        statusLabel.text = message

        let reloadTargets = selectedIndexPaths
        selectedIndexPaths.removeAll()
        collectionView.reloadItems(at: reloadTargets)

        // 셔플/초기화 로직 제거됨
    }

    private func handleCorrectPair(firstIndex: IndexPath,
                                   secondIndex: IndexPath,
                                   pair: Level1SyllableConfig) {
        
        // 타일 제거 상태로 변경
        tiles[firstIndex.item].isRemoved = true
        tiles[secondIndex.item].isRemoved = true
        
        let reloadTargets = selectedIndexPaths
        selectedIndexPaths.removeAll()
        collectionView.reloadItems(at: reloadTargets)
        
        // 만든 음절 상세정보 저장
        let detail = LearnedSyllableDetail(
            consonant: pair.consonant,
            consonantRoman: pair.consonantRoman,
            vowel: pair.vowel,
            vowelRoman: pair.vowelRoman,
            syllable: pair.syllable,
            syllableRoman: pair.syllableRoman
        )
        learnedSyllables[pair.syllable] = detail

        // 자음+모음 조합이 성공했을 때 디버그 로그 출력
        print("✅ 성공: \(pair.consonant)+\(pair.vowel) => \(pair.syllable) (\(pair.syllableRoman))")
        
        let message = "\(pair.syllable) (\(pair.syllableRoman))"
        statusLabel.text = message
        
        checkLevelClear()
        
        // TODO: 나중에 여기서 발음 음성 재생도 추가 가능 (AVFoundation)
    }
    
    /// 첫 번째 선택과 두 번째 선택 순서가 잘못된 경우 (자음 → 모음이 아닌 경우)
    private func playWrongOrderFeedback() {
        // 선택된 셀 흔들기
        let cells = selectedIndexPaths.compactMap {
            collectionView.cellForItem(at: $0) as? HangeulTileCell
        }
        cells.forEach { $0.playWrongAnimation() }
        
        let message = "Select consonant first, then vowel."
        statusLabel.text = message
        
        // 선택 초기화
        let reloadTargets = selectedIndexPaths
        selectedIndexPaths.removeAll()
        collectionView.reloadItems(at: reloadTargets)

        // 셔플/초기화 로직 제거됨
    }

    private func playWrongFeedback() {
        // 선택된 셀 흔들기
        let cells = selectedIndexPaths.compactMap { collectionView.cellForItem(at: $0) as? HangeulTileCell }
        cells.forEach { $0.playWrongAnimation() }
        
        let message = "Only Consonant + Vowel pair is allowed."
        statusLabel.text = message
        
        // 선택 해제
        let reloadTargets = selectedIndexPaths
        selectedIndexPaths.removeAll()
        collectionView.reloadItems(at: reloadTargets)

        // 셔플/초기화 로직 제거됨
    }
    
    private func position(for item: Int) -> (row: Int, col: Int) {
        let row = item / numberOfColumns
        let col = item % numberOfColumns
        return (row, col)
    }
    
    // 셔플/초기화 관련 함수 및 호출부 모두 제거됨

    // MARK: - Path finding
    private func findPath(_ firstIndex: IndexPath,
                          _ secondIndex: IndexPath) -> [(row: Int, col: Int)]? {
        let rows = numberOfRows
        let cols = numberOfColumns
        if rows == 0 { return nil }
        
        // 0 ~ rows-1, 0 ~ cols-1 좌표
        let (r1, c1) = position(for: firstIndex.item)
        let (r2, c2) = position(for: secondIndex.item)
        
        let H = rows
        let W = cols
        
        // true = 통과 불가
        var blocked = Array(repeating: Array(repeating: false, count: W), count: H)
        
        // 현재 보드 상태 반영
        for row in 0..<rows {
            for col in 0..<cols {
                let item = row * cols + col
                guard item < tiles.count else { continue }
                
                // 제거된 타일은 빈칸
                if tiles[item].isRemoved { continue }
                // 시작 / 끝 타일은 통과 가능해야 하므로 막지 않는다
                if row == r1 && col == c1 { continue }
                if row == r2 && col == c2 { continue }
                
                blocked[row][col] = true
            }
        }
        
        struct State {
            var r: Int
            var c: Int
            var dir: Int   // 0: up, 1: right, 2: down, 3: left
            var turns: Int
            var parentIndex: Int?
        }
        
        let dirs = [(-1, 0), (0, 1), (1, 0), (0, -1)]
        
        // visited[r][c][dir] = 최소 꺾은 횟수
        var visited = Array(
            repeating: Array(
                repeating: Array(repeating: Int.max, count: 4),
                count: W
            ),
            count: H
        )
        
        var queue: [State] = []
        var head = 0
        
        // 시작점에서 한 칸씩 나가며 초기 상태 추가
        for d in 0..<4 {
            let nr = r1 + dirs[d].0
            let nc = c1 + dirs[d].1
            guard nr >= 0, nr < H, nc >= 0, nc < W else { continue }
            
            if blocked[nr][nc] && !(nr == r2 && nc == c2) { continue }
            
            visited[nr][nc][d] = 0
            queue.append(State(r: nr, c: nc, dir: d, turns: 0, parentIndex: nil))
        }
        
        var targetStateIndex: Int?
        
        // BFS
        while head < queue.count {
            let cur = queue[head]
            head += 1
            
            if cur.r == r2 && cur.c == c2 {
                targetStateIndex = head - 1
                break
            }
            
            for nd in 0..<4 {
                let nr = cur.r + dirs[nd].0
                let nc = cur.c + dirs[nd].1
                guard nr >= 0, nr < H, nc >= 0, nc < W else { continue }
                
                if blocked[nr][nc] && !(nr == r2 && nc == c2) { continue }
                
                var newTurns = cur.turns
                if nd != cur.dir {
                    newTurns += 1
                }
                if newTurns > 2 { continue }     // 최대 2번까지만 꺾기 허용
                
                if newTurns >= visited[nr][nc][nd] { continue }
                visited[nr][nc][nd] = newTurns
                queue.append(State(r: nr, c: nc, dir: nd, turns: newTurns, parentIndex: head - 1))
            }
        }
        
        // 도착 실패
        guard let endIndex = targetStateIndex else {
            return nil
        }
        
        // 경로 복원
        var path: [(Int, Int)] = []
        var curIndex: Int? = endIndex
        
        while let idx = curIndex {
            let s = queue[idx]
            path.append((s.r, s.c))
            curIndex = s.parentIndex
        }
        
        // 시작점도 포함
        path.append((r1, c1))
        path.reverse()
        
        // 직선 구간은 중간 점들을 줄여서 꺾이는 지점만 남기기 (선 그릴 때 깔끔하게)
        var compressed: [(Int, Int)] = []
        
        func dirBetween(_ a: (Int, Int), _ b: (Int, Int)) -> (Int, Int) {
            return (b.0 - a.0, b.1 - a.1)
        }
        
        for i in 0..<path.count {
            if i == 0 || i == path.count - 1 {
                compressed.append(path[i])
            } else {
                let prev = path[i - 1]
                let cur = path[i]
                let next = path[i + 1]
                
                let d1 = dirBetween(prev, cur)
                let d2 = dirBetween(cur, next)
                
                if d1.0 != d2.0 || d1.1 != d2.1 {
                    compressed.append(cur)
                }
            }
        }
        
        // 이제 보드 안쪽 좌표(row, col) 그대로 리턴
        let result: [(row: Int, col: Int)] = compressed.map { (r, c) in
            (row: r, col: c)
        }
        
        return result.isEmpty ? nil : result
    }
    
    private func showConnectionPath(
        gridPath: [(row: Int, col: Int)],
        completion: @escaping () -> Void
    ) {
        guard gridPath.count >= 2 else {
            completion()
            return
        }
        
        let path = UIBezierPath()
        var isFirstPoint = true
        
        for point in gridPath {
            let row = point.row
            let col = point.col
            let item = row * numberOfColumns + col
            guard item < tiles.count else { continue }
            
            let indexPath = IndexPath(item: item, section: 0)
            
            // 레이아웃 정보를 기반으로 셀 중심 좌표 가져오기
            guard let attrs = collectionView.layoutAttributesForItem(at: indexPath) else { continue }
            
            // collectionView 기준 center를 overlay 기준으로 변환
            let centerInCollection = attrs.center
            let centerInOverlay = pathOverlayView.convert(centerInCollection, from: collectionView)
            
            if isFirstPoint {
                path.move(to: centerInOverlay)
                isFirstPoint = false
            } else {
                path.addLine(to: centerInOverlay)
            }
        }
        
        pathLayer.path = path.cgPath
        
        // 🔹 간단한 페이드 인/아웃 애니메이션 후 completion 호출
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            // 라인 사라지게
            CATransaction.begin()
            CATransaction.setCompletionBlock {
                self.pathLayer.path = nil
                completion()
            }
            let fadeOut = CABasicAnimation(keyPath: "opacity")
            fadeOut.fromValue = 1.0
            fadeOut.toValue = 0.0
            fadeOut.duration = 0.2
            self.pathLayer.add(fadeOut, forKey: "fadeOut")
            self.pathLayer.opacity = 0.0
            CATransaction.commit()
        }
        
        let fadeIn = CABasicAnimation(keyPath: "opacity")
        fadeIn.fromValue = 0.0
        fadeIn.toValue = 1.0
        fadeIn.duration = 0.15
        pathLayer.add(fadeIn, forKey: "fadeIn")
        pathLayer.opacity = 1.0
        
        CATransaction.commit()
    }
    
    private func checkLevelClear() {
        // 1) 타일이 하나도 안 남았으면 → 클리어
        let hasRemaining = tiles.contains { $0.isRemoved == false }
        if !hasRemaining {
            print("저장된 음절: \(self.learnedSyllables)")
            showLevelClearPopup()
            return
        }
        
        // 2) 더 이상 만들 수 있는 조합(연결 가능한 자+모)이 없으면 → 클리어
        if !canMakeAnyMorePairs() {
            print("저장된 음절: \(self.learnedSyllables)")
            print("🔚 더 이상 가능한 조합이 없습니다. 레벨 클리어 처리.")
            showLevelClearPopup()
        }
        
        // 3) 셔플/초기화 로직 없음
    }
    
    // 현재 보드에서 level1ValidPairs 중 하나라도 "연결 가능한" 자+모 쌍이 남아있는지 검사
    private func canMakeAnyMorePairs() -> Bool {
        // 남아있는 타일만 대상으로 인덱스를 수집
        var consonantIndices: [String: [IndexPath]] = [:]
        var vowelIndices: [String: [IndexPath]] = [:]
        
        for (i, tile) in tiles.enumerated() where !tile.isRemoved {
            let indexPath = IndexPath(item: i, section: 0)
            switch tile.type {
            case .consonant:
                consonantIndices[tile.symbol, default: []].append(indexPath)
            case .vowel:
                vowelIndices[tile.symbol, default: []].append(indexPath)
            }
        }
        
        // 가능한 모든 허용 조합을 순회하며, 실제 보드 위에서 연결 가능한 쌍이 있는지 확인
        for pair in level1ValidPairs {
            guard let cList = consonantIndices[pair.consonant], !cList.isEmpty,
                  let vList = vowelIndices[pair.vowel], !vList.isEmpty else {
                continue
            }
            
            // 후보 인덱스 조합들 중 하나라도 연결 가능하면 true
            for cIndex in cList {
                for vIndex in vList {
                    if findPath(cIndex, vIndex) != nil {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    private func showLevelClearPopup() {
        let alert = UIAlertController(
            title: "Level Clear 🎉",
            message: "You removed all tiles.\n만든 음절들을 복습해볼까요?",
            preferredStyle: .alert
        )
        
        let reviewAction = UIAlertAction(title: "Review syllables", style: .default) { [weak self] _ in
            // 상세 리뷰 화면으로 이동
            self?.showSyllableReviewScreen()
        }
        
        let cancelAction = UIAlertAction(title: "Close", style: .cancel) { [weak self] _ in
            // 취소를 눌러도 메인으로 이동
            if let nav = self?.navigationController {
                nav.popToRootViewController(animated: true)
            } else {
                self?.dismiss(animated: true, completion: nil)
            }
        }
        
        alert.addAction(reviewAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func showLearnedSyllablesPopup() {
        if learnedSyllables.isEmpty {
            let alert = UIAlertController(
                title: "No syllables",
                message: "아직 저장된 음절이 없어요.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // syllable 기준으로 정렬
        let sorted = learnedSyllables.sorted { $0.key < $1.key }
        
        // "가 (ga)\n나 (na)\n..." 형태로 문자열 구성
        let message = sorted
            .map { "\($0.key)  (\($0.value))" }
            .joined(separator: "\n")
        
        let reviewAlert = UIAlertController(
            title: "Syllables you made",
            message: message,
            preferredStyle: .alert
        )
        
        reviewAlert.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(reviewAlert, animated: true)
    }
    
    private func showSyllableReviewScreen() {
        guard !learnedSyllables.isEmpty else {
            let alert = UIAlertController(
                title: "No syllables",
                message: "아직 저장된 음절이 없어요.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // 🔹 딕셔너리를 배열로 변환 + 음절 기준 정렬
        let items: [LearnedSyllableDetail] = learnedSyllables
            .map { $0.value }
            .sorted { $0.syllable < $1.syllable }
        
        let reviewVC = SyllableReviewViewController(items: items)
        
        if let nav = navigationController {
            nav.pushViewController(reviewVC, animated: true)
        } else {
            let nav = UINavigationController(rootViewController: reviewVC)
            nav.modalPresentationStyle = .formSheet
            present(nav, animated: true)
        }
    }
}

