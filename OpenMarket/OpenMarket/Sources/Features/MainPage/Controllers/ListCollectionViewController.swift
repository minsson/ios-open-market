//
//  OpenMarket - ItemListPageViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit

final class ListCollectionViewController: UIViewController, ItemDataHandling {
    
    // MARK: - Properties
    
    typealias ItemSnapShot = NSDiffableDataSourceSnapshot<Section, ItemListPage.Item>
    
    lazy var dataSource = configureListDataSource()
    
    var itemListPage: ItemListPage?
    
    // MARK: - UI Properties
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: createListLayout()
        )
        collectionView.delegate = self
        return collectionView
    }()
    
    // MARK: - Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpCollectionViewLayout()
        dataSource = configureListDataSource()
        
        createNetworkRequest(using: HTTPMethod.get)
    }
    
}

// MARK: - Private Actions

private extension ListCollectionViewController {
    
    func setUpCollectionViewLayout() {
        self.view.addSubview(collectionView)
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            
            collectionView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor
            ),
            
            collectionView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor
            ),
            
            collectionView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor
            )
        ])
    }
    
    func createListLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupsize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(1/4)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupsize,
            subitem: item,
            count: 1
        )
        
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    func configureListDataSource()
    ->  UICollectionViewDiffableDataSource<Section, ItemListPage.Item> {
        let registration = UICollectionView.CellRegistration<ItemListCollectionViewCell, ItemListPage.Item>.init { cell, _, item in
            cell.receiveData(item)
        }
        
        return UICollectionViewDiffableDataSource<Section, ItemListPage.Item> (
            collectionView: collectionView
        ) { collectionView, indexPath, item -> UICollectionViewCell? in
            let cell = collectionView.dequeueConfiguredReusableCell(
                using: registration,
                for: indexPath,
                item: item
            )
            
            return cell
        }
    }

}


extension ListCollectionViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        let itemDetailViewController = ItemDetailViewController()
        itemDetailViewController.setupProductID(productID: String(item.id))
    
        self.navigationController?.pushViewController(itemDetailViewController, animated: true)
    }
    
}
