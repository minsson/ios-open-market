//
//  OpenMarket - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit

final class OpenMarketViewController: UIViewController {
    private let segmentControl = SegmentControl(items: LayoutType.inventory)
    private var layoutType = LayoutType.list
    private var collectionView: UICollectionView?
    private var network: URLSessionProvider<ProductList>?
    private var productList: [Product]? {
        didSet {
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        network = URLSessionProvider()
        fetchData(from: .productList(page: 1, itemsPerPage: 110))
        setupCollectionView()
        setupSegmentControl()
    }
    
    private func fetchData(from: Endpoint) {
        network?.fetchData(from: from, completionHandler: { result in
            switch result {
            case .success(let data):
                self.productList = data.pages
            case .failure(_):
                return
            }
        })
    }
    
    private func setupCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 10
        
        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: flowLayout)
        view.addSubview(collectionView ?? UICollectionView())
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.register(ListCell.self, forCellWithReuseIdentifier: ListCell.identifier)
        collectionView?.register(GridCell.self, forCellWithReuseIdentifier: GridCell.identifier)
    }
    
    private func setupSegmentControl() {
        self.navigationItem.titleView = segmentControl
        segmentControl.addTarget(self, action: #selector(didChangeSegment), for: .valueChanged)
    }
    
    @objc private func didChangeSegment(_ sender: UISegmentedControl) {
        
        
        if let currentLayout = LayoutType(rawValue: sender.selectedSegmentIndex) {
            layoutType = currentLayout
        }
        
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
    }
}

extension OpenMarketViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
        switch layoutType {
        case .list:
            return CGSize(width: view.frame.width, height: view.frame.height / 14)
        case .grid:
            return CGSize(width: view.frame.width / 2.2, height: view.frame.height / 3)
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        
        switch layoutType {
        case .list:
            return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 15)
        case .grid:
            return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        }
    }
}

extension OpenMarketViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        guard let product = productList?[indexPath.item] else {
            return UICollectionViewCell()
        }
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: layoutType.cell.identifier,
            for: indexPath) as? CustomCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(data: product)
        
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return productList?.count ?? .zero
    }
}
