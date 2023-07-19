//
//  PriceTextField.swift
//  DivTracker
//
//  Created by Apps4World on 3/6/23.
//

import UIKit

/// Custom text field for stock price formatting
class PriceTextField: UITextField {
    
    private var enteredNumbers = ""
    private var didBackspace = false
    private let locale: Locale = Locale(identifier: "en_US")
    var priceDidChange: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureTextField()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureTextField()
    }
    
    private func configureTextField() {
        addTarget(self, action: #selector(editingChanged), for: .editingChanged)
    }
    
    override func deleteBackward() {
        enteredNumbers = String(enteredNumbers.dropLast())
        text = enteredNumbers.currency(locale: locale)
        didBackspace = true
        super.deleteBackward()
    }
    
    @objc func editingChanged() {
        defer {
            didBackspace = false
            text = enteredNumbers.currency(locale: locale)
            priceDidChange?()
        }
        
        guard didBackspace == false else {
            priceDidChange?()
            return
        }
        
        if let lastCharacter = text?.last, lastCharacter.isNumber {
            enteredNumbers.append(lastCharacter)
        }
        
        priceDidChange?()
    }
}
