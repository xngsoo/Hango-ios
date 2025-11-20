//
//  Level2ViewController.swift
//  Hango-ios
//
//  Created by SEUNGSOO HAN on 11/19/25.
//

import UIKit

/// Level 2 메인 게임 화면 (Level1과 동일 UI/로직, 데이터셋만 Level2)
class Level2ViewController: UIViewController {

    // 상단 상태 라벨
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppTheme.Fonts.displayLarge()
        label.textColor = AppTheme.Colors.ink
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        label.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return label
    }()
    
    // 발음 표기 라벨 (statusLabel 아래)
    private let pronunciationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppTheme.Fonts.body()
        label.textColor = AppTheme.Colors.ink
        label.textAlignment = .center
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()

    private var collectionView: UICollectionView!
    private let numberOfColumns: Int = 6
    private let numberOfRowsMax: Int = 7
    
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
    private var learnedSyllables: [String: LearnedSyllableDetail] = [:]
    
    // 최대 타일 개수
    private var maxTilesCount: Int {
        return numberOfColumns * numberOfRowsMax
    }
    
    private var isInteractionLocked: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AppTheme.applyNavigationBarAppearance()
        view.backgroundColor = AppTheme.Colors.hanjiBackground
        title = "Level 2"
        
        setupStatusLabel()
        setupPronunciationLabel()
        setupCollectionView()
        setupPathOverlay()
        setupLevel2Tiles()
    }

    private func setupStatusLabel() {
        view.addSubview(statusLabel)
        
        NSLayoutConstraint.activate([
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
    
    private func setupPronunciationLabel() {
        view.addSubview(pronunciationLabel)
        NSLayoutConstraint.activate([
            pronunciationLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 6),
            pronunciationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            pronunciationLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        pronunciationLabel.text = "" // 초기 비움
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10

        let visualPadding: CGFloat = 16
        let topPaddingInside: CGFloat = 12
        
        let totalSpacing = CGFloat(numberOfColumns - 1) * layout.minimumInteritemSpacing
        let availableWidth = view.bounds.width - (visualPadding * 2) - totalSpacing
        let itemWidth = max(1, floor(availableWidth / CGFloat(numberOfColumns)))
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.layer.cornerRadius = AppTheme.Metrics.cornerRadius
        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.contentInset = UIEdgeInsets(top: topPaddingInside,
                                                   left: visualPadding,
                                                   bottom: visualPadding,
                                                   right: visualPadding)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(HangeulTileCell.self, forCellWithReuseIdentifier: HangeulTileCell.reuseIdentifier)

        view.addSubview(collectionView)

        let rows = numberOfRowsMax
        let gridHeightCore = itemWidth * CGFloat(rows) + layout.minimumLineSpacing * CGFloat(rows - 1)
        let gridHeight = gridHeightCore + topPaddingInside + visualPadding
        let height = collectionView.heightAnchor.constraint(equalToConstant: gridHeight)
        height.priority = .defaultHigh

        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            height
        ])

        let headerGuide = UILayoutGuide()
        view.addLayoutGuide(headerGuide)
        
        NSLayoutConstraint.activate([
            headerGuide.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerGuide.bottomAnchor.constraint(equalTo: collectionView.topAnchor),
            
            statusLabel.centerYAnchor.constraint(equalTo: headerGuide.centerYAnchor)
        ])
        
        collectionView.clipsToBounds = false
    }
    
    private func setupPathOverlay() {
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
            
            pathLayer.strokeColor = AppTheme.Colors.danGold.withAlphaComponent(0.95).cgColor
            pathLayer.lineWidth = 5
            pathLayer.lineJoin = .round
            pathLayer.lineCap = .round
            pathLayer.fillColor = UIColor.clear.cgColor
            pathLayer.opacity = 0.0
            pathLayer.shadowColor = AppTheme.Colors.danGold.cgColor
            pathLayer.shadowOpacity = 0.35
            pathLayer.shadowRadius = 6
            pathLayer.shadowOffset = CGSize(width: 0, height: 0)
            
            pathOverlayView.layer.addSublayer(pathLayer)
        } else {
            pathLayer.path = nil
            pathLayer.opacity = 0.0
        }
    }

    private func setupLevel2Tiles() {
        tiles = generateRandomBoard()
        collectionView.reloadData()
        checkLevelClear()
    }
    
    /// 6 x 10 보드를 랜덤으로 채우는 함수
    /// - level2ValidPairs를 기반으로 자/모 타일을 섞어서 maxTilesCount 개까지 채운다.
    private func generateRandomBoard() -> [HangeulTile] {
        var pool: [HangeulTile] = []
        
        for pair in level2ValidPairs {
            pool.append(HangeulTile(symbol: pair.consonant, type: .consonant))
            pool.append(HangeulTile(symbol: pair.vowel, type: .vowel))
        }
        
        var index = 0
        while pool.count < maxTilesCount {
            let pair = level2ValidPairs[index % level2ValidPairs.count]
            pool.append(HangeulTile(symbol: pair.consonant, type: .consonant))
            pool.append(HangeulTile(symbol: pair.vowel, type: .vowel))
            index += 1
        }
        
        pool.shuffle()
        if pool.count > maxTilesCount {
            pool = Array(pool.prefix(maxTilesCount))
        }
        
        return pool
    }

    // MARK: - Status text helper (UI-only)
    private func setStatusText(_ text: String, compact: Bool) {
        if compact {
            statusLabel.font = UIFont.systemFont(ofSize: 32, weight: .semibold)
            statusLabel.numberOfLines = 0
        } else {
            statusLabel.font = UIFont.systemFont(ofSize: 56, weight: .semibold)
            statusLabel.numberOfLines = 0
        }
        statusLabel.text = text
    }
    
    // 발음 표기 문자열 업데이트
    private func setPronunciationText(_ text: String?) {
        pronunciationLabel.text = text ?? ""
    }

    private func shakeStatusLabel() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.35
        animation.values = [-6, 6, -5, 5, -3, 3, -1, 1, 0]
        statusLabel.layer.add(animation, forKey: "shake")
    }
    
    // 선택한 자/모의 로마자 표기를 가져오기 위한 헬퍼 (Level2 데이터셋 기반)
    private func romanForConsonant(_ symbol: String) -> String? {
        // level2ValidPairs 중 해당 자음을 포함하는 아무 항목에서 roman을 가져온다.
        return level2ValidPairs.first(where: { $0.consonant == symbol })?.consonantRoman
    }
    
    private func romanForVowel(_ symbol: String) -> String? {
        return level2ValidPairs.first(where: { $0.vowel == symbol })?.vowelRoman
    }
}

extension Level2ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
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
        
        let isSelected = selectedIndexPaths.contains(indexPath)
        cell.setSelectedAppearance(isSelected, type: tile.type)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        handleSelect(at: indexPath)
    }

    private func handleSelect(at indexPath: IndexPath) {
        guard !isInteractionLocked else { return }
        guard tiles[indexPath.item].isRemoved == false else { return }
        
        if let idx = selectedIndexPaths.firstIndex(of: indexPath) {
            selectedIndexPaths.remove(at: idx)
            collectionView.reloadItems(at: [indexPath])
            updateSelectionStatusForCurrentSelection()
            return
        }
        
        if selectedIndexPaths.count >= 2 {
            let old = selectedIndexPaths
            selectedIndexPaths.removeAll()
            selectedIndexPaths.append(indexPath)
            collectionView.reloadItems(at: old + [indexPath])
            updateSelectionStatusForCurrentSelection()
            return
        }
        
        selectedIndexPaths.append(indexPath)
        collectionView.reloadItems(at: [indexPath])
        updateSelectionStatusForCurrentSelection()
        
        if selectedIndexPaths.count == 2 {
            checkPair()
        }
    }

    // 선택 상태에 따라 statusLabel과 pronunciationLabel을 갱신
    private func updateSelectionStatusForCurrentSelection() {
        switch selectedIndexPaths.count {
        case 0:
            setStatusText("", compact: false)
            setPronunciationText(nil)
        case 1:
            let idx = selectedIndexPaths[0].item
            let tile = tiles[idx]
            setStatusText(tile.symbol, compact: false)
            
            switch tile.type {
            case .consonant:
                let roman = romanForConsonant(tile.symbol) ?? "?"
                setPronunciationText("\(tile.symbol) (\(roman))")
            case .vowel:
                let roman = romanForVowel(tile.symbol) ?? "?"
                setPronunciationText("\(tile.symbol) (\(roman))")
            }
        case 2:
            let firstTile = tiles[selectedIndexPaths[0].item]
            let secondTile = tiles[selectedIndexPaths[1].item]
            setStatusText("\(firstTile.symbol)  +  \(secondTile.symbol)", compact: false)
            
            let cTile: HangeulTile?
            let vTile: HangeulTile?
            if firstTile.type == .consonant && secondTile.type == .vowel {
                cTile = firstTile; vTile = secondTile
            } else if firstTile.type == .vowel && secondTile.type == .consonant {
                cTile = secondTile; vTile = firstTile
            } else {
                cTile = nil; vTile = nil
            }
            
            if let c = cTile, let v = vTile {
                let cRoman = romanForConsonant(c.symbol) ?? "?"
                let vRoman = romanForVowel(v.symbol) ?? "?"
                setPronunciationText("\(c.symbol) (\(cRoman))  +  \(v.symbol) (\(vRoman))")
            } else {
                let r1: String
                if firstTile.type == .consonant {
                    r1 = "\(firstTile.symbol) (\(romanForConsonant(firstTile.symbol) ?? "?"))"
                } else {
                    r1 = "\(firstTile.symbol) (\(romanForVowel(firstTile.symbol) ?? "?"))"
                }
                let r2: String
                if secondTile.type == .consonant {
                    r2 = "\(secondTile.symbol) (\(romanForConsonant(secondTile.symbol) ?? "?"))"
                } else {
                    r2 = "\(secondTile.symbol) (\(romanForVowel(secondTile.symbol) ?? "?"))"
                }
                setPronunciationText("\(r1)  +  \(r2)")
            }
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
        
        let isCV = (firstTile.type == .consonant && secondTile.type == .vowel)
        let isSameType = (firstTile.type == secondTile.type)
        
        if isSameType {
            playWrongFeedback()
            return
        }
        
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
        
        // Level2 조합 유효성 검사
        guard let pair = level2ValidPairs.first(where: {
            $0.consonant == consonantTile.symbol && $0.vowel == vowelTile.symbol
        }) else {
            playWrongFeedback()
            return
        }
        
        guard let gridPath = findPath(consonantIndex, vowelIndex) else {
            playBlockedFeedback()
            return
        }
        
        guard isCV else {
            playWrongOrderFeedback()
            return
        }
        
        isInteractionLocked = true
        showConnectionPath(gridPath: gridPath) { [weak self] in
            guard let self = self else { return }
            self.handleCorrectPair(firstIndex: firstIndex,
                                   secondIndex: secondIndex,
                                   pair: pair)
            self.isInteractionLocked = false
        }
    }
    
    private func playBlockedFeedback() {
        let cells = selectedIndexPaths.compactMap { collectionView.cellForItem(at: $0) as? HangeulTileCell }
        cells.forEach { $0.playWrongAnimation() }

        setStatusText("Path is blocked.", compact: true)
        setPronunciationText(nil)
        shakeStatusLabel()

        let reloadTargets = selectedIndexPaths
        selectedIndexPaths.removeAll()
        collectionView.reloadItems(at: reloadTargets)
    }

    private func handleCorrectPair(firstIndex: IndexPath,
                                   secondIndex: IndexPath,
                                   pair: Level2SyllableConfig) {
        
        tiles[firstIndex.item].isRemoved = true
        tiles[secondIndex.item].isRemoved = true
        
        let reloadTargets = [firstIndex, secondIndex]
        selectedIndexPaths.removeAll()
        collectionView.reloadItems(at: reloadTargets)
        
        let detail = LearnedSyllableDetail(
            consonant: pair.consonant,
            consonantRoman: pair.consonantRoman,
            vowel: pair.vowel,
            vowelRoman: pair.vowelRoman,
            syllable: pair.syllable,
            syllableRoman: pair.syllableRoman
        )
        learnedSyllables[pair.syllable] = detail
        
        setStatusText("\(pair.syllable) (\(pair.syllableRoman))", compact: false)
        setPronunciationText("\(pair.consonant) (\(pair.consonantRoman))   \(pair.vowel) (\(pair.vowelRoman))")
        
        checkLevelClear()
    }
    
    private func playWrongOrderFeedback() {
        let cells = selectedIndexPaths.compactMap {
            collectionView.cellForItem(at: $0) as? HangeulTileCell
        }
        cells.forEach { $0.playWrongAnimation() }
        
        setStatusText("Select consonant first, then vowel.", compact: true)
        setPronunciationText(nil)
        
        shakeStatusLabel()
        
        let reloadTargets = selectedIndexPaths
        selectedIndexPaths.removeAll()
        collectionView.reloadItems(at: reloadTargets)
    }

    private func playWrongFeedback() {
        let cells = selectedIndexPaths.compactMap { collectionView.cellForItem(at: $0) as? HangeulTileCell }
        cells.forEach { $0.playWrongAnimation() }
        
        setStatusText("Only Consonant + Vowel\npair is allowed.", compact: true)
        setPronunciationText(nil)
        shakeStatusLabel()
        
        let reloadTargets = selectedIndexPaths
        selectedIndexPaths.removeAll()
        collectionView.reloadItems(at: reloadTargets)
    }
    
    private func position(for item: Int) -> (row: Int, col: Int) {
        let row = item / numberOfColumns
        let col = item % numberOfColumns
        return (row, col)
    }

    // MARK: - Path finding (Level1과 동일)
    private func findPath(_ firstIndex: IndexPath,
                          _ secondIndex: IndexPath) -> [(row: Int, col: Int)]? {
        let rows = numberOfRows
        let cols = numberOfColumns
        if rows == 0 { return nil }
        
        let (r1, c1) = position(for: firstIndex.item)
        let (r2, c2) = position(for: secondIndex.item)
        
        let H = rows
        let W = cols
        
        var blocked = Array(repeating: Array(repeating: false, count: W), count: H)
        
        for row in 0..<rows {
            for col in 0..<cols {
                let item = row * cols + col
                guard item < tiles.count else { continue }
                if tiles[item].isRemoved { continue }
                if row == r1 && col == c1 { continue }
                if row == r2 && col == c2 { continue }
                blocked[row][col] = true
            }
        }
        
        struct State {
            var r: Int
            var c: Int
            var dir: Int
            var turns: Int
            var parentIndex: Int?
        }
        
        let dirs = [(-1, 0), (0, 1), (1, 0), (0, -1)]
        
        var visited = Array(
            repeating: Array(
                repeating: Array(repeating: Int.max, count: 4),
                count: W
            ),
            count: H
        )
        
        var queue: [State] = []
        var head = 0
        
        for d in 0..<4 {
            let nr = r1 + dirs[d].0
            let nc = c1 + dirs[d].1
            guard nr >= 0, nr < H, nc >= 0, nc < W else { continue }
            if blocked[nr][nc] && !(nr == r2 && nc == c2) { continue }
            visited[nr][nc][d] = 0
            queue.append(State(r: nr, c: nc, dir: d, turns: 0, parentIndex: nil))
        }
        
        var targetStateIndex: Int?
        
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
                if newTurns > 2 { continue }
                
                if newTurns >= visited[nr][nc][nd] { continue }
                visited[nr][nc][nd] = newTurns
                queue.append(State(r: nr, c: nc, dir: nd, turns: newTurns, parentIndex: head - 1))
            }
        }
        
        guard let endIndex = targetStateIndex else {
            return nil
        }
        
        var path: [(Int, Int)] = []
        var curIndex: Int? = endIndex
        
        while let idx = curIndex {
            let s = queue[idx]
            path.append((s.r, s.c))
            curIndex = s.parentIndex
        }
        
        path.append((r1, c1))
        path.reverse()
        
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
            guard let attrs = collectionView.layoutAttributesForItem(at: indexPath) else { continue }
            
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
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
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
        let hasRemaining = tiles.contains { $0.isRemoved == false }
        if !hasRemaining {
            showLevelClearPopup()
            return
        }
        
        if !canMakeAnyMorePairs() {
            showLevelClearPopup()
        }
    }
    
    private func canMakeAnyMorePairs() -> Bool {
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
        
        for pair in level2ValidPairs {
            guard let cList = consonantIndices[pair.consonant], !cList.isEmpty,
                  let vList = vowelIndices[pair.vowel], !vList.isEmpty else {
                continue
            }
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
            title: "Level 2 Clear 🎉",
            message: "You removed all tiles.\nLet's review the syllables we made.",
            preferredStyle: .alert
        )
        
        let reviewAction = UIAlertAction(title: "Review syllables", style: .default) { [weak self] _ in
            self?.showSyllableReviewScreen()
        }
        
        let cancelAction = UIAlertAction(title: "Close", style: .cancel) { [weak self] _ in
            if let nav = self?.navigationController {
                nav.popToRootViewController(animated: true)
            } else {
                self?.dismiss(animated: true, completion: nil)
            }
        }
        
        alert.addAction(reviewAction)
        alert.addAction(cancelAction)
        alert.view.tintColor = AppTheme.Colors.danBlue
        present(alert, animated: true)
    }
    
    private func showSyllableReviewScreen() {
        guard !learnedSyllables.isEmpty else {
            let alert = UIAlertController(
                title: "No syllables",
                message: "There are no syllables saved yet.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            alert.view.tintColor = AppTheme.Colors.danBlue
            present(alert, animated: true)
            return
        }
        
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

extension Level2ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Level1과 동일한 셀 크기 계산을 위해 flow layout의 itemSize를 이미 설정했으므로 여기서는 반환 생략 가능.
        // 필요 시 레이아웃 변경 대응:
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            return layout.itemSize
        }
        let size = collectionView.bounds.size
        let totalSpacing = CGFloat(numberOfColumns - 1) * 10
        let availableWidth = size.width - 32 - totalSpacing
        let itemWidth = max(1, floor(availableWidth / CGFloat(numberOfColumns)))
        return CGSize(width: itemWidth, height: itemWidth)
    }
}
