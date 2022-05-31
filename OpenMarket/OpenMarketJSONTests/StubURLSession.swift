//
//  StubURLSession.swift
//  OpenMarket
//
//  Created by SeoDongyeon on 2022/05/13.
//

import Foundation

struct DummyData {
    let data: Data?
    let response: URLResponse?
    let error: Error?
    var completionHandler: ((Data?, URLResponse?, Error?) -> Void?)? = nil
    
    func completion() {
        completionHandler?(data, response, error)
    }
}

final class StubURLSession: URLSessionProtocol {
    func dataTask(with urlRequest: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return StubURLSessionDataTask(dummy: dummyData, completionHandler: completionHandler)
    }
    
    var dummyData: DummyData?
    
    init(dummy: DummyData) {
        self.dummyData = dummy
    }
    
    func dataTask(
        with url: URL,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTask {
        return StubURLSessionDataTask(dummy: dummyData, completionHandler: completionHandler)
    }
}

final class StubURLSessionDataTask: URLSessionDataTask {
    var dummyData: DummyData?
    
    init(
        dummy: DummyData?,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void?
    ) {
        self.dummyData = dummy
        self.dummyData?.completionHandler = completionHandler
    }
    
    override func resume() {
        dummyData?.completion()
    }
}
