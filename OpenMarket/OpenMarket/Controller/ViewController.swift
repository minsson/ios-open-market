//
//  OpenMarket - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit

class ViewController: UIViewController {
    let networkManager = NetworkManager()

    override func viewDidLoad() {
        super.viewDidLoad()

    // getItems
        networkManager.commuteWithAPI(api: GetItemsAPI(page: 1)) { _ in
        }
        
    // getItem
//        networkManager.commuteWithAPI(api: GetItemAPI(id: 643)) { _ in
//        }
        
    // post
//        guard let testImage = Media(image: #imageLiteral(resourceName: "test1"), mimeType: .png) else { return }
//        let postMultipart = MultipartFormData(title: "test", descriptions: "test1", price: 100, currency: "KRW", stock: 5, discountedPrice: 50, password: "12345")
//        networkManager.commuteWithAPI(api: PostAPI(parameter: postMultipart.parameter, image: [testImage])) { _ in
//        }
        
    // Patch
//        let patchMultipart = MultipartFormData(title: "modify", descriptions: "test2", password: "12345")
//        networkManager.commuteWithAPI(api: PatchAPI(id: 643, parameter: patchMultipart.parameter, image: nil)) { _ in
//        }
        
    // Delete
//        networkManager.commuteWithAPI(api: DeleteAPI(id: 643, password: "12345")) { _ in
//        }
    }
}
