//
//  SearchViewController.swift
//  DivTracker
//
//  Created by Apps4World on 3/6/23.
//

import UIKit

/// Search for a stock flow
class SearchViewController: UIViewController {

    @IBOutlet weak var emptyStateStackView: UIStackView!
    private var searchController: UISearchController!
    private var dataManager: DataManager = DataManager.shared

    /// Default logic when the view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchController()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dataManager.objectWillChange.send()
    }

    private func configureSearchController() {
        let resultsController = ResultsTableController()
        resultsController.tableView.delegate = self
        searchController = UISearchController(searchResultsController: resultsController)
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.searchController = searchController
    }
}

// MARK: - Handle Search bar interaction
extension SearchViewController: UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate, UITableViewDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        if let resultsController = searchController.searchResultsController as? ResultsTableController {
            dataManager.search(for: searchController.searchBar.text) {
                resultsController.items = self.dataManager.searchResults
                resultsController.tableView.reloadData()
            }
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        emptyStateStackView.isHidden = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        emptyStateStackView.isHidden = false
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchController.searchBar.resignFirstResponder()
        let result = dataManager.searchResults[indexPath.row]
        if let dividendFlow = DividendViewController.instantiate(symbol: result.symbol, name: result.name, holdings: dataManager.portfolioHoldings) {
            present(dividendFlow, animated: true)
        }
    }
}

// MARK: - Search results controller
class ResultsTableController: UITableViewController {

    var items: [SearchResultModel] = [SearchResultModel]()

    /// Default logic when the view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }

    private func configureTableView() {
        tableView.register(UINib(nibName: "ResultTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
    }
}

/// Display search results list
extension ResultsTableController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ResultTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(model: items[indexPath.row])
        return cell
    }
}
