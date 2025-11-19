//
//  ToastView.swift
//  Hango-ios
//
//  Created by SEUNGSOO HAN on 11/19/25.
//

import UIKit

enum ToastStyle {
    case success
    case fail
}

class ToastView: UIView {

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(message: String, style: ToastStyle) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        layer.cornerRadius = 16
        layer.masksToBounds = true
        
        switch style {
        case .success:
            backgroundColor = UIColor.systemGreen.withAlphaComponent(0.9)
        case .fail:
            backgroundColor = UIColor.systemRed.withAlphaComponent(0.9)
        }
        
        messageLabel.text = message
        
        addSubview(messageLabel)
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 토스트를 특정 뷰 위에 표시하는 헬퍼
    static func show(in parentView: UIView, message: String, style: ToastStyle = .success, duration: TimeInterval = 2.0) {
        // 이미 떠 있는 토스트 제거 (중복방지)
        parentView.subviews
            .compactMap { $0 as? ToastView }
            .forEach { $0.removeFromSuperview() }
        
        let toast = ToastView(message: message, style: style)
        parentView.addSubview(toast)
        
        let safeArea = parentView.safeAreaLayoutGuide
        
        // 처음에는 화면 하단에 숨긴 상태
        let bottomConstraint = toast.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: 100)
        
        NSLayoutConstraint.activate([
            toast.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 24),
            toast.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -24),
            bottomConstraint
        ])
        
        parentView.layoutIfNeeded()
        
        // 등장 애니메이션
        bottomConstraint.constant = -24
        UIView.animate(withDuration: 0.25,
                       delay: 0,
                       options: [.curveEaseOut],
                       animations: {
            toast.alpha = 1.0
            parentView.layoutIfNeeded()
        }, completion: { _ in
            UIView.animate(withDuration: 0.25,
                           delay: duration,
                           options: [.curveEaseIn],
                           animations: {
                toast.alpha = 0.0
                bottomConstraint.constant = 100
                parentView.layoutIfNeeded()
            }, completion: { _ in
                toast.removeFromSuperview()
            })
        })
    }
}
