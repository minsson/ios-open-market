//
//  Currency.swift
//  OpenMarket
//
//  Created by minsson on 2022/11/25.
//

enum Currency: String, Decodable {
    
    case krw = "KRW"
    case usd = "USD"
    
    var index: Int {
        switch self {
        case .krw:
            return 0
        case .usd:
            return 1
        }
    }
}
