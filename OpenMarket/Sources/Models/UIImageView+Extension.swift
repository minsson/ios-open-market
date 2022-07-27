//
//  UIImageView+Extension.swift
//  OpenMarket
//
//  Created by 이예은 on 2022/07/27.
//

import UIKit

extension UIImageView {
    func setImageURL(_ url: String) {
        DispatchQueue.global(qos: .background).async {

            // cache할 객체의 key값을 string으로 생성
            let cachedKey = NSString(string: url)
            let session = URLSession.shared
            // cache된 이미지가 존재하면 그 이미지를 사용 (API 호출안함)
            if let cachedImage = ImageCacheManager.shared.object(forKey: cachedKey) {
                DispatchQueue.main.async {
                    self.image = cachedImage
                }
                return
            }

            guard let url = URL(string: url) else {
                return
            }
            
            session.dataTask(with: url) { (data, result, error) in
                guard error == nil else {
                    DispatchQueue.main.async { [weak self] in
                        self?.image = UIImage()
                    }
                    return
                }

                DispatchQueue.main.async { [weak self] in
                    if let data = data, let image = UIImage(data: data) {

                        // 캐싱
                        ImageCacheManager.shared.setObject(image, forKey: cachedKey)
                        self?.image = image
                    }
                }
            }.resume()
        }
    }
}
