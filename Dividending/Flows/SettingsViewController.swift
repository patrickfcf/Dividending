//
//  SettingsViewController.swift
//  Dividending
//
//  Created by Patrick Fonseca on 7/20/23.
//

import UIKit
import Combine
import StoreKit
import MessageUI
import PurchaseKit

/// Main settings for the app
class SettingsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var goalTextField: PriceTextField!
    private var dataManager: DataManager = DataManager.shared
    private var subscriptions: Set<AnyCancellable> = Set<AnyCancellable>()
    
    /// Default logic when the view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        registerObservers()
        updateGoalTextField()
        configureTextField()
    }
    
    private func configureTextField() {
        goalTextField.layer.borderColor = UIColor.systemMint.cgColor
        goalTextField.layer.cornerRadius = 5.0
        goalTextField.layer.borderWidth = 1
    }
    
    private func registerObservers() {
        dataManager.objectWillChange.sink { [weak self] _ in
            DispatchQueue.main.async {
                if self?.dataManager.currentSegmentedTab == .settings {
                    self?.updateGoalTextField()
                }
            }
        }.store(in: &subscriptions)
    }
    
    private func updateGoalTextField() {
        goalTextField.text = dataManager.annualGoal.dollarAmount
    }

    @IBAction func updateGoalAction(_ sender: Any) {
        goalTextField.resignFirstResponder()
        guard let goalAmount = goalTextField.text?.double else { return }
        dataManager.annualGoal = goalAmount
        presentAlert(title: "Well Done!", message: "Your annual goal has been updated", primaryAction: .OK)
    }
}

// MARK: - Handle Table view items
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        SettingsItem.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = SettingsItem.allCases[indexPath.row].rawValue
        cell.imageView?.image = UIImage(systemName: SettingsItem.allCases[indexPath.row].icon)
        return cell
    }
}

// MARK: - Show Settings item details
extension SettingsViewController {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch SettingsItem.allCases[indexPath.row] {
        case .privacyPolicy:
            UIApplication.shared.open(AppConfig.privacyURL)
        case .termsOfUse:
            UIApplication.shared.open(AppConfig.termsAndConditionsURL)
        case .premiumUpgrade:
            presentLoadingIndicator()
            PKManager.purchaseProduct(identifier: AppConfig.premiumVersion) { _, status, _ in
                DispatchQueue.main.async {
                    if status == .success {
                        self.dataManager.isPremiumUser = true
                    }
                    hideLoadingIndicator()
                }
            }
        case .restorePurchases:
            var didFinishRestoringPurchases: Bool = false
            presentLoadingIndicator()
            PKManager.restorePurchases { _, status, _ in
                DispatchQueue.main.async {
                    if status == .restored {
                        self.dataManager.isPremiumUser = true
                    }
                    didFinishRestoringPurchases = true
                    hideLoadingIndicator()
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                if !didFinishRestoringPurchases {
                    hideLoadingIndicator()
                }
            }
        case .contactUs:
            EmailPresenter.shared.present()
        case .shareApp:
            let shareController = UIActivityViewController(activityItems: [AppConfig.yourAppURL], applicationActivities: nil)
            rootController?.present(shareController, animated: true, completion: nil)
        case .rateApp:
            if let scene = windowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        case .aboutCreator:
            UIApplication.shared.open(AppConfig.aboutCreatorURL)
        }
    }
}

// MARK: - Mail presenter
class EmailPresenter: NSObject, MFMailComposeViewControllerDelegate {
    public static let shared = EmailPresenter()
    private override init() { }
    
    func present() {
        if !MFMailComposeViewController.canSendMail() {
            presentAlert(title: "Email Client", message: "Your device must have the native iOS email app installed for this feature.", primaryAction: .OK)
            return
        }
        let picker = MFMailComposeViewController()
        picker.setToRecipients([AppConfig.emailSupport])
        picker.mailComposeDelegate = self
        rootController?.present(picker, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        rootController?.dismiss(animated: true, completion: nil)
    }
}
