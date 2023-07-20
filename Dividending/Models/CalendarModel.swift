//
//  CalendarModel.swift
//  Dividending
//
//  Created by Patrick Fonseca on 7/20/23.
//

import Foundation

/// A model for dividend calendar
struct CalendarModel: Codable {
    let data: CalendarData
}

struct CalendarData: Codable {
    let calendar: CalendarItems
}

struct CalendarItems: Codable {
    let rows: [CalendarItem]
}

struct CalendarItem: Codable {
    let symbol: String
    let companyName: String
    let paymentDate: String
    let annualDividend: Double
    
    enum CodingKeys: String, CodingKey {
        case symbol, companyName
        case paymentDate = "payment_Date"
        case annualDividend = "indicated_Annual_Dividend"
    }
    
    var date: Date {
        paymentDate.date
    }
}
