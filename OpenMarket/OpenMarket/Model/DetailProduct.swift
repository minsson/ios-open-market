//
//  DetailProduct.swift
//  OpenMarket
//
//  Created by cathy, mmim.
//

import Foundation

struct DetailProduct: Decodable {
  let id: Int
  let venderId: Int
  let name: String?
  let description: String?
  let thumbnail: String?
  let currency: Currency
  let price: Int?
  let bargainPrice: Int?
  let discountedPrice: Int?
  let stock: Int?
  let images: [Image]
  let vendors: Vendor
  let createdAt: String
  let issuedAt: String
  
  private enum CodingKeys: String, CodingKey {
    case id, name, description, thumbnail, currency, price, stock, images, vendors
    case venderId = "vendor_id"
    case bargainPrice = "bargain_price"
    case discountedPrice = "discounted_price"
    case createdAt = "created_at"
    case issuedAt = "issued_at"
  }
}

struct Image: Decodable {
  let id: Int
  let url: String
  let thumbnailUrl: String
  let succeed: Bool
  let issuedAt: String
  
  private enum CodingKeys: String, CodingKey {
    case id, url, succeed
    case thumbnailUrl = "thumbnail_url"
    case issuedAt = "issued_at"
  }
}

struct Vendor: Decodable {
  let name: String
  let id: Int
  let createdAt: String
  let issuedAt: String
  
  private enum CodingKeys: String, CodingKey {
    case name, id
    case createdAt = "created_at"
    case issuedAt = "issued_at"
  }
}
