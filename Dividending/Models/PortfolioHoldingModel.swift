//
//  PortfolioHoldingModel.swift
//  DivTracker
//
//  Created by Apps4World on 3/6/23.
//

import Foundation

/// A simple representation of a portfolio item/holding
struct PortfolioHoldingModel {
    let name: String
    let symbol: String
    let price: Double
    let shares: Int
    let paymentDate: Date
    let annualDividend: Double
    
    /// Holding value
    var value: Double {
        price * Double(shares)
    }
    
    /// Upcoming payment
    var upcomingPayment: Double {
        annualDividend / 12.0
    }
    
    /// Upcoming formatted title
    var upcomingTitle: String {
        "\(symbol) (\(paymentDate.string))"
    }
    
    /// Monthly dividend amount
    var monthlyAmount: Double {
        (annualDividend / 12.0) * Double(shares)
    }
}

// MARK: - Build a holding model from Core Data entity
extension PortfolioHoldingModel {
    static func build(with entity: StockEntity) -> PortfolioHoldingModel? {
        guard let name = entity.name, let symbol = entity.symbol, let payDate = entity.dividendPaymentDate  else { return nil }
        return PortfolioHoldingModel(name: name, symbol: symbol,
                                     price: entity.price, shares: Int(entity.shares),
                                     paymentDate: payDate, annualDividend: entity.annualizedDividend)
    }
}
