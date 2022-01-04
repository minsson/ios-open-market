import Foundation

struct NetworkDataTransfer {
    private var url: String
    private var semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
    var isConnected: Bool {
        return getHealthChecker()
    }
    
    init(url: String = "https://market-training.yagom-academy.kr/") {
        self.url = url
    }
    
    private func getHealthChecker() -> Bool {
        guard let url = URL(string: "\(self.url)healthChecker") else {
            return false
        }
        var result: Bool = false
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { _, response, _ in
            let successStatusCode = 200
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == successStatusCode else {
                      semaphore.signal()
                      return
                  }
            result = true
            semaphore.signal()
        }
        dataTask.resume()
        semaphore.wait()
        
        return result
    }
    
    func getProductDetail(id: Int) -> Product? {
        guard isConnected,
              let url = URL(string: "\(self.url)api/products/\(id)") else {
            return nil
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        
        var product: Product?
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in
            let successStatusCode = 200...299
            
            guard let httpResponse = response as? HTTPURLResponse,
                  successStatusCode.contains(httpResponse.statusCode) else {
                      semaphore.signal()
                      return
                  }
            
            product = JSONParser<Product>().decode(from: data)
            semaphore.signal()
        }
        dataTask.resume()
        semaphore.wait()
        
        return product
    }
}
