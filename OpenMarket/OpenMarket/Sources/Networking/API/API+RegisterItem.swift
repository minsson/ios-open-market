//
//  OpenMarketAPIRequestPost.swift
//  OpenMarket
//
//  Created by minsson on 2022/12/09.
//

import UIKit

extension API {
    
    struct RegisterItem: OpenMarketAPIRequestPostable {
        
        var jsonData: Data?
        var images: [UIImage]
        
        let boundary: String = UUID().uuidString
        let httpMethod: String = HTTPMethod.post.rawValue
        
    }
    
}
