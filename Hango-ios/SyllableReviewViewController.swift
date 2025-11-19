//
//  SyllableReviewViewController.swift
//  Hango-ios
//
//  Created by SEUNGSOO HAN on 11/19/25.
//

import UIKit

/// 저장된 음절들을 하나씩 넘기면서 복습하는 화면
final class SyllableReviewViewController: UIViewController {
    
    private let items: [LearnedSyllableDetail]
    
    private var collectionView: UICollectionView!
    private let pageControl = UIPageControl()
    
    // 마지막 축하 페이지를 포함한 총 페이지 수 = items.count + 1
    private var totalPages: Int { max(1, items.count + 1) }
    
    // MARK: - Init
    
    init(items: [LearnedSyllableDetail]) {
        self.items = items
        super.init(nibName: nil, bundle: nil)
        self.title = "Syllable Review"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        setupCollectionView()
        setupPageControl()
        setupNavigationItems()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 레이아웃이 갱신될 때 페이지 컨트롤과 페이지 인덱스를 안전하게 동기화
        syncCurrentPageWithScroll()
    }
    
    // MARK: - UI Setup
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(
            SyllablePageCell.self,
            forCellWithReuseIdentifier: SyllablePageCell.reuseIdentifier
        )
        collectionView.register(
            SyllableCongratsCell.self,
            forCellWithReuseIdentifier: SyllableCongratsCell.reuseIdentifier
        )
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40)
        ])
    }
    
    private func setupPageControl() {
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.numberOfPages = totalPages
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .systemGray4
        pageControl.currentPageIndicatorTintColor = .systemBlue
        
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -4)
        ])
    }
    
    private func setupNavigationItems() {
        // 리뷰 화면 어디서든 닫기 버튼을 제공하여 메인으로 돌아갈 수 있게 함
        if presentingViewController != nil && navigationController?.viewControllers.first == self {
            // 모달 + 내비 루트
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .close,
                target: self,
                action: #selector(didTapClose)
            )
        } else if navigationController != nil {
            // 내비게이션 스택 위에 있음
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .close,
                target: self,
                action: #selector(didTapClose)
            )
        }
    }
    
    @objc private func didTapClose() {
        // 메인 화면으로 돌아가기: 내비게이션이면 루트로 pop, 모달이면 dismiss
        if let nav = navigationController {
            nav.popToRootViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Helpers
    
    private func syncCurrentPageWithScroll() {
        let width = collectionView.bounds.width
        guard width > 0 else { return }
        
        let page = Int(round(collectionView.contentOffset.x / width))
        let clamped = max(0, min(page, totalPages - 1))
        if pageControl.currentPage != clamped {
            pageControl.currentPage = clamped
        }
    }
}

// MARK: - UICollectionViewDataSource

extension SyllableReviewViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return totalPages
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 마지막 페이지는 축하 셀
        if indexPath.item == items.count {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: SyllableCongratsCell.reuseIdentifier,
                for: indexPath
            ) as? SyllableCongratsCell else {
                return UICollectionViewCell()
            }
            cell.configure(
                message: "Great job! 🎉\nYou reviewed all syllables.",
                buttonTitle: "Back to Main"
            ) { [weak self] in
                self?.didTapClose()
            }
            return cell
        }
        
        // 그 외는 일반 리뷰 페이지
        guard indexPath.item < items.count,
              let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: SyllablePageCell.reuseIdentifier,
                for: indexPath
              ) as? SyllablePageCell else {
            return UICollectionViewCell()
        }
        
        let item = items[indexPath.item]
        cell.configure(with: item)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension SyllableReviewViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.bounds.size
        let safeWidth = max(size.width, 1)
        let safeHeight = max(size.height, 1)
        return CGSize(width: safeWidth, height: safeHeight)
    }
}

// MARK: - UIScrollViewDelegate

extension SyllableReviewViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.bounds.width
        guard width > 0 else { return }
        
        let page = Int(round(scrollView.contentOffset.x / width))
        pageControl.currentPage = max(0, min(page, totalPages - 1))
    }
}
