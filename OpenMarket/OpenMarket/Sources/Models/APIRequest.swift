//
//  APIRequest.swift
//  OpenMarket
//
//  Created by minsson on 2022/08/10.
//

import Foundation

struct APIRequest {
    
    // MARK: - Life Cycles
    
    init(url: URL, httpMethod: HTTPMethod, body: Data?) {
        self.url = url
        self.httpMethod = httpMethod
        self.body = body
    }
    
    // MARK: - Properties
    
    private var url: URL
    private var httpMethod: HTTPMethod
    private var body: Data?
    
    // MARK: - Actions
    
    func createURLRequest() -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = self.httpMethod.rawValue
        urlRequest.httpBody = self.body
        return urlRequest
    }
}
