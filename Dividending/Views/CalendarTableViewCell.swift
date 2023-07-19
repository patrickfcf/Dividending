//
//  CalendarTableViewCell.swift
//  DivTracker
//
//  Created by Apps4World on 3/6/23.
//

import UIKit

/// Shows a calendar dividend item
class CalendarTableViewCell: UITableViewCell {

    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var paymentDateLabel: UILabel!
    @IBOutlet weak var dividendAmountLabel: UILabel!
    
    /// Configure labels with the model
    func configure(model: CalendarItem) {
        symbolLabel.text = model.symbol
        companyNameLabel.text = model.companyName
        paymentDateLabel.text = "Payment Date: \(model.paymentDate)"
        dividendAmountLabel.text = model.annualDividend.dollarAmount
    }
}
