//
//  OpenMarketAPIRequestPost.swift
//  OpenMarket
//
//  Created by minsson on 2022/12/09.
//

import UIKit

struct OpenMarketAPIRequestPost: OpenMarketAPIRequest, OpenMarketAPIRequestSettable {
    
    var image: UIImage
    
    var urlHost = "https://openmarket.yagom-academy.kr/"
    var urlPath = "api/products"
        
    var httpMethod: String = HTTPMethod.post.rawValue
    
}
