//
//  HomeViewController.swift
//  Dividending
//
//  Created by Patrick Fonseca on 7/20/23.
//

import UIKit
import Combine

/// Shows the main bottom controller for the dashboard/home tab
class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addStocksButton: UIButton!
    private var dataManager: DataManager = DataManager.shared
    private var subscriptions: Set<AnyCancellable> = Set<AnyCancellable>()

    /// Default logic when the view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        registerObservers()
        buildCompositionalLayout()
    }
    
    private func registerObservers() {
        dataManager.objectWillChange.sink { [weak self] _ in
            DispatchQueue.main.async {
                if self?.dataManager.currentSegmentedTab == .dashboard {
                    self?.buildCompositionalLayout()
                    self?.tableView?.reloadData()
                }
            }
        }.store(in: &subscriptions)
        dataManager.fetchPortfolioData()
    }

    private func buildCompositionalLayout() {
        let layout: UICollectionViewCompositionalLayout = dataManager.portfolioHoldings.count == 0 ? actionLayout : horizontalLayout
        collectionView?.alwaysBounceVertical = false
        collectionView?.alwaysBounceHorizontal = true
        collectionView?.setCollectionViewLayout(layout, animated: false)
        addStocksButton?.isHidden = dataManager.portfolioHoldings.count == 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.collectionView?.reloadData()
        }
    }

    private var horizontalLayout: UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { _, _ in
            let groupItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
            let groupItem = NSCollectionLayoutItem(layoutSize: groupItemSize)
            groupItem.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 20)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.235), heightDimension: .absolute(75))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [groupItem])
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 0)
            return section
        }
    }

    private var actionLayout: UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { _, _ in
            let groupItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
            let groupItem = NSCollectionLayoutItem(layoutSize: groupItemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(75))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [groupItem])
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 20)
            return section
        }
    }
    
    @IBAction func presentSearchFlow(_ sender: Any) {
        if let searchController = storyboard?.instantiateViewController(withIdentifier: "searchController") {
            if let presentationController = searchController.presentationController as? UISheetPresentationController {
                presentationController.detents = [.medium(), .large()]
                presentationController.preferredCornerRadius = 30
            }
            present(searchController, animated: true)
        }
    }
}

// MARK: - Handle Collection view items (Porfolio Holdings)
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataManager.portfolioHoldings.count == 0 ? 1 : dataManager.portfolioHoldings.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? HoldingCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        var item: PortfolioHoldingModel?
        if dataManager.portfolioHoldings.count > 0 {
            item = dataManager.portfolioHoldings[indexPath.row]
        }
        
        let title: String = item?.symbol ?? "Your Portfolio"
        let subtitle: String = item?.annualDividend.dollarAmount ?? "Search and Add some stocks"
        cell.configure(title: title, subtitle: subtitle, searchIcon: item == nil)
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if dataManager.portfolioHoldings.count == 0 {
            presentSearchFlow(self)
        } else {
            let result = dataManager.portfolioHoldings[indexPath.row]
            if let dividendFlow = DividendViewController.instantiate(symbol: result.symbol, name: result.name, holdings: dataManager.portfolioHoldings) {
                present(dividendFlow, animated: true)
            }
        }
    }
}

// MARK: - Handle Table view items (Upcoming Payments
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        var item: PortfolioHoldingModel?
        if dataManager.upcomingPayments?.count ?? 0 > 0 {
            item = dataManager.upcomingPayments?[indexPath.row]
        }
        
        let title: String = item?.upcomingTitle ?? "Nothing to see here ⎯ yet"
        let subtitle: String = item?.upcomingPayment.dollarAmount ?? ""
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = subtitle
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        (dataManager.upcomingPayments?.count ?? 0) == 0 ? 1 : (dataManager.upcomingPayments?.count ?? 0)
    }
}
