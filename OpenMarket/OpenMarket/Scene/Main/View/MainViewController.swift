//
//  OpenMarket - MainViewController.swift
//  Created by Red, Mino.
//  Copyright © yagom. All rights reserved.
// 

import UIKit

final class MainViewController: UIViewController, NotificationObservable {
    private enum Constants {
        static let requestErrorAlertTitle = "오류 발생"
        static let requestErrorAlertConfirmTitle = "다시요청하기"
        static let requestDetailErrorAlertConfirmTitle = "확인"
    }
    
    private lazy var mainView = MainView(frame: view.bounds)
    private let viewModel = MainViewModel()
    
    override func loadView() {
        super.loadView()
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationItem()
        setUpCollectionView()
        setUpSegmentControl()
        setUpViewModel()
        viewModel.requestProducts()
        setUpNotification()
    }
}

// MARK: SetUp Method

extension MainViewController {
    private func setUpNavigationItem() {
        navigationItem.titleView = mainView.segmentControl
        navigationItem.rightBarButtonItem = mainView.addButton
        mainView.addButton.target = self
        mainView.addButton.action = #selector(addButtonDidTap)
    }
    
    private func setUpCollectionView() {
        mainView.collectionView.delegate = self
        mainView.collectionView.refreshControl = UIRefreshControl()
        mainView.collectionView.refreshControl?.addTarget(self, action: #selector(refreshControlValueChanged), for: .valueChanged)
    }
    
    private func setUpSegmentControl() {
        mainView.segmentControl.addTarget(self, action: #selector(segmentControlValueChanged), for: .valueChanged)
    }
    
    private func setUpViewModel() {
        viewModel.datasource = makeDataSource()
        viewModel.snapshot = viewModel.makeSnapshot()
        viewModel.delegate = self
    }
    
    private func setUpNotification() {
        registerNotification { [weak self] in
            self?.viewModel.resetItemList()
        }
    }
}

// MARK: Objc Method

extension MainViewController {
    @objc private func refreshControlValueChanged() {
        viewModel.resetItemList()
        mainView.collectionView.refreshControl?.endRefreshing()
    }
    
    @objc private func segmentControlValueChanged() {
        mainView.setUpLayout(segmentIndex: mainView.segmentControl.selectedSegmentIndex)
    }
    
    @objc private func addButtonDidTap() {
        let registerViewController = RegisterViewController()
        registerViewController.modalPresentationStyle = .fullScreen
        self.present(registerViewController, animated: true)
    }
}

// MARK: Datasource

extension MainViewController {
    private func makeDataSource() -> UICollectionViewDiffableDataSource<MainViewModel.Section, ProductDetail> {
        let dataSource = UICollectionViewDiffableDataSource<MainViewModel.Section, ProductDetail>(
            collectionView: mainView.collectionView,
            cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell in
                switch self.mainView.layoutStatus {
                case .list:
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: ProductsListCell.identifier,
                        for: indexPath) as? ProductsListCell else {
                        return UICollectionViewCell()
                    }
                    
                    cell.configure(data: item, apiService: self.viewModel.productsAPIService)
                    
                    return cell
                    
                case .grid:
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: ProductsGridCell.identifier,
                        for: indexPath) as? ProductsGridCell else {
                        return UICollectionViewCell()
                    }
                    
                    cell.configure(data: item, apiService: self.viewModel.productsAPIService)
                    
                    return cell
                }
            })
        return dataSource
    }
}

// MARK: AlertDelegate

extension MainViewController: AlertDelegate {
    func showAlertRequestError(with error: Error) {
        self.alertBuilder
            .setTitle(Constants.requestErrorAlertTitle)
            .setMessage(error.localizedDescription)
            .setConfirmTitle(Constants.requestErrorAlertConfirmTitle)
            .setConfirmHandler {
                self.viewModel.requestProducts()
            }
            .showAlert()
    }
}

// MARK: UICollectionViewDelegate

extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard viewModel.productList?.hasNext == true else {
            return
        }
        
        guard let snapshot = viewModel.snapshot else {
            return
        }
        
        if indexPath.row >= snapshot.numberOfItems - 3 {
            viewModel.requestProducts()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let id = viewModel.snapshot?.itemIdentifiers[safe: indexPath.item]?.id {
            DispatchQueue.main.async {
                let modifyViewController = DetailViewController(id: id)
                self.navigationController?.pushViewController(modifyViewController, animated: true)
            }
        }
    }
}
