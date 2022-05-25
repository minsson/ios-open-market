//
//  OpenMarket - MainViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit

@available(iOS 14.0, *)
class MainViewController: UIViewController {
    enum Section {
        case main
    }
    private var isFirstSnapshot = true
    private var collectionView: UICollectionView?
    private var listLayout: UICollectionViewLayout?
    private var gridLayout: UICollectionViewLayout?
    private var listCellRegisteration: UICollectionView.CellRegistration<ProductListCell, Product>?
    private var gridCellRegisteration: UICollectionView.CellRegistration<ProductGridCell, Product>?
    private var dataSource: UICollectionViewDiffableDataSource<Section, Product>?
    private var currentSnapshot: NSDiffableDataSourceSnapshot<Section, Product>?
    private var baseView = BaseView()
    private let dataProvider = DataProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyListLayout()
        applyGridLayout()
        registerCell()
        guard let listLayout = listLayout else {
            return
        }
        configureHierarchy(collectionViewLayout: listLayout)
        configureDataSource()
        setUpNavigationItem()
        dataProvider.fetchData() { products in
            DispatchQueue.main.async { [self] in
                updateSnapshot(products: products)
            }
        }
        collectionView?.delegate = self
    }
    
    private func setUpNavigationItem() {
        setUpSegmentation()
        navigationItem.titleView = baseView.segmentedControl
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "+", style: .plain, target: self, action: #selector(registerProduct))
    }
    
    private func setUpSegmentation() {
        baseView.segmentedControl.setWidth(view.bounds.width * 0.18 , forSegmentAt: 0)
        baseView.segmentedControl.setWidth(view.bounds.width * 0.18, forSegmentAt: 1)
        baseView.segmentedControl.addTarget(self, action: #selector(switchCollectionViewLayout), for: .valueChanged)
    }
    
    @objc private func switchCollectionViewLayout() {
        switch baseView.segmentedControl.selectedSegmentIndex {
        case 0:
            guard let listLayout = listLayout else {
                return
            }
            collectionView?.setCollectionViewLayout(listLayout, animated: false)
        case 1:
            guard let gridLayout = gridLayout else {
                return
            }
            collectionView?.setCollectionViewLayout(gridLayout, animated: false)
        default:
            break
        }
        self.configureDataSource()
        dataSource?.apply(currentSnapshot ?? NSDiffableDataSourceSnapshot())
    }
    
    @objc private func registerProduct() {
        present(RegisterProductViewController(), animated: false)
    }
}

@available(iOS 14.0, *)
extension MainViewController {
    
    private func configureHierarchy(collectionViewLayout: UICollectionViewLayout) {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        view.addSubview(collectionView ?? UICollectionView())
        layoutCollectionView()
    }
    
    private func applyGridLayout() {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.3))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        group.interItemSpacing = .fixed(10)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        section.interGroupSpacing = 10
        let layout = UICollectionViewCompositionalLayout(section: section)
        gridLayout = layout
    }
    
    private func applyListLayout() {
        let configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        listLayout = layout
    }
    
    private func layoutCollectionView() {
        guard let collectionView = collectionView else {
            return
        }
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func registerCell() {
        listCellRegisteration = UICollectionView.CellRegistration<ProductListCell, Product> { [self] (cell, indexPath, item) in
            guard let sectionIdentifier = currentSnapshot?.sectionIdentifiers[indexPath.section] else {
                return
            }
            let numberOfItemsInSection = currentSnapshot?.numberOfItems(inSection: sectionIdentifier)
            let isLastCell = indexPath.item + 1 == numberOfItemsInSection
            cell.seperatorView.isHidden = isLastCell
            
            cell.update(newItem: item)
        }
        
        gridCellRegisteration = UICollectionView.CellRegistration<ProductGridCell, Product> { (cell, indexPath, item) in
            cell.update(newItem: item)
        }
    }
    
    private func configureDataSource() {
        guard let collectionView = collectionView,
              let listCellRegisteration = listCellRegisteration,
              let gridCellRegisteration = gridCellRegisteration else {
            return
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Product>(collectionView: collectionView) { [self] (collectionView, indexPath, itemIdentifier) -> UICollectionViewCell? in
            if baseView.segmentedControl.selectedSegmentIndex == 0 {
                return collectionView.dequeueConfiguredReusableCell(using: listCellRegisteration, for: indexPath, item: itemIdentifier)
            } else {
                return collectionView.dequeueConfiguredReusableCell(using: gridCellRegisteration, for: indexPath, item: itemIdentifier)
            }
        }
    }
    
    private func updateSnapshot(products: [Product]) {
        currentSnapshot = dataSource?.snapshot()
        if isFirstSnapshot {
            currentSnapshot?.appendSections([.main])
            isFirstSnapshot = false
        }
        currentSnapshot?.appendItems(products)
        dataSource?.apply(currentSnapshot ?? NSDiffableDataSourceSnapshot())
        
    }
}

@available(iOS 14.0, *)
extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        dataProvider.fetchData() { products in
            DispatchQueue.main.async { [self] in
                updateSnapshot(products: products)
            }
        }
    }
}
