//
//  UIImageView.swift
//  OpenMarket
//
//  Created by 조민호 on 2022/05/20.
//

import UIKit

extension UIImageView {
    func loadImage(url: URL, apiService: APIProvider, completion: @escaping () -> ()) -> URLSessionDataTaskProtocol? {
        let nsURL = url as NSURL
        let imageCacheManager = ImageCacheManager.shared
        
        if let cachedImage = imageCacheManager.cache.object(forKey: nsURL) {
            self.image = cachedImage
            completion()
            return nil
        }
        
        return apiService.requestImage(with: url) { result in
            switch result {
            case .success(let data):
                if let image = UIImage(data: data) {
                    imageCacheManager.cache.setObject(image, forKey: nsURL)
                    DispatchQueue.main.async {
                        self.image = image
                    }
                    completion()
                }
            case .failure(_):
                DispatchQueue.main.async {
                    self.image = UIImage(systemName: "photo")
                }
            }
        }
    }
}

