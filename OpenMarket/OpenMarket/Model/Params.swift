//
//  Params.swift
//  OpenMarket
//
//  Created by cathy, mmim.
//

import Foundation

struct Params: Encodable {
  let name: String
  let price: Int
  let discountedPrice: Int
  let stock: Int
  let currency: String
  let descriptions: String
  let secret: String
  
  private enum CodingKeys: String, CodingKey {
    case name, price, stock, currency, descriptions, secret
    case discountedPrice = "discounted_price"
  }
}

struct ImageFile {
  let fileName: String = "imageName.jpeg"
  let type: String = "jpeg"
  let data: Data
}
