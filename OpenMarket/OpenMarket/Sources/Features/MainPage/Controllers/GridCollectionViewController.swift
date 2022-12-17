//
//  GridCollectionViewController.swift
//  OpenMarket
//
//  Created by minsson, yeton on 2022/08/03.
//

import UIKit

final class GridCollectionViewController: UIViewController, ItemDataHandling {
    
    // MARK: - Properties
    
    typealias ItemSnapShot = NSDiffableDataSourceSnapshot<Section, ItemListPage.Item>
    
    lazy var dataSource = configureGridDataSource()
    
    var itemListPage: ItemListPage?
    
    // MARK: - UI Properties
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: createGridLayout()
        )
        collectionView.delegate = self
        return collectionView
    }()
    
    // MARK: - Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpCollectionViewLayout()
        dataSource = configureGridDataSource()
        
        createNetworkRequest(using: HTTPMethod.get)
    }
    
}

// MARK: - Private Actions

private extension GridCollectionViewController {
    
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
    
    func createGridLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        item.contentInsets = .init(
            top: 4,
            leading: 4,
            bottom: 4,
            trailing: 4
        )
        
        let groupsize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(2/3)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupsize,
            subitem: item,
            count: 2
        )
        
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    func configureGridDataSource()
    ->  UICollectionViewDiffableDataSource<Section, ItemListPage.Item> {
        let registration = UICollectionView.CellRegistration<ItemGridCollectionViewCell, ItemListPage.Item>.init { cell, _, item in
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

extension GridCollectionViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        let itemDetailViewController = ItemDetailViewController()
        itemDetailViewController.setupProductID(productID: String(item.id))
    
        self.navigationController?.pushViewController(itemDetailViewController, animated: true)
    }
    
}
