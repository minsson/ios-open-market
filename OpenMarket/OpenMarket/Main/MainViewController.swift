//
//  OpenMarket - MainViewController.swift
//  Created by yagom. 
//  Copyright dudu, safari All rights reserved.
// 

import UIKit

private enum Constant {
    static let requestItemCount = 20
}

final class MainViewController: UIViewController {
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Product>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Product>
    
    private var networkManager = NetworkManager<ProductList>()
    private let cellLayoutSegmentControl = UISegmentedControl(items: ProductCollectionViewLayoutType.names)
    
    private var mainView: MainView?
    private var dataSource: DataSource?
    private var snapshot: Snapshot?
    
    private var pageNumber = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureNavigationBar()
        configureRefreshControl()
        requestData(pageNumber: pageNumber)
    }
    
    override func loadView() {
        super.loadView()
        mainView = MainView(frame: view.bounds)
        view = mainView
    }
    
    private func configureView() {
        mainView?.backgroundColor = .systemBackground
        configureCollectionView()
        configureSegmentControl()
    }
    
    private func configureNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonDidTapped))
        navigationItem.titleView = cellLayoutSegmentControl
    }
    
    private func configureCollectionView() {
        mainView?.collectionView.register(ProductGridCell.self, forCellWithReuseIdentifier: ProductGridCell.identifier)
        mainView?.collectionView.register(ProductListCell.self, forCellWithReuseIdentifier: ProductListCell.identifier)
        mainView?.collectionView.delegate = self
        mainView?.collectionView.prefetchDataSource = self
        dataSource = makeDataSource()
        snapshot = makeSnapshot()
    }
    
    private func configureRefreshControl() {
        mainView?.collectionView.refreshControl = UIRefreshControl()
        mainView?.collectionView.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
    }
    
    private func configureSegmentControl() {
        cellLayoutSegmentControl.setTitleTextAttributes([.foregroundColor : UIColor.white], for: .selected)
        cellLayoutSegmentControl.setTitleTextAttributes([.foregroundColor : UIColor.systemBlue], for: .normal)
        cellLayoutSegmentControl.selectedSegmentTintColor = .systemBlue
        cellLayoutSegmentControl.setWidth(view.bounds.width * 0.2, forSegmentAt: 0)
        cellLayoutSegmentControl.setWidth(view.bounds.width * 0.2, forSegmentAt: 1)
        cellLayoutSegmentControl.layer.borderWidth = 1.0
        cellLayoutSegmentControl.layer.borderColor = UIColor.systemBlue.cgColor
        cellLayoutSegmentControl.selectedSegmentIndex = 0
        cellLayoutSegmentControl.addTarget(self, action: #selector(segmentValueDidChanged), for: .valueChanged)
    }
}

// MARK: - Action Method

extension MainViewController {
    @objc private func addButtonDidTapped() {
        let registerViewController = RegisterViewController()
        registerViewController.delegate = self
        
        let registerNavigationController = UINavigationController(rootViewController: registerViewController)
        registerNavigationController.modalPresentationStyle = .fullScreen
        
        present(registerNavigationController, animated: true)
    }
    
    @objc private func segmentValueDidChanged() {
        mainView?.changeLayout(index: cellLayoutSegmentControl.selectedSegmentIndex)
        mainView?.collectionView.reloadData()
    }
    
    @objc private func handleRefreshControl() {
        resetData()
    }
}

// MARK: - NetWork Method

extension MainViewController {
    private func requestData(pageNumber: Int) {
        let endPoint = EndPoint.requestList(page: pageNumber, itemsPerPage: Constant.requestItemCount)
        
        networkManager.request(endPoint: endPoint) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                guard let result = data.products else { return }
                
                self.applySnapshot(products: result)
                
                DispatchQueue.main.async {
                    self.mainView?.indicatorView.stop()
                    self.mainView?.collectionView.refreshControl?.stop()
                }
            case .failure(_):
                AlertDirector(viewController: self).createErrorAlert(message: "데이터를 불러오지 못했습니다.")
            }
        }
    }
    
    private func resetData() {
        pageNumber = 1
        snapshot = makeSnapshot()

        ImageManager.shared.clearCache()
        requestData(pageNumber: pageNumber)
    }
}

//MARK: - CollectionView Delegate

extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let product = snapshot?.itemIdentifiers[indexPath.item] else { return }
        
        let editViewController = EditViewController(product: product)
        editViewController.delegate = self

        navigationController?.pushViewController(editViewController, animated: true)
    }
}

//MARK: - CollectionView DataSource

extension MainViewController {
    private func makeDataSource() -> DataSource? {
        guard let mainView = mainView else { return nil }
        
        let dataSource = DataSource(collectionView: mainView.collectionView) { [weak self] collectionView, indexPath, itemIdentifier in
            guard let self = self else { return nil }
            
            guard let cellType = ProductCollectionViewLayoutType(rawValue: self.cellLayoutSegmentControl.selectedSegmentIndex)?.cellType else {
                return nil
            }
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellType.identifier, for: indexPath) as? ProductCell else {
                return cellType.init()
            }
            
            cell.configure(data: itemIdentifier)
            
            return cell
        }
        
        return dataSource
    }
     
    private func makeSnapshot() -> Snapshot? {
        var snapshot = dataSource?.snapshot()
        snapshot?.deleteAllItems()
        snapshot?.appendSections([.main])
        
        return snapshot
    }
    
    private func applySnapshot(products: [Product]) {
        DispatchQueue.main.async { [self] in
            snapshot?.appendItems(products)
            
            guard let snapshot = snapshot else { return }
            
            dataSource?.apply(snapshot, animatingDifferences: false)
        }
    }
}

//MARK: - CollectionView DataSourcePrefetching

extension MainViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        prefetchData(indexPaths)
    }
    
    private func prefetchData(_ indexPaths: [IndexPath]) {
        guard let indexPath = indexPaths.last else { return }
        
        let section = indexPath.row / Constant.requestItemCount
        
        if section + 1 == pageNumber {
            pageNumber += 1
            requestData(pageNumber: pageNumber)
        }
    }
}

//MARK: - ProductViewController Delegate

extension MainViewController: ProductViewControllerDelegate {
    func refreshData() {
        resetData()
    }
}
