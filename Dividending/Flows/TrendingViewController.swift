//
//  TrendingViewController.swift
//  DivTracker
//
//  Created by Apps4World on 3/6/23.
//

import UIKit
import Combine

/// Shows a list of trending dividend items
class TrendingViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
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
                if self?.dataManager.currentSegmentedTab == .trending {
                    self?.tableView?.reloadData()
                }
            }
        }.store(in: &subscriptions)
        
        dataManager.$currentSegmentedTab.sink { [weak self] _ in
            DispatchQueue.main.async {
                if self?.dataManager.currentSegmentedTab == .trending {
                    self?.dataManager.fetchTrendingDividendData()
                }
            }
        }.store(in: &subscriptions)
    }
}

// MARK: - Handle Table view items
extension TrendingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataManager.trendingItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? TrendingTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(model: dataManager.trendingItems[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let result = dataManager.trendingItems[indexPath.row]
        guard let symbol = result.symbol, let name = result.name else { return }
        if let dividendFlow = DividendViewController.instantiate(symbol: symbol, name: name, holdings: dataManager.portfolioHoldings) {
            present(dividendFlow, animated: true)
        }
    }
}
