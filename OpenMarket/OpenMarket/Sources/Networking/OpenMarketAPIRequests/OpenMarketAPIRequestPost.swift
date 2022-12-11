//
//  OpenMarketAPIRequestPost.swift
//  OpenMarket
//
//  Created by minsson on 2022/12/09.
//

import UIKit

struct OpenMarketAPIRequestPost: OpenMarketAPIRequest, OpenMarketAPIRequestSettable {
    
    var jsonData: Data?
    var image: UIImage
    
    let boundary: String = UUID().uuidString
    let httpMethod: String = HTTPMethod.post.rawValue
    
}
