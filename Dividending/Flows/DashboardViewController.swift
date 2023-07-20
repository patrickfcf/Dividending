//
//  DashboardViewController.swift
//  Dividending
//
//  Created by Patrick Fonseca on 7/20/23.
//

import UIKit

/// Main dashboard for the app
class DashboardViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    private var selectedTab: SegmentedTabType = .dashboard
    private var bottomController: BottomViewController?

    /// Default logic when the view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        buildCompositionalLayout()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateSegmentContainer()
    }

    private func buildCompositionalLayout() {
        let layout = UICollectionViewCompositionalLayout { _, _ in
            let groupItemSize = NSCollectionLayoutSize(widthDimension: .estimated(50), heightDimension: .fractionalHeight(1))
            let groupItem = NSCollectionLayoutItem(layoutSize: groupItemSize)
            groupItem.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 20)
            let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(50), heightDimension: .absolute(40))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [groupItem])
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 20)
            return section
        }
        collectionView.alwaysBounceVertical = false
        collectionView.setCollectionViewLayout(layout, animated: true)
    }

    private func updateSegmentContainer() {
        if bottomController == nil {
            let id: String = "bottomController"
            bottomController = storyboard?.instantiateViewController(withIdentifier: id) as? BottomViewController
            bottomController?.isModalInPresentation = true
            if let presentationController = bottomController?.presentationController as? UISheetPresentationController {
                presentationController.detents = [.medium(), .large()]
                presentationController.preferredCornerRadius = 30
                presentationController.prefersGrabberVisible = true
                presentationController.largestUndimmedDetentIdentifier = .medium
            }
            present(bottomController!, animated: true)
        }
        bottomController?.updateSelectedTab(selectedTab)
    }
}

// MARK: - Handle Collection view items
extension DashboardViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return SegmentedTabType.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? SegmentCollectionViewCell else {
            return UICollectionViewCell()
        }
        let segment: SegmentedTabType = SegmentedTabType.allCases[indexPath.row]
        cell.configure(title: "\(segment)".capitalized, selected: selectedTab == segment)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SegmentCollectionViewCell else { return }
        selectedTab = SegmentedTabType.allCases[indexPath.row]
        SegmentedTabType.allCases.enumerated().forEach { index, _ in
            guard let inactiveCell = collectionView.cellForItem(at: .init(row: index, section: 0)) as? SegmentCollectionViewCell else { return }
            inactiveCell.configureStyle(selected: false)
        }
        cell.configureStyle(selected: true)
        updateSegmentContainer()
    }
}
