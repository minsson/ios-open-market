//
//  ItemDetailModel.swift
//  OpenMarket
//
//  Created by minsson on 2022/12/17.
//

struct ItemDetail: Decodable {
    
    // MARK: - Properties
    
    let id, vendorID: Int
    let name: String
    let description: String
    let thumbnail: String
    let currency: Currency
    let price, bargainPrice, discountedPrice: Double
    let stock: Int
    let images: [ItemImage]
    let vendors: Vendor
    let createdAt, issuedAt: String
    
    // MARK: - Enums
    
    private enum CodingKeys: String, CodingKey {
        
        case id
        case vendorID = "vendor_id"
        case name
        case description
        case thumbnail
        case currency
        case price
        case bargainPrice = "bargain_price"
        case discountedPrice = "discounted_price"
        case stock
        case images
        case vendors
        case createdAt = "created_at"
        case issuedAt = "issued_at"
        
    }
    
    // MARK: - Nested Struct
    
    struct ItemImage: Decodable, Hashable {
        
        // MARK: - Properties
        
        let id: Int
        let url: String
        let thumbnailURL: String
        let issuedAt: String
        
        
        // MARK: - Enums
        
        private enum CodingKeys: String, CodingKey {
            
            case id
            case url
            case thumbnailURL = "thumbnail_url"
            case issuedAt = "issued_at"
            
        }
        
    }
    
    struct Vendor: Decodable {
        
        let id: Int
        let name: String
        
    }
    
}

