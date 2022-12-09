//
//  ConfigurableCollectionViewController.swift
//  OpenMarket
//
//  Created by minsson, yeton on 2022/08/03.
//

import UIKit

protocol ItemDataHandling: AnyObject {
    
    // MARK: - Properties
    
    var collectionView: UICollectionView { get set }
    var dataSource: UICollectionViewDiffableDataSource<Section, ItemListPage.Item> { get set }
    var itemListPage: ItemListPage? { get set }
    
    typealias SnapShot = NSDiffableDataSourceSnapshot<Section, ItemListPage.Item>
}

// MARK: - Actions

extension ItemDataHandling {
    func createNetworkRequest(using httpMethod: HTTPMethod) {
        
        guard let urlRequest = OpenMarketAPIRequestGet().urlRequest else {
            return
        }
        
        NetworkManager.execute(
            urlRequest
        ) { (result: Result<Data, NetworkingError>) in
            switch result {
            case .success(let data):
                self.itemListPage = NetworkManager.parse(
                    data,
                    into: ItemListPage.self
                )
                
                guard let itemListPage = self.itemListPage else {
                    return
                }
                
                DispatchQueue.main.async { [self] in
                    var itemSnapshot = SnapShot()
                    itemSnapshot.appendSections([.main])
                    itemSnapshot.appendItems(itemListPage.items)
                    
                    dataSource.apply(
                        itemSnapshot,
                        animatingDifferences: false
                    )
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
