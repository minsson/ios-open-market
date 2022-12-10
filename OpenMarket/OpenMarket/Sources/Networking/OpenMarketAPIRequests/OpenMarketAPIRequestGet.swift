//
//  OpenMarketAPIRequests.swift
//  OpenMarket
//
//  Created by minsson on 2022/12/09.
//

import Foundation

struct OpenMarketAPIRequestGet: OpenMarketAPIRequest, OpenMarketAPIRequestGettable {
    
    var queryItems = [
        "page_no": "1",
        "items_per_page": "100"
    ]
    
    var httpMethod: String = HTTPMethod.get.rawValue
    
}
