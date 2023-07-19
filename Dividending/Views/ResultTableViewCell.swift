//
//  ResultTableViewCell.swift
//  DivTracker
//
//  Created by Apps4World on 3/6/23.
//

import UIKit

/// A search result list item
class ResultTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    
    /// Configure the cell details
    func configure(model: SearchResultModel) {
        nameLabel.text = model.name.trimmingCharacters(in: .whitespaces)
        symbolLabel.text = model.symbol
    }
}
