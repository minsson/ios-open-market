//
//  OpenMarket - MainViewController.swift
//  Created by Red, Mino.
//  Copyright © yagom. All rights reserved.
// 

import UIKit

final class MainViewController: UIViewController {
    private enum Constants {
        static let itemsCountPerPage = 20
        static let requestErrorAlertTitle = "오류 발생"
        static let requestErrorAlertConfirmTitle = "다시요청하기"
        static let loadImageErrorAlertConfirmTitle = "확인"
    }
    
    private enum Section {
        case main
    }
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    private let productsAPIServie = APIProvider<Products>()
    
    private lazy var mainView = MainView(frame: view.bounds)
    private lazy var datasource = makeDataSource()
    private lazy var imageCacheManager = ImageCacheManager<Products>(apiService: productsAPIServie)
        
    private var products: Products?
    private var items: [Item] = []
    private var currentPage = 1
    
    override func loadView() {
        super.loadView()
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationItem()
        setUpCollectionView()
        setUpSegmentControl()
        requestProducts(by: currentPage)
    }
 }

// MARK: SetUp Method

extension MainViewController {
    private func setUpNavigationItem() {
        navigationItem.titleView = mainView.segmentControl
        navigationItem.rightBarButtonItem = mainView.addButton
    }
    
    private func setUpCollectionView() {
        mainView.collectionView.delegate = self
        mainView.collectionView.register(
            ListCollectionViewCell.self,
            forCellWithReuseIdentifier: ListCollectionViewCell.identifier
        )
        
        mainView.collectionView.register(
            GridCollectionViewCell.self,
            forCellWithReuseIdentifier: GridCollectionViewCell.identifier
        )
    }
    
    private func setUpSegmentControl() {
        mainView.segmentControl.addTarget(self, action: #selector(changeLayout), for: .valueChanged)
    }
    
    @objc private func changeLayout() {
        mainView.setUpLayout(segmentIndex: mainView.segmentControl.selectedSegmentIndex)
    }
}

// MARK: API Request Method

extension MainViewController {
    private func requestProducts(by page: Int) {
        let endpoint = EndPointStorage.productsList(pageNumber: page, perPages: Constants.itemsCountPerPage)
        
        productsAPIServie.request(with: endpoint) { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let products):
                self.products = products
                self.items.append(contentsOf: products.items)
                self.applySnapshot()
            case .failure(let error):
                DispatchQueue.main.async {
                    self.alertBuilder
                        .setTitle(Constants.requestErrorAlertTitle)
                        .setMessage(error.localizedDescription)
                        .setConfirmTitle(Constants.requestErrorAlertConfirmTitle)
                        .setConfirmHandler {
                            self.requestProducts(by: self.currentPage)
                        }
                        .showAlert()
                }
            }
        }
    }
    
    private func loadImage(url: URL, completion: @escaping (UIImage) -> Void) {
        self.imageCacheManager.loadImage(url: url) { result in
            switch result {
            case .success(let image):
                completion(image)
            case .failure(let error):
                DispatchQueue.main.async {
                    self.alertBuilder
                        .setTitle(Constants.requestErrorAlertTitle)
                        .setMessage(error.localizedDescription)
                        .setConfirmTitle(Constants.loadImageErrorAlertConfirmTitle)
                        .showAlert()
                }
            }
        }
    }
}

// MARK: Datasource && Snapshot

extension MainViewController {
    private func makeDataSource() -> DataSource {
        let dataSource = DataSource(
            collectionView: mainView.collectionView,
            cellProvider: { (collectionView, indexPath, item) ->
                UICollectionViewCell in
                switch self.mainView.layoutStatus {
                case .list:
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: ListCollectionViewCell.identifier,
                        for: indexPath) as? ListCollectionViewCell else {
                        return UICollectionViewCell()
                    }
    
                    self.loadImage(url: item.thumbnail) { image in
                        DispatchQueue.main.async {
                            cell.updateImage(image: image)
                        }
                    }
                    
                    cell.updateLabel(data: item)
                    return cell
                
                case .grid:
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: GridCollectionViewCell.identifier,
                        for: indexPath) as? GridCollectionViewCell else {
                        return UICollectionViewCell()
                    }
                    
                    self.loadImage(url: item.thumbnail) { image in
                        DispatchQueue.main.async {
                            cell.updateImage(image: image)
                        }
                    }
                    
                    cell.updateLabel(data: item)
                    return cell
                }
            })
        return dataSource
    }
    
    private func applySnapshot() {
        DispatchQueue.main.async {
            var snapshot = Snapshot()
            snapshot.appendSections([.main])
            snapshot.appendItems(self.items, toSection: .main)
            self.datasource.apply(snapshot)
        }
    }
}

extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard products?.hasNext == true else {
            return
        }
        
        if indexPath.row >= items.count - 3 {
            currentPage += 1
            requestProducts(by: currentPage)
        }
    }
}

