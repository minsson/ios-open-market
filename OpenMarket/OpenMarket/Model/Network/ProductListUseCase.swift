//
//  ProductListUseCase.swift
//  OpenMarket
//
//  Created by 우롱차, Donnie on 2022/05/25.
//

import UIKit

struct ProductListUseCase {
    
    private let network: NetworkAble
    private let jsonDecoder: JSONDecoder
    private let pageInfoManager: PageInfoManager

    init(network: Network, jsonDecoder: JSONDecoder, pageInfoManager: PageInfoManager){
        self.network = network
        self.jsonDecoder = jsonDecoder
        self.pageInfoManager = pageInfoManager
    }
    
    func requestPageInformation(
        completeHandler: @escaping (PageInformation) -> Void,
        errorHandler: @escaping (Error) -> Void
    ) {
        guard let url = pageInfoManager.currentPageInformationUrl else {
            errorHandler(NetworkError.urlError)
            return
        }
        
        network.requestData(url: url) {
            data, response -> Void in
            guard let data = data,
                  let decodedData = try? jsonDecoder.decode(PageInformation.self, from: data) else {
                errorHandler(UseCaseError.decodingError)
                return
            }
            completeHandler(decodedData)
        } errorHandler: { error in
            errorHandler(error)
        }
    }
    
}

extension Data {
    mutating func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}
