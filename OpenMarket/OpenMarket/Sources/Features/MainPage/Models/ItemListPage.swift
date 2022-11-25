//
//  ItemListPage.swift
//  OpenMarket
//
//  Created by minsson, yeton on 2022/07/12.
//

struct ItemListPage: Decodable {
    
    // MARK: - Properties
    
    let pageNumber, itemsPerPage, totalCount, offset: Int
    let limit: Int
    let items: [Item]
    let lastPage: Int
    let hasNext, hasPrevious: Bool
    
    // MARK: - Enums
    
    private enum CodingKeys: String, CodingKey {
        case pageNumber = "pageNo"
        case itemsPerPage = "itemsPerPage"
        case totalCount = "totalCount"
        case offset, limit
        case items = "pages"
        case lastPage = "lastPage"
        case hasNext = "hasNext"
        case hasPrevious = "hasPrev"
    }
    
    // MARK: - Nested Struct
    
    struct Item: Decodable, Hashable {
        
        // MARK: - Properties
        
        let id, vendorID: Int
        let name: String
        let thumbnail: String
        let currency: Currency
        let price, bargainPrice, discountedPrice: Double
        let stock: Int
        let createdAt, issuedAt: String

        // MARK: - Enums
        
        private enum CodingKeys: String, CodingKey {
            case id
            case vendorID = "vendor_id"
            case name, thumbnail, currency, price
            case bargainPrice = "bargain_price"
            case discountedPrice = "discounted_price"
            case stock
            case createdAt = "created_at"
            case issuedAt = "issued_at"
        }
    }
}
