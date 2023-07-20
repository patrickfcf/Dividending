//
//  DataManager.swift
//  Dividending
//
//  Created by Patrick Fonseca on 7/20/23.
//

import SwiftUI
import Combine
import CoreData
import Foundation

/// Main data manager for the app
class DataManager: NSObject, ObservableObject {
    
    /// Dynamic properties that the UI will react to
    @Published var currentSegmentedTab: SegmentedTabType = .dashboard
    
    /// Singleton instance
    static var shared: DataManager = DataManager()
    
    /// Stocks search results
    var searchResults: [SearchResultModel] = [SearchResultModel]()
    
    /// Porfolio holdings from Core Data
    var portfolioHoldings: [PortfolioHoldingModel] = [PortfolioHoldingModel]()
    
    /// Latest news list
    var latestNews: [NewsDetails] = [NewsDetails]()
    
    /// Calendar items
    var calendarItems: [CalendarItem] = [CalendarItem]()
    
    /// Trending items
    var trendingItems: [DividendModel] = AppConfig.trendingItems.shuffled()
    
    /// Dynamic properties that the UI will react to AND store values in UserDefaults
    @AppStorage("annualGoal") var annualGoal: Double = 0.0
    @AppStorage(AppConfig.premiumVersion) var isPremiumUser: Bool = false {
        didSet { Interstitial.shared.isPremiumUser = isPremiumUser }
    }
    
    /// Core Data container with the database model
    let container: NSPersistentContainer = PersistenceManager.shared.container
    
    /// Default initializer
    override init() {
        super.init()
        fetchPortfolioData()
    }
}

// MARK: - Search Request
extension DataManager {
    
    /// Search for a given stock
    func search(for query: String?, completion: @escaping () -> Void) {
        guard let searchTerm = query?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: AppConfig.searchAPI + searchTerm)
        else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }
            let results = try? JSONDecoder().decode(SearchResults.self, from: data)
            DispatchQueue.main.async {
                self.searchResults = results?.data.filter({ $0.asset == "STOCKS" }) ?? []
                completion()
            }
        }.resume()
    }
}

// MARK: - Dividend Request
extension DataManager {
    
    /// Get dividend data for a stock symbol
    func fetchDividendData(for symbol: String, completion: @escaping (_ model: DividendModel?) -> Void) {
        guard let url = URL(string: AppConfig.dividendsAPI.replacingOccurrences(of: "<symbol>", with: symbol)) else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }
            let model = try? JSONDecoder().decode(DividendModel.self, from: data)
            completion(model)
        }.resume()
    }
    
    /// Get dividend data for all trending stocks
    func fetchTrendingDividendData() {
        let dispatchGroup = DispatchGroup()
        trendingItems.enumerated().forEach { index, model in
            dispatchGroup.enter()
            fetchDividendData(for: model.symbol!) { updatedData in
                if let updatedModel = updatedData {
                    self.trendingItems[index] = DividendModel(data: updatedModel.data, symbol: model.symbol, name: model.name)
                }
                self.objectWillChange.send()
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) {
            self.objectWillChange.send()
        }
    }
}

// MARK: - Handle Portfolio Positions
extension DataManager {
    
    /// Fetch saved portfolio items
    func fetchPortfolioData() {
        let fetchRequest: NSFetchRequest<StockEntity> = StockEntity.fetchRequest()
        if let results = try? container.viewContext.fetch(fetchRequest) {
            self.portfolioHoldings = results.compactMap({ PortfolioHoldingModel.build(with: $0) })
            self.objectWillChange.send()
        }
    }
    
    /// Save a portfolio position based on shares count and price
    func savePosition(shares: Int, price: Double, dividendData: DividendModel) {
        guard let symbol = dividendData.symbol else { return }
        let fetchRequest: NSFetchRequest<StockEntity> = StockEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "symbol == %@", symbol)
        let existingItem = try? container.viewContext.fetch(fetchRequest).first
        let stockEntity = existingItem ?? StockEntity(context: container.viewContext)
        stockEntity.symbol = dividendData.symbol
        stockEntity.name = dividendData.name
        stockEntity.price = price
        stockEntity.shares = Int64(shares)
        stockEntity.dividendPaymentDate = dividendData.data.dividendPaymentDate.date
        stockEntity.annualizedDividend = dividendData.data.annualizedDividend.double
        try? container.viewContext.save()
        fetchPortfolioData()
    }
    
    /// Delete a portfolio position
    func deletePosition(symbol: String) {
        let fetchRequest: NSFetchRequest<StockEntity> = StockEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "symbol == %@", symbol)
        if let existingItem = try? container.viewContext.fetch(fetchRequest).first {
            container.viewContext.delete(existingItem)
            try? container.viewContext.save()
            fetchPortfolioData()
        }
    }
}

// MARK: - Fetch latest news
extension DataManager {
    
    /// Fetch latest news
    func fetchLatestNews() {
        guard let url = URL(string: AppConfig.newsAPI) else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }
            let model = try? JSONDecoder().decode(NewsModel.self, from: data)
            self.latestNews = model?.data.rows ?? []
            self.objectWillChange.send()
        }.resume()
    }
}

// MARK: - Fetch Calendar items
extension DataManager {
    
    /// Fetch dividend calendar items
    func fetchCalendarData() {
        guard let url = URL(string: AppConfig.calendarAPI) else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }
            let model = try? JSONDecoder().decode(CalendarModel.self, from: data)
            self.calendarItems = model?.data.calendar.rows.sorted(by: { $0.date < $1.date }) ?? []
            self.objectWillChange.send()
        }.resume()
    }
}

// MARK: - Local calculations
extension DataManager {
    
    /// Current annual dividend amount towards the goal
    var currentGoalProgress: Double {
        portfolioHoldings.map { holding in
            holding.annualDividend * Double(holding.shares)
        }.reduce(0, +)
    }
    
    /// Total portfolio value
    var totalPortfolioValue: Double {
        portfolioHoldings.map({ $0.value }).reduce(0, +)
    }
    
    /// Upcoming payment details
    var upcomingPayments: [PortfolioHoldingModel]? {
        portfolioHoldings.sorted(by: { $0.paymentDate > $1.paymentDate }).filter({ $0.paymentDate > Date() })
    }
    
    /// Monthly dividends amount
    var monthlyDividendsAmount: String {
        let amount = portfolioHoldings.map({ $0.monthlyAmount }).reduce(0, +)
        return amount > 0.0 ? amount.dollarAmount : "- - -"
    }
    
    /// Highest Paying Stock
    var highestPayingHolding: String {
        if let holding = portfolioHoldings.sorted(by: { $0.monthlyAmount > $1.monthlyAmount}).first {
            return holding.symbol
        }
        return "- - -"
    }
}
