//
//  HoldingCollectionViewCell.swift
//  DivTracker
//
//  Created by Apps4World on 3/6/23.
//

import UIKit

/// Shows a portfolio holding on the dashboard/home tab
class HoldingCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    /// Reset cell data before re-using the cell
    override func prepareForReuse() {
        super.prepareForReuse()
        resetCollectionViewCellData()
    }
    
    /// Configure the cell with a given portfolio item details
    func configure(title: String, subtitle: String, searchIcon: Bool) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        if searchIcon {
            iconImageView.image = UIImage(systemName: "magnifyingglass")
        } else {
            let iconURL = AppConfig.stockLogoAPI.replacingOccurrences(of: "<symbol>", with: title).lowercased()
            iconImageView.accessibilityIdentifier = iconURL
            iconImageView.assignImage(fromURLString: iconURL, cacheKey: title)
        }
    }
    
    private func resetCollectionViewCellData() {
        iconImageView.image = nil
        iconImageView.accessibilityIdentifier = nil
    }
}
