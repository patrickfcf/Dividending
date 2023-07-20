//
//  GoalProgressView.swift
//  Dividending
//
//  Created by Patrick Fonseca on 7/20/23.
//

import UIKit

/// Progress view for the goal
class GoalProgressView: UIView {
    
    private var progressView: UIView = UIView()

    func updateProgress(_ value: Double) {
        progressView.removeFromSuperview()
        progressView.frame = .init(x: 0, y: 0, width: bounds.width * value, height: bounds.height)
        addSubview(progressView)
        progressView.backgroundColor = .systemMint
        backgroundColor = .white
        layer.cornerRadius = 8.0
        layer.borderColor = UIColor.systemMint.cgColor
        layer.borderWidth = 1.5
    }
}
