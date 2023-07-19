//
//  AppDelegate.swift
//  DivTracker
//
//  Created by Apps4World on 1/27/23.
//

import UIKit
import Foundation
import PurchaseKit
import GoogleMobileAds
import AppTrackingTransparency

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        PKManager.loadProducts(identifiers: [AppConfig.premiumVersion])
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { _ in self.requestIDFA() }
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        return true
    }
    
    /// Display the App Tracking Transparency authorization request for accessing the IDFA
    func requestIDFA() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            ATTrackingManager.requestTrackingAuthorization { _ in }
        }
    }
}

// MARK: - Google AdMob Interstitial - Support class
class Interstitial: NSObject, GADFullScreenContentDelegate {
    var isPremiumUser: Bool = UserDefaults.standard.bool(forKey: AppConfig.premiumVersion)
    private var interstitial: GADInterstitialAd?
    static var shared: Interstitial = Interstitial()

    /// Default initializer of interstitial class
    override init() {
        super.init()
        loadInterstitial()
    }

    /// Request AdMob Interstitial ads
    func loadInterstitial() {
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: AppConfig.adMobAdId, request: request, completionHandler: { [self] ad, error in
            if ad != nil { interstitial = ad }
            interstitial?.fullScreenContentDelegate = self
        })
    }

    func showInterstitialAds() {
        if self.interstitial != nil, !isPremiumUser {
            guard let root = rootController else { return }
            self.interstitial?.present(fromRootViewController: root)
        }
    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        loadInterstitial()
    }
}

/// Present an alert from anywhere in the app
func presentAlert(title: String, message: String, primaryAction: UIAlertAction, secondaryAction: UIAlertAction? = nil, tertiaryAction: UIAlertAction? = nil) {
    DispatchQueue.main.async {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(primaryAction)
        if let secondary = secondaryAction { alert.addAction(secondary) }
        if let tertiary = tertiaryAction { alert.addAction(tertiary) }
        rootController?.present(alert, animated: true, completion: nil)
    }
}

extension UIAlertAction {
    static var Cancel: UIAlertAction {
        UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    }
    
    static var OK: UIAlertAction {
        UIAlertAction(title: "OK", style: .cancel, handler: nil)
    }
}

var rootController: UIViewController? {
    var root = windowScene?.windows.first(where: { $0.isKeyWindow })?.rootViewController
    while root?.presentedViewController != nil {
        root = root?.presentedViewController
    }
    return root
}

var windowScene: UIWindowScene? {
    UIApplication.shared.connectedScenes
        .filter({ $0.activationState == .foregroundActive })
        .first(where: { $0 is UIWindowScene }).flatMap({ $0 as? UIWindowScene })
}

/// Formatting strings and doubles
extension String {
    var commaString: String {
        double.formattedString
    }
    
    var double: Double {
        Formatter.currency.number(from: self)?.doubleValue ?? Double(self) ?? Double(self.replacingOccurrences(of: "%", with: "")) ?? 0.0
    }
    
    var integer: Int {
        Int(self) ?? 0
    }
    
    var date: Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        dateFormatter.locale = Locale(identifier: "en_US")
        return dateFormatter.date(from: self) ?? Date()
    }
    
    func currency(locale: Locale) -> String? {
        Formatter.currency.locale = locale
        if self.isEmpty {
            return Formatter.currency.string(from: NSNumber(value: 0))
        } else {
            return Formatter.currency.string(from: NSNumber(value: (Double(self) ?? 0) / 100))
        }
    }
}

extension Date {
    var string: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        dateFormatter.locale = Locale(identifier: "en_US")
        return dateFormatter.string(from: self)
    }
}

extension Double {
    var formattedString: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
    
    var dollarAmount: String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.roundingMode = .down
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.locale = Locale(identifier: "en_US")
        currencyFormatter.maximumFractionDigits = 2
        
        let value = self
        if value >= 1000000000 {
            let formattedValue = currencyFormatter.string(from: NSNumber(value: value / 1000000000)) ?? "- -"
            return "\(formattedValue)B"
        } else if value >= 10000000 {
            let formattedValue = currencyFormatter.string(from: NSNumber(value: value / 1000000)) ?? "- -"
            return "\(formattedValue)M"
        } else {
            let formattedValue = currencyFormatter.string(from: NSNumber(value: value)) ?? "- -"
            return formattedValue
        }
    }
}

/// Custom formatter
extension Formatter {
    static let currency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()
}

/// Find a subview for a given type
extension UIView {
    func first<T: UIView>(ofType: T.Type) -> T? {
        recursiveSubviews.compactMap { $0 as? T }.first
    }
    
    var recursiveSubviews: [UIView] {
        subviews + subviews.flatMap { $0.recursiveSubviews }
    }
}

/// Useful extensions for the UIImageView
extension UIImageView {
    
    /// Download image from URL and assign it to the image view
    func assignImage(fromURLString string: String, cacheKey: String) {
        guard let imageURL = URL(string: string) else { return }
        if let cachedImage = PersistenceManager.shared.cachedImage(forKey: cacheKey) {
            DispatchQueue.main.async { self.image = cachedImage }
        } else {
            fetchImage(forURL: imageURL, cacheKey: cacheKey)
        }
    }
    
    /// Fetch image for a given URL
    func fetchImage(forURL imageURL: URL, cacheKey: String) {
        URLSession.shared.dataTask(with: imageURL) { data, _, _ in
            if let imageData = data, let downloadedImage = UIImage(data: imageData) {
                if self.accessibilityIdentifier == imageURL.absoluteString, self.accessibilityIdentifier != nil {
                    DispatchQueue.main.async { self.image = downloadedImage }
                    PersistenceManager.shared.cacheImage(downloadedImage, key: cacheKey)
                }
            }
        }.resume()
    }
}

/// Present loading indicator from anywhere in the app
func presentLoadingIndicator() {
    let overlayView = UIView(frame: .zero)
    overlayView.translatesAutoresizingMaskIntoConstraints = false
    overlayView.backgroundColor = UIColor(white: 0, alpha: 0.7)
    
    let indicatorView = UIActivityIndicatorView(style: .medium)
    indicatorView.translatesAutoresizingMaskIntoConstraints = false
    indicatorView.color = .white
    indicatorView.startAnimating()
    overlayView.addSubview(indicatorView)
    indicatorView.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor).isActive = true
    indicatorView.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor, constant: -10).isActive = true
    overlayView.tag = 101001
    
    let primaryLabel = UILabel(frame: .zero)
    primaryLabel.text = "please wait..."
    primaryLabel.textColor = .white
    primaryLabel.translatesAutoresizingMaskIntoConstraints = false
    overlayView.addSubview(primaryLabel)
    primaryLabel.topAnchor.constraint(equalTo: indicatorView.bottomAnchor, constant: 5).isActive = true
    primaryLabel.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor).isActive = true
    
    guard let hostView = windowScene?.keyWindow else { return }
    hostView.addSubview(overlayView)
    overlayView.topAnchor.constraint(equalTo: hostView.topAnchor).isActive = true
    overlayView.bottomAnchor.constraint(equalTo: hostView.bottomAnchor).isActive = true
    overlayView.leftAnchor.constraint(equalTo: hostView.leftAnchor).isActive = true
    overlayView.rightAnchor.constraint(equalTo: hostView.rightAnchor).isActive = true
}

func hideLoadingIndicator() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        windowScene?.keyWindow?.viewWithTag(101001)?.removeFromSuperview()
    }
}
