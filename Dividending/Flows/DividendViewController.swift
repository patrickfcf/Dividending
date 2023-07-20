//
//  DividendViewController.swift
//  Dividending
//
//  Created by Patrick Fonseca on 7/20/23.
//

import UIKit

/// Shows dividend data for a selected stock
class DividendViewController: UIViewController {

    @IBOutlet weak var deletePositionButton: UIButton!
    @IBOutlet weak var savePositionButton: UIButton!
    @IBOutlet weak var priceTextField: PriceTextField!
    @IBOutlet weak var sharesTextField: UITextField!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var stockSymbolLabel: UILabel!
    @IBOutlet weak var exDividendLabel: UILabel!
    @IBOutlet weak var yieldLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    private var dividendModel: DividendModel?
    private var dataManager: DataManager = DataManager.shared
    var currentSharesCount: Int?
    var currentSharesPrice: Double?
    var selectedStock: SearchResultModel!
    
    /// Default logic when the view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDividendData()
        updateCurrentSharesData()
    }

    var sharesCount: Int {
        sharesTextField.text?.integer ?? 0
    }
    
    var pricePerShare: Double {
        priceTextField.text?.double ?? 0.0
    }
    
    func updateCurrentSharesData() {
        guard let currentShares = currentSharesCount, let currentPrice = currentSharesPrice else { return }
        sharesTextField.text = "\(currentShares)"
        priceTextField.text = currentPrice.dollarAmount
        savePositionButton.setTitle("Update Position", for: .normal)
        deletePositionButton.isHidden = false
    }
    
    func configureDividendData() {
        companyNameLabel.text = selectedStock.name
        stockSymbolLabel.text = selectedStock.symbol
        dataManager.fetchDividendData(for: selectedStock.symbol) { model in
            DispatchQueue.main.async {
                guard let dividendData = model else { return }
                self.dividendModel = dividendData
                self.yieldLabel.text = dividendData.data.value(forType: .yield)
                self.amountLabel.text = dividendData.data.value(forType: .annualizedDividend)
                self.exDividendLabel.text = dividendData.data.value(forType: .exDividendDate)
            }
        }
        
        if !dataManager.isPremiumUser && dataManager.portfolioHoldings.count >= AppConfig.freePortfolioItems {
            self.savePositionButton.setTitle("Premium Version Required", for: .normal)
            self.savePositionButton.isEnabled = false
        } else {
            priceTextField.priceDidChange = {
                self.savePositionButton.isEnabled =  self.sharesCount > 0 &&  self.pricePerShare > 0.0
            }
        }
    }
    
    @IBAction func savePositionAction(_ sender: Any) {
        if let model = dividendModel, model.data.annualizedDividend.double > 0.0 {
            let data = DividendModel(data: model.data, symbol: selectedStock.symbol, name: selectedStock.name)
            dataManager.savePosition(shares: sharesCount, price: pricePerShare, dividendData: data)
            dismiss(animated: true) {
                self.dataManager.objectWillChange.send()
            }
        } else {
            presentAlert(title: "Oops!", message: "Looks like the dividend data is missing", primaryAction: .OK)
        }
    }
    
    @IBAction func shareCountChanged(_ sender: UITextField) {
        savePositionButton.isEnabled = sharesCount > 0 && pricePerShare > 0.0
    }
    
    @IBAction func deletePosition(_ sender: Any) {
        presentAlert(title: "Delete Position", message: "Are you sure you want to delete your entire \(selectedStock.symbol) position?", primaryAction: .Cancel, secondaryAction: .init(title: "Delete", style: .destructive, handler: { _ in
            self.dataManager.deletePosition(symbol: self.selectedStock.symbol)
            self.dismiss(animated: true) {
                self.dataManager.objectWillChange.send()
            }
        }))
    }
}

// MARK: - Present `DividendViewController` from anywhere in the app
extension DividendViewController {
    static func instantiate(symbol: String, name: String, holdings: [PortfolioHoldingModel]) -> DividendViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let dividendController = storyboard.instantiateViewController(withIdentifier: "dividendController") as? DividendViewController {
            dividendController.selectedStock = SearchResultModel(name: name, symbol: symbol, asset: "")
            
            if let existingPosition = holdings.first(where: { $0.symbol == symbol }) {
                dividendController.currentSharesPrice = existingPosition.price
                dividendController.currentSharesCount = existingPosition.shares
            }
            
            if let presentationController = dividendController.presentationController as? UISheetPresentationController {
                presentationController.detents = [.medium(), .large()]
                presentationController.preferredCornerRadius = 30
                presentationController.prefersGrabberVisible = true
            }
            
            return dividendController
        }
        return nil
    }
}

