//
//  PortfolioValueViewController.swift
//  Dividending
//
//  Created by Patrick Fonseca on 7/20/23.
//

import UIKit
import Combine

/// Shows the total portolio value
class PortfolioValueViewController: UIViewController {

    @IBOutlet weak var totalValueLabel: UILabel!
    @IBOutlet weak var monthlyAmountLabel: UILabel!
    @IBOutlet weak var highestPayingLabel: UILabel!
    private var dataManager: DataManager = DataManager.shared
    private var subscriptions: Set<AnyCancellable> = Set<AnyCancellable>()
    
    /// Default logic when the view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        registerObservers()
    }
    
    private func registerObservers() {
        dataManager.objectWillChange.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.updatePortfolioData()
            }
        }.store(in: &subscriptions)
    }

    func updatePortfolioData() {
        totalValueLabel.text = dataManager.totalPortfolioValue.dollarAmount
        monthlyAmountLabel.text = dataManager.monthlyDividendsAmount
        highestPayingLabel.text = dataManager.highestPayingHolding
    }
    
    @IBAction func showHighestPayingInfo(_ sender: Any) {
        presentAlert(title: "Highest Paying", message: "This stock provides the highest dividends based on both the number of shares held and the yield of the stock's dividends.", primaryAction: .OK)
    }
    
    @IBAction func showMonthlyDividendInfo(_ sender: Any) {
        presentAlert(title: "Monthly Dividend", message: "This refers to the total amount of dividends earned per month. Some stocks distribute dividends quarterly while others do so monthly. This figure is calculated by dividing the yearly dividend payment by 12.", primaryAction: .OK)
    }
}
