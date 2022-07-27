//
//  ImageCacheManager.swift
//  OpenMarket
//
//  Created by 이예은 on 2022/07/27.
//

import Foundation
import UIKit

class ImageCacheManager {
    static let shared = NSCache<NSString, UIImage>()
    private init() {}
}
