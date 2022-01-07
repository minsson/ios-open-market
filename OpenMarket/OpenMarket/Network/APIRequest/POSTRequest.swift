//
//  POSTRequest.swift
//  OpenMarket
//
//  Created by JeongTaek Han on 2022/01/07.
//

import Foundation

protocol POSTRequest: APIRequest {
    
    var header: [String: String] { get }
    var body: [String: Any] { get }
    var boundary: String { get }
    
}

extension POSTRequest {
    
    var method: String { return "POST" }
    
}
