//
//  API+LookUpItemDetail.swift
//  OpenMarket
//
//  Created by minsson on 2022/12/16.
//

import Foundation

extension API {
    
    struct LookUpItemDetail: OpenMarketAPIRequestGettable {
        
        var productID: String?
        var queryItems: [String: String]?
        
        init(productID: String) {
            self.productID = productID
        }
        
    }
    
}
