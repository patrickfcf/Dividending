//
//  SegmentCollectionViewCell.swift
//  Dividending
//
//  Created by Patrick Fonseca on 7/20/23.
//

import UIKit

/// A custom collection view cell to show the dashboard flow type
class SegmentCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var itemLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = contentView.bounds.height/2.0
    }

    func configure(title: String, selected: Bool) {
        itemLabel.text = title
        configureStyle(selected: selected)
    }

    func configureStyle(selected: Bool) {
        itemLabel.textColor = selected ? .black : .white
        contentView.backgroundColor = selected ? .white : .clear
    }
}
