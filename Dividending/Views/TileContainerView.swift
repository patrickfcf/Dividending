//
//  TileContainerView.swift
//  Dividending
//
//  Created by Patrick Fonseca on 7/20/23.
//

import UIKit

@IBDesignable
class TileContainerView: UIView {

    @IBInspectable var cornerRadius: Double = 15.0
    @IBInspectable var borderColor: UIColor = .gray
    @IBInspectable var borderWidth: Double = 1.0

    override func draw(_ rect: CGRect) {
        configureRoundedCornersBorder()
    }

    private func configureRoundedCornersBorder() {
        layer.borderWidth = borderWidth
        layer.cornerRadius = cornerRadius
        layer.borderColor = borderColor.withAlphaComponent(0.5).cgColor
    }
}
