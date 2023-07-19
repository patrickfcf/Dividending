//
//  TrendingTableViewCell.swift
//  DivTracker
//
//  Created by Apps4World on 3/6/23.
//

import UIKit

/// Shows a trending dividend item
class TrendingTableViewCell: UITableViewCell {

    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var annualAmountLabel: UILabel!
    @IBOutlet weak var yieldLabel: UILabel!
    
    /// Configure labels with the model
    func configure(model: DividendModel) {
        symbolLabel.text = model.symbol
        companyNameLabel.text = model.name
        let paymentAmount = model.data.value(forType: .annualizedDividend)
        annualAmountLabel.text = "Annual payment: \(paymentAmount.double == 0.0 ? "- -" : paymentAmount)"
        let yieldAmount = model.data.value(forType: .yield)
        yieldLabel.text = yieldAmount.double == 0.0 ? "- - -" : yieldAmount
    }
}
