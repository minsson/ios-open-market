//
//  NetworkManager.swift
//  OpenMarket
//
//  Created by minsson, yeton on 2022/07/14.
//

import UIKit

struct NetworkManager {
    
    // MARK: - Static Actions
    
    static func execute(
        _ urlRequest: URLRequest,
        completion: @escaping (Result<Data, NetworkingError>) -> Void
    ) {
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if error != nil {
                return completion(.failure(.clientTransport))
            }
            
            guard isValidResponse(response) else {
                return completion(.failure(.serverSideInvalidResponse))
            }
            
            guard let data = data else {
                return completion(.failure(.missingData))
            }
            
            completion(.success(data))
        }
        task.resume()
    }
    
    // TODO: 에러처리 구현
    static func decode<T: Decodable>(_ data: Data,
                                    into type: T.Type) -> T? {
        do {
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            return decodedData
        } catch {
            return nil
        }
    }
    
    static func encode<T: Encodable>(data: T) -> Data? {
        do {
            let decodedData =  try JSONEncoder().encode(data)
            return decodedData
        } catch {
            return nil
        }
    }
}

// MARK: - Private Static Actions

private extension NetworkManager {
    static func isValidResponse(_ response: URLResponse?) -> Bool {
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            return false
        }
        
        return true
    }
}
