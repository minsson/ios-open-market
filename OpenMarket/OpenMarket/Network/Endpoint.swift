//
//  Endpoint.swift
//  OpenMarket
//
//  Created by marlang, Taeangel on 2022/05/12.
//
import UIKit

enum Endpoint {
    case healthChecker
    case productList(page: Int, itemsPerPage: Int)
    case detailProduct(id: Int)
    case productRegistration
}

extension Endpoint {
    var url: URL? {
        switch self {
        case .healthChecker:
            return .makeForEndpoint("healthChecker")
        case .productList(let page, let itemsPerPage):
            return .makeForEndpoint("api/products?page_no=\(page)&items_per_page=\(itemsPerPage)")
        case .detailProduct(let id):
            return .makeForEndpoint("api/products/\(id)")
        case .productRegistration:
            return .makeForEndpoint("api/products")
        }
    }
}

private extension URL {
    static let baseURL = "https://market-training.yagom-academy.kr/"

    static func makeForEndpoint(_ endpoint: String) -> URL? {
        return URL(string: baseURL + endpoint)
    }
}
