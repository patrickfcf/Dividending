//
//  BottomViewController.swift
//  DivTracker
//
//  Created by Apps4World on 3/6/23.
//

import UIKit

/// Custom container to host bottom view controllers
class BottomViewController: UIViewController {

    /// Default logic when the view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        updateSelectedTab(.dashboard)
    }

    /// Update visible dashboard flow based on selected tab
    func updateSelectedTab(_ tab: SegmentedTabType) {
        view.subviews.forEach { subview in
            subview.isHidden = true
        }
        view.viewWithTag(tab.rawValue)?.isHidden = false
        DataManager.shared.currentSegmentedTab = tab
        Interstitial.shared.showInterstitialAds()
    }
}
