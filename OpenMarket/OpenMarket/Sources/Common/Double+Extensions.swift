//
//  Double+Extensions.swift
//  OpenMarket
//
//  Created by minsson, yeton on 2022/08/03.
//

import Foundation

extension Double {
    
    // MARK: - Actions
    
    func applyFormat(currency: Currency?) -> String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 4
        numberFormatter.roundingMode = .up
        
        guard let price = numberFormatter.string(from: self as NSNumber) else {
                  return nil
              }
        
        guard let currency = currency else {
            return price
        }
        
        return currency.rawValue + " " + price
    }
}
