//
//  Cache.swift
//  OpenMarket
//
//  Created by marlang, Taeangel on 2022/06/01.
//

import UIKit

struct Cache {
    static let cache: NSCache<NSURL, UIImage> = {
        let cache = NSCache<NSURL, UIImage>()
        cache.countLimit = 20
        return cache
    }()
   
    private init() {}
}
