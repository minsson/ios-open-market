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
    
    var queryItems: [String: String] { get }
    
}

protocol OpenMarketAPIRequestSettable: OpenMarketAPIRequest {
    
    var image: UIImage { get }
    
}

extension OpenMarketAPIRequestGettable {
    
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
        let request = URLRequest(url: url)
        
        return request
    }
    
}

extension OpenMarketAPIRequestSettable {
    
    var url: URL? {
        let urlComponents = URLComponents(string: urlHost + urlPath)
        
        return urlComponents?.url
    }
    
    // TODO: urlRequest를 쪼갤 필요성이 있음
    var urlRequest: URLRequest? {
        guard let url = url else {
            return nil
        }
        
        let boundary: String = UUID().uuidString
        let lineBreak = "\r\n"
        
        var request = URLRequest(url: url)
        var body = Data()
        
        request.httpMethod = "POST"
        request.setValue("7184295e-4aa1-11ed-a200-354cb82ae52e", forHTTPHeaderField: "identifier")
        request.setValue("multipart/form-data; boundary=" + boundary, forHTTPHeaderField: "Content-type")
        
        // TODO: temporaryData를 실제 데이터로 교체하기
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"params\"\(lineBreak + lineBreak)")
        let temporaryData = "{\"name\": \"민\", \"price\": 15000, \"stock\":1000, \"currency\": \"KRW\", \"secret\": \"ebs12345\", \"description\": \"화이팅\"}"
        body.append("\(temporaryData + lineBreak)")
        
        body.append("--\(boundary + lineBreak)")
        body.append("Content-Disposition: form-data; name=\"images\"; filename=\"\(UUID().uuidString).jpg\"\(lineBreak)")
        body.append("Content-Type: image/jpeg\(lineBreak + lineBreak)")
        body.append(image.jpegData(compressionQuality: 0.1)!)
        body.append(lineBreak)
        body.append("--\(boundary)--\(lineBreak)")
        
        request.httpBody = body
        return request
    }
    
}

fileprivate extension Data {
    
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
    
}
