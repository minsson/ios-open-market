//
//  ProductInput.swift
//  OpenMarket
//
//  Created by papri, Tiana on 31/05/2022.
//

import Foundation

struct ProductInput {
    private var productInput: [String: Any] = [:]
    
    var isEmpty: Bool {
        return productInput.isEmpty
    }
    
    func isValidName(product: ProductDetail?) -> Bool {
        if let name = productInput["name"] as? String {
            return name.count >= 3
        }
        return product != nil ? true : false
    }
    
    func isValidDescription(product: ProductDetail?) -> Bool {
        if let description = productInput["descriptions"] as? String {
            return description.count >= 10
        }
        return product != nil ? true : false
    }
    
    func getProductInput() -> [String: Any] {
        return productInput
    }
    
    mutating func setName(with value: String?) {
        guard let value = value else { return }
        productInput["name"] = value
    }
    
    mutating func setPrice(with value: String?) {
        guard let value = Int(value ?? "0") else { return }
        productInput["price"] = value
    }
    
    mutating func setDiscountedPrice(with value: String?) {
        guard let value = Int(value ?? "0") else { return }
        productInput["discounted_price"] = value
    }
    
    mutating func setStock(with value: String?) {
        guard let value = Int(value ?? "0") else { return }
        productInput["stock"] = value
    }
    
    mutating func setDescriptions(with value: String?) {
        productInput["descriptions"] = value
    }
    
    mutating func setCurrency(with value: String?) {
        productInput["currency"] = value
    }
    
    mutating func convertDescription() {
        if let description = productInput["descriptions"] as? String {
            setDescriptions(with: description.replacingOccurrences(of: "\n", with: "\\n"))
        }
    }
    
    mutating func setDefaultCurrency() {
        if !productInput.keys.contains("currency") {
            setCurrency(with: "KRW")
        }
    }
}
