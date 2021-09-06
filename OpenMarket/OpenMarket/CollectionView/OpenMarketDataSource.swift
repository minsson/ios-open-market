//
//  File.swift
//  OpenMarket
//
//  Created by tae hoon park on 2021/09/07.
//

import UIKit

struct MarketLayout {
    var type: Mode = .grid
    
    enum Mode {
        case grid
        case list
    }
}

class OpenMarketDataSource: NSObject {
    private var productList: [Product] = []
    private let networkManager = NetworkManager()
    private let parsingManager = ParsingManager()
    private let pageNumber = 1
    var viewMode: MarketLayout = MarketLayout.init(type: .list)
}

extension OpenMarketDataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        productList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if viewMode.type == .list {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductCell.listIdentifier, for: indexPath) as? ProductCell else {
                return  UICollectionViewCell()
            }
            let productForItem = productList[indexPath.item]
            cell.imageConfigure(product: productForItem)
            cell.textConfigure(product: productForItem)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductCell.gridItentifier, for: indexPath) as? ProductCell else {
                return  UICollectionViewCell()
            }
            let productForItem = productList[indexPath.item]
            cell.imageConfigure(product: productForItem)
            cell.textConfigure(product: productForItem)
            return cell
        }
        
    }
    
    func requestProductList(collectionView: UICollectionView) {
        self.networkManager.commuteWithAPI(api: GetItemsAPI(page: pageNumber)) { result in
            if case .success(let data) = result {
                guard let product = try? self.parsingManager.decodedJSONData(type: ProductCollection.self, data: data) else {
                    return
                }
                self.productList.append(contentsOf: product.items)
                
                DispatchQueue.main.async {
                    collectionView.reloadData()
                }
            }
        }
    }
}
