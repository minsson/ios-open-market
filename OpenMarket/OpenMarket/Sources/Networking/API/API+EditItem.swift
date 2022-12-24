//
//  API+Edit.swift
//  OpenMarket
//
//  Created by minsson on 2022/12/23.
//

import UIKit

extension API {
    
    struct EditItem: OpenMarketAPIRequestPatchable {
        
        var productID: String?
        var jsonData: Data?
        
        let httpMethod: String = HTTPMethod.patch.rawValue
        
        init(productID: String, with jsonData: Data?) {
            self.productID = productID
            self.jsonData = jsonData
        }
        
    }
    
}
