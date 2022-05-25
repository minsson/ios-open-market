//
//  Product.swift
//  OpenMarket
//
//  Created by dudu, safari on 2022/05/09.
//

import Foundation

struct Product: Codable, Hashable {
    let id: Int?
    let vendorId: Int?
    let name: String?
    let thumbnail: String?
    let currency: Currency?
    let price: Double?
    let description: String?
    let bargainPrice: Double?
    let discountedPrice: Double?
    let stock: Int?
    let createdAt: String?
    let issuedAt: String?
    let images: [Image]?
    let vendors: Vendor?
    let secret: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, thumbnail, currency, price, description, stock
        case vendorId = "vendor_id"
        case bargainPrice = "bargain_price"
        case discountedPrice = "discounted_price"
        case createdAt = "created_at"
        case issuedAt = "issued_at"
        case images, vendors, secret
    }
    
    struct Image: Codable, Hashable {
        let id: Int?
        let url: String?
        let thumbnailUrl: String?
        let succeed: Bool?
        let issuedAt: String?
        
        enum CodingKeys: String, CodingKey {
            case id, url, succeed
            case thumbnailUrl = "thumbnail_url"
            case issuedAt = "issued_at"
        }
    }
    
    struct Vendor: Codable, Hashable {
        let name: String?
        let id: Int?
        let createdAt: String?
        let issuedAt: String?
        
        enum CodingKeys: String, CodingKey {
            case name, id
            case createdAt = "created_at"
            case issuedAt = "issued_at"
        }
    }
}
