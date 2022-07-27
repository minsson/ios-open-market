//
//  OpenMarket - ItemListPageViewController.swift
//  Created by yagom.
//  Copyright © yagom. All rights reserved.
//

import UIKit

final class ItemListPageViewController: UIViewController {
    
    // MARK: - Properties

    @IBOutlet weak var itemCollectionView: UICollectionView!
    
    enum Section: CaseIterable {
        case main
    }
    
    var dataSource: UICollectionViewDiffableDataSource<Section, ItemListPage.Item>!
    var snapshot = NSDiffableDataSourceSnapshot<Section, ItemListPage.Item>()
    
    private var itemListPage: ItemListPage?
    private lazy var request = Path.products + queryString
    private let queryString = QueryCharacter.questionMark + QueryKey.pageNumber + QueryValue.pageNumber + QueryCharacter.ampersand + QueryKey.itemsPerPage + QueryValue.itemsPerPage
    
    // MARK: - UI Components
    
    private let segmentedControl: UISegmentedControl = {
        let segmentedControl = UIKit.UISegmentedControl(items: ["LIST", "GRID"])
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.layer.borderColor = UIColor.systemBlue.cgColor
        segmentedControl.layer.borderWidth = 1.0
        return segmentedControl
    }()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        itemCollectionView.register(ItemListCollectionViewCell.self, forCellWithReuseIdentifier: "ItemListCollectionViewCell")

        setLayout()
        getProductList()
        touchSegmentedControl()
        configureDataSource()
    }
}

// MARK: - Private Actions

private extension ItemListPageViewController {
    func setLayout() {
        navigationItem.titleView = segmentedControl
        itemCollectionView.collectionViewLayout = createListLayout() // 처음 화면 레이아웃 잡아주기
    }
    
    private func touchSegmentedControl() {
        segmentedControl.addTarget(self, action: #selector(selectLayout), for: .valueChanged)
    }
    
    @objc private func selectLayout(segmentedControl: UISegmentedControl) {
        if segmentedControl.selectedSegmentIndex == 0 {
            itemCollectionView.collectionViewLayout = createListLayout()
        } else {
            itemCollectionView.collectionViewLayout = createGridLayout()
        }
    }
}

// MARK: - layout
private extension ItemListPageViewController {
    func createListLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupsize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalWidth(1/3))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupsize,
                                                       subitem: item,
                                                       count: 1)
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    func createGridLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupsize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalWidth(1/3))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupsize,
                                                       subitem: item,
                                                       count: 2)
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
}

// MARK: - SnapShot, DataSource

extension ItemListPageViewController {
    func getProductList() {
        NetworkManager.performRequestToAPI(from: HostAPI.openMarket.url, with: request) { (result: Result<Data, NetworkingError>) in
            
            switch result {
            case .success(let data):
                self.itemListPage = NetworkManager.parse(data, into: ItemListPage.self)
                
                self.snapshot.appendSections([.main])
                self.snapshot.appendItems(self.itemListPage!.items)
                self.dataSource.apply(self.snapshot, animatingDifferences: false)
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, ItemListPage.Item> (collectionView: itemCollectionView) { [self]
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: ItemListPage.Item) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemListCollectionViewCell", for: indexPath) as? ItemListCollectionViewCell else {
                return ItemListCollectionViewCell()
            }
            
            if let item = itemListPage?.items[indexPath.item] {
                cell.receiveData(item)
            }
            
//            if segmentedControl.selectedSegmentIndex == 0 {
//                cell.transferCell(flag: 0)
//            } else {
//                cell.transferCell(flag: 1)
//            }
//
            
            return cell
        }
    }
}

// MARK: - Private Enums

private extension ItemListPageViewController {
    enum QueryValue {
        static var pageNumber = "1"
        static var itemsPerPage = "100"
    }
    
    enum QueryKey {
        static var pageNumber = "page_no="
        static var itemsPerPage = "items_per_page="
    }
    
    enum Path {
        static var products = "/api/products"
    }
    
    enum QueryCharacter {
        static var questionMark = "?"
        static var ampersand = "&"
    }
}
