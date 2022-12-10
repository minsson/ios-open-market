//
//  OpenMarketAPIRequestPost.swift
//  OpenMarket
//
//  Created by minsson on 2022/12/09.
//

import UIKit

struct OpenMarketAPIRequestPost: OpenMarketAPIRequest, OpenMarketAPIRequestSettable {
    
    var image: UIImage
    
    var httpMethod: String = HTTPMethod.post.rawValue
    
}
