//
//  AppConfig.swift
//  Dividending
//
//  Created by Patrick Fonseca on 7/20/23.
//

import UIKit
import SwiftUI
import Foundation

/// Generic configurations for the app
class AppConfig {
    
    /// This is the AdMob Interstitial ad id
    /// Test App ID: ca-app-pub-3940256099942544~1458002511
    static let adMobAdId: String = "ca-app-pub-1884043504892272~3219363851"
    
    // MARK: - Generic Configurations
    static let apiHost: String = "https://api.nasdaq.com/api"
    static let newsAPI: String = apiHost + "/news/topic/latestnews?offset=0&limit=20&blacklist=true"
    static let searchAPI: String = apiHost + "/autocomplete/slookup/10?search="
    static let calendarAPI: String = apiHost + "/calendar/dividends"
    static let dividendsAPI: String = apiHost + "/quote/<symbol>/dividends?assetclass=stocks"
    static let stockLogoAPI: String = "https://s3.polygon.io/logos/<symbol>/logo.png"
    
    // MARK: - Settings flow items
    static let emailSupport = "support@dividending.io"
    static let privacyURL: URL = URL(string: "http://dividending.io/privacy")!
    static let termsAndConditionsURL: URL = URL(string: "http://dividending.io/terms")!
    static let yourAppURL: URL = URL(string: "http://apps.apple.com/app/idXXXXXXXXX")!
    
    // MARK: - Trending Dividend items
    static let trendingItems: [DividendModel] = [
        .build(withSymbol: "AAPL", name: "Apple Inc."),
        .build(withSymbol: "UPS", name: "United Parcel Service"),
        .build(withSymbol: "PM", name: "Philip Morris International"),
        .build(withSymbol: "USB", name: "U.S. Bancorp"),
        .build(withSymbol: "VZ", name: "Verizon Communications"),
        .build(withSymbol: "WHR", name: "Whirlpool")
    ]
    
    // MARK: - In App Purchases
    static let premiumVersion: String = "DivTracker.Premium"
    static let freePortfolioItems: Int = 5
}

// MARK: - Dashboard flows
enum SegmentedTabType: Int, CaseIterable {
    case dashboard = 1, news, calendar, trending, settings
}

// MARK: - Settings Item
enum SettingsItem: String, CaseIterable {
    case premiumUpgrade = "Premium Upgrade"
    case restorePurchases = "Restore Purchases"
    case rateApp = "Rate App"
    case shareApp = "Share App"
    case contactUs = "Contact Us"
    case termsOfUse = "Terms & Conditions"
    case privacyPolicy = "Privacy Policy"
    
    /// Item Icon
    var icon: String {
        switch self {
        case .rateApp: return "star.fill"
        case .shareApp: return "square.and.arrow.up.fill"
        case .contactUs: return "envelope.badge.fill"
        case .restorePurchases: return "arrow.counterclockwise.circle.fill"
        case .premiumUpgrade: return "crown.fill"
        case .termsOfUse: return "doc.text.fill"
        case .privacyPolicy: return "checkmark.shield.fill"
        }
    }
}
