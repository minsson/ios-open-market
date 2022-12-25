//
//  API+DeleteItem.swift
//  OpenMarket
//
//  Created by minsson on 2022/12/25.
//

import Foundation

extension API {
    
    struct DeleteItem: OpenMarketAPIRequestDeletable {
        
        var productID: String
        var deletionTargetItemURI: String
        var httpMethodForSearchingURI = HTTPMethod.post.rawValue
        let httpMethod: String = HTTPMethod.delete.rawValue
                
    }
    
}
