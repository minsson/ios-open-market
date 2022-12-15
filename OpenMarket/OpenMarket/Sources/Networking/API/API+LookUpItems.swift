//
//  API+LookUpItems.swift
//  OpenMarket
//
//  Created by minsson on 2022/12/15.
//

import Foundation

extension API {
    
    struct LookUpItems: OpenMarketAPIRequestGettable {
        
        var productID: String?
        var queryItems: [String: String]? = [
            "page_no": "1",
            "items_per_page": "100"
        ]
        
    }
    
}

