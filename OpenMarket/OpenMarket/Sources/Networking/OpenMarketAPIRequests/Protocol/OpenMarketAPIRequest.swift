//
//  APIRequest.swift
//  OpenMarket
//
//  Created by minsson on 2022/12/09.
//

import Foundation

protocol OpenMarketAPIRequest {
    
    var urlHost: String { get }
    var urlPath: String { get }
    var queryItems: [String: String] { get }
    
    var httpHeader: [String: String]? { get }
    var httpMethod: String { get }
    var httpBody: Data? { get }
    
}

extension OpenMarketAPIRequest {
    
    var url: URL? {
        var urlComponents = URLComponents(string: urlHost + urlPath)
        urlComponents?.queryItems = self.queryItems.map {
            URLQueryItem(name: $0.key, value: $0.value)
        }
        
        return urlComponents?.url
    }
    
    var urlRequest: URLRequest? {
        guard let url = url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = self.httpHeader
        request.httpMethod = self.httpMethod
        request.httpBody = self.httpBody
        return request
    }
    
}
