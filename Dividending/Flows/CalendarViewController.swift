//
//  CalendarViewController.swift
//  DivTracker
//
//  Created by Apps4World on 3/6/23.
//

import UIKit
import Combine

/// Shows a list of dividend calendar items
class CalendarViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyStateContainer: UIView!
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
                if self?.dataManager.currentSegmentedTab == .calendar {
                    self?.tableView?.reloadData()
                    self?.emptyStateContainer.isHidden = self?.dataManager.calendarItems.count ?? 0 > 0
                    if let emptyStateView = self?.emptyStateContainer, !emptyStateView.isHidden {
                        self?.view.bringSubviewToFront(emptyStateView)
                    }
                }
            }
        }.store(in: &subscriptions)
        
        dataManager.$currentSegmentedTab.sink { [weak self] _ in
            DispatchQueue.main.async {
                if self?.dataManager.currentSegmentedTab == .calendar {
                    self?.dataManager.fetchCalendarData()
                }
            }
        }.store(in: &subscriptions)
    }
}

// MARK: - Handle Table view items
extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataManager.calendarItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? CalendarTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(model: dataManager.calendarItems[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let result = dataManager.calendarItems[indexPath.row]
        if let dividendFlow = DividendViewController.instantiate(symbol: result.symbol, name: result.companyName, holdings: dataManager.portfolioHoldings) {
            present(dividendFlow, animated: true)
        }
    }
}
