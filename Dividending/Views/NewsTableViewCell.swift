//
//  NewsTableViewCell.swift
//  Dividending
//
//  Created by Patrick Fonseca on 7/20/23.
//

import UIKit

/// Shows a news list item
class NewsTableViewCell: UITableViewCell {

    @IBOutlet weak var providerLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
        
    /// Configure with the news details model
    func configure(model: NewsDetails) {
        providerLabel.text = model.publisher
        dateLabel.text = model.ago
        titleLabel.text = model.title
    }
}
