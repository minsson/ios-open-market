//
//  URLSessionProvider.swift
//  OpenMarket
//
//  Created by marlang, Taeangel on 2022/05/12.
//

import UIKit

enum OpenMarket: String {
    case identifier = "5fbc34e4-d1b8-11ec-9676-f7ffe1d75e84"
    case secret = "qb19a7ac0m"
    
    var description: String {
        return self.rawValue
    }
}

struct URLSessionProvider<T: Decodable> {
    private let session: URLSessionProtocol
    
    init (session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    func fetchData(
        from url: Endpoint,
        completionHandler: @escaping (Result<T, NetworkError>) -> Void
    ) {
        
        guard let request = makeURLRequest(httpMethod: .get, url: url) else {
            return completionHandler(.failure(.urlError))
        }
        
        let task = session.dataTask(with: request) { data, urlResponse, error in
            
            guard error == nil else {
                completionHandler(.failure(.clientError))
                return
            }
            
            guard let httpResponse = urlResponse as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completionHandler(.failure(.statusCodeError))
                return
            }
            
            guard let data = data else {
                completionHandler(.failure(.dataError))
                return
            }
            
            guard let resultData = T.parse(data: data) else {
                completionHandler(.failure(.decodeError))
                return
            }
            
            completionHandler(.success(resultData))
        }
        task.resume()
    }
    
    func postData(
        params: ProductInfomation,
        completionHandler: @escaping (Result<Void, NetworkError>) -> Void) {
        
        guard var urlRequest = makeURLRequest(httpMethod: .post, url: Endpoint.productRegistration) else {
            return completionHandler(.failure(.urlError))
        }
        
        let boundary = UUID().uuidString
        
        urlRequest.addValue(OpenMarket.identifier.description, forHTTPHeaderField: "identifier")
        urlRequest.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        urlRequest.httpBody = createBody(params: params, boundary: boundary)
        let task = session.dataTask(with: urlRequest) { _, urlResponse, error in
            
            guard error == nil else {
                completionHandler(.failure(.clientError))
                return
            }
            
            guard let httpResponse = urlResponse as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completionHandler(.failure(.statusCodeError))
                return
            }
            
            completionHandler(.success(()))
        }
        task.resume()
    }
     
    func patchData(
        product: ProductInfomation,
        id: Int,
        completionHandler: @escaping (Result<Void, NetworkError>
    ) -> Void) {
        
        guard var urlRequest = makeURLRequest(httpMethod: .patch, url: .detailProduct(id: id)) else {
            return completionHandler(.failure(.urlError))
        }
        
        guard let product = try? Json.encoder.encode(product) else {
            return
        }
                
        urlRequest.addValue(OpenMarket.identifier.description, forHTTPHeaderField: "identifier")
        urlRequest.httpBody = product
        
        let task = session.dataTask(with: urlRequest) { _, urlResponse, error in
            guard error == nil else {
                completionHandler(.failure(.clientError))
                return
            }
            
            guard let httpResponse = urlResponse as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completionHandler(.failure(.statusCodeError))
                return
            }
            
            completionHandler(.success(()))
        }
        task.resume()
    }
}

extension URLSessionProvider {
    
    private func makeURLRequest(httpMethod: Http, url: Endpoint) -> URLRequest? {
        guard let url = url.url else {
            return nil
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod.method
        
        return urlRequest
    }
    
    private func createBody(params: ProductInfomation, boundary: String) -> Data? {
        var body = Data()
        let newline = "\r\n"
        let boundaryPrefix = "--\(boundary)\r\n"
        let boundarySuffix = "\r\n--\(boundary)--\r\n"
        
        guard let product = try? Json.encoder.encode(params) else {
            return nil
        }
        
        body.appendString(boundaryPrefix)
        body.appendString("Content-Disposition: form-data; name=\"params\"")
        body.appendString(newline)
        body.appendString(newline)
        body.append(product)
        body.appendString(newline)
        
        guard let images = params.images else {
            return nil
        }

        for image in images {
            body.appendString(boundaryPrefix)
            body.appendString("Content-Disposition: form-data; name=\"images\"; filename=\"\(image.fileName).jpeg\"")
            body.appendString(newline)
            body.appendString("Content-Type: image/\(image.type)")
            body.appendString(newline)
            body.appendString(newline)
            body.append(image.data)
            body.appendString(newline)
        }

        body.appendString(boundarySuffix)
        return body
    }
}
