//
//  APIRequest.swift
//  OpenMarket
//
//  Created by minsson on 2022/12/09.
//

import UIKit

protocol OpenMarketAPIRequest {
    
    var urlHost: String { get }
    var urlPath: String { get }
    var httpMethod: String { get }
    
}

protocol OpenMarketAPIRequestGettable: OpenMarketAPIRequest {
    
    var queryItems: [String: String]? { get }
    var productID: String? { get }
    
}

protocol OpenMarketAPIRequestPostable: OpenMarketAPIRequest, MultipartFormDataHandleable { }

extension OpenMarketAPIRequest {
    
    var urlHost: String {
        return "https://openmarket.yagom-academy.kr/"
    }
    
    var urlPath: String {
        return "api/products/"
    }
    
}


extension OpenMarketAPIRequestGettable {
    
    var httpMethod: String {
        return HTTPMethod.get.rawValue
    }
    
    var url: URL? {
        
        var urlComponents = URLComponents(string: urlHost + urlPath)
        
        let queryItems = queryItems ?? [:]
        urlComponents?.queryItems = queryItems.map {
            URLQueryItem(name: $0.key, value: $0.value)
        }
        
        let productID = productID ?? ""
        urlComponents?.path += productID
        
        return urlComponents?.url
    }
    
    var urlRequest: URLRequest? {
        guard let url = url else {
            return nil
        }
        let request = URLRequest(url: url)
        
        return request
    }
    
}

extension OpenMarketAPIRequestPostable {
    
    var url: URL? {
        let urlComponents = URLComponents(string: urlHost + urlPath)
        
        return urlComponents?.url
    }
    
    var urlRequest: URLRequest? {
        guard let url = url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.setValue("7184295e-4aa1-11ed-a200-354cb82ae52e", forHTTPHeaderField: "identifier")
        request.setValue("multipart/form-data; boundary=" + boundary, forHTTPHeaderField: "Content-type")
        request.httpBody = multipartFormBody
        return request
    }
    
}

protocol OpenMarketAPIRequestPatchable: OpenMarketAPIRequest {
    
    var productID: String? { get }
    var jsonData: Data? { get }
    
}

extension OpenMarketAPIRequestPatchable {
    
    var url: URL? {
        
        var urlComponents = URLComponents(string: urlHost + urlPath)
        
        let productID = productID ?? ""
        urlComponents?.path += productID
        
        return urlComponents?.url
    }
    
    var urlRequest: URLRequest? {
        guard let url = url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.setValue("7184295e-4aa1-11ed-a200-354cb82ae52e", forHTTPHeaderField: "identifier")
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        request.httpBody = jsonData
        
        return request
    }
    
}

protocol MultipartFormDataHandleable {
    
    var jsonData: Data? { get }
    var boundary: String { get }
    var images: [UIImage] { get }
    
}

extension MultipartFormDataHandleable {
    
    var multipartFormBody: Data? {
        var body = Data()
        let lineBreak = "\r\n"
        
        guard let jsonData = jsonData else {
            return nil
        }
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"params\"\(lineBreak + lineBreak)")
        body.append(jsonData)
        body.append("\(lineBreak)")
        
        images.forEach { image in
            body.append("--\(boundary + lineBreak)")
            body.append("Content-Disposition: form-data; name=\"images\"; filename=\"\(UUID().uuidString).jpg\"\(lineBreak)")
            body.append("Content-Type: image/jpeg\(lineBreak + lineBreak)")
            body.append(image.jpegData(compressionQuality: 0.1)!)
            body.append(lineBreak)
        }
        
        body.append("--\(boundary)--\(lineBreak)")
        
        return body
    }
    
}

fileprivate extension Data {
    
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
    
}
