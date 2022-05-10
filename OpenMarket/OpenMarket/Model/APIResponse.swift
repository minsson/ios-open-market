//
//  APIResponse.swift
//  OpenMarket
//  Created by Lingo, Quokka
//

import Foundation

struct APIResponse: Decodable {
  let pageNo: Int
  let itemsPerPage: Int
  let totalCount: Int
  let offset: Int
  let limit: Int
  let pages: [Product]
  let lastPage: Int
  let hasNext: Bool
  let hasPrev: Bool
  
  private enum CodingKeys: String, CodingKey {
    case pageNo = "page_no"
    case itemsPerPage = "items_per_page"
    case totalCount = "total_count"
    case lastPage = "last_page"
    case hasNext = "has_next"
    case hasPrev = "has_prev"
    case offset, limit, pages
  }
}

