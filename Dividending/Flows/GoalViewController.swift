//
//  GoalViewController.swift
//  DivTracker
//
//  Created by Apps4World on 3/6/23.
//

import UIKit
import Combine

/// Shows the goal tile and progress
class GoalViewController: UIViewController {

    @IBOutlet weak var goalTextField: PriceTextField!
    @IBOutlet weak var goalProgressContainer: UIView!
    @IBOutlet weak var goalProgressLabel: UILabel!
    @IBOutlet weak var progressContainer: UIView!
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
                if self?.dataManager.currentSegmentedTab == .dashboard {
                    self?.configureAnnualGoal()
                }
            }
        }.store(in: &subscriptions)
        goalTextField?.layer.borderColor = UIColor.systemMint.cgColor
        goalTextField?.layer.cornerRadius = 5.0
        goalTextField?.layer.borderWidth = 1
    }

    private func configureAnnualGoal() {
        goalProgressContainer?.isHidden = dataManager.annualGoal == 0.0
        goalProgressLabel?.text = dataManager.currentGoalProgress.dollarAmount + " / \(dataManager.annualGoal.dollarAmount)"
        if let container = goalProgressContainer, dataManager.annualGoal > 0 {
            container.first(ofType: GoalProgressView.self)?.updateProgress(dataManager.currentGoalProgress/dataManager.annualGoal)
            view.bringSubviewToFront(container)
        }
    }

    @IBAction func saveGoalAction(_ sender: Any) {
        goalTextField.resignFirstResponder()
        guard let goalAmount = goalTextField.text?.double else { return }
        dataManager.annualGoal = goalAmount
        configureAnnualGoal()
    }
}
