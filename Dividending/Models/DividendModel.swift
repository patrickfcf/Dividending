//
//  DividendModel.swift
//  DivTracker
//
//  Created by Apps4World on 3/6/23.
//

import Foundation

/// A model for dividends data
struct DividendModel: Codable {
    let data: DividendValues
    let symbol: String?
    let name: String?
}

struct DividendValues: Codable {
    let dividendPaymentDate: String
    let annualizedDividend: String
    let exDividendDate: String
    let yield: String
    
    func value(forType type: DividendDataType) -> String {
        switch type {
        case .annualizedDividend:
            return "$" + annualizedDividend
        case .dividendPaymentDate:
            return dividendPaymentDate
        case .exDividendDate:
            return exDividendDate
        case .yield:
            return yield
        }
    }
}

enum DividendDataType: String, Identifiable, CaseIterable {
    case annualizedDividend, exDividendDate, dividendPaymentDate, yield
    var id: Int { hashValue }
}

extension DividendModel {
    static func build(withSymbol symbol: String, name: String) -> DividendModel {
        DividendModel(data: .init(dividendPaymentDate: "", annualizedDividend: "", exDividendDate: "", yield: ""),
                      symbol: symbol, name: name)
    }
}
