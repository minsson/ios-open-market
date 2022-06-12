//
//  OpenMarket - ViewController.swift
//  Created by Grumpy, OneTool
//  Copyright © yagom. All rights reserved.
// 

import UIKit

protocol ListUpdateDelegate: NSObject {
    func refreshProductList()
}

enum ArrangeMode: String, CaseIterable {
    case list = "LIST"
    case grid = "GRID"
    
    var value: Int {
        switch self {
        case .list:
            return 0
        case .grid:
            return 1
        }
    }
}

extension API {
    static let numbers: Int = 1
    static let pages: Int = 100
}

final class MainViewController: UIViewController {
    private let arrangeModeSegmentedControl = UISegmentedControl(items: ArrangeMode.allCases.map {
        $0.rawValue
    })
    private enum Reloadable {
        case able
        case disable
    }
    private var currentArrangeMode: ArrangeMode = .list
    private var reloadableState: Reloadable = .able
    private var productsWillShow: [Product] = []
    private var products: [Product] = [] {
        didSet {
            productsWillShow = products
        }
    }
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: listLayout)
    private lazy var activityIndicator: UIActivityIndicatorView = {
        createActivityIndicator()
    }()
    private var timer: DispatchSourceTimer?
    private lazy var searchBar: UISearchBar = {
       let searchBar = UISearchBar()
        searchBar.searchBarStyle = .default
        searchBar.placeholder = OpenMarketConstant.productName
        searchBar.sizeToFit()
        searchBar.isTranslucent = false
        searchBar.backgroundImage = UIImage()
        
        return searchBar
    }()
    private lazy var newProductButton: UIButton = {
        let button = UIButton()
        button.setTitle("새 게시물", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 10
        button.backgroundColor = .white
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 1.0
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.shadowColor = UIColor.gray.cgColor
        button.isHidden = true
        button.addTarget(self, action: #selector(reloadAction), for: .touchUpInside)
        
        return button
    }()
}

extension MainViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationItems()
        setUpCollectionViewCellRegister()
        self.view.addSubview(searchBar)
        self.view.addSubview(collectionView)
        self.view.addSubview(newProductButton)
        self.view.bringSubviewToFront(newProductButton)
        self.view.addSubview(activityIndicator)
        self.activityIndicator.startAnimating()
        requestProductListData()
        let backButton = UIBarButtonItem(title: OpenMarketConstant.cancel, style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backButton
        
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        setUpNewProductButtonConstraints()
        setUpSegmentedControlLayout()
        setUpCollectionViewConstraints()
        defineCollectionViewDelegate()
        defineSearchBarDelegate()
        setUpSearchBarConstraints()
        setUpInitialState()
        
        startTimer()
    }
    
    @objc func pullToRefresh() {
        self.collectionView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.refreshProductList()
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
}

// MARK: - Delegate
extension MainViewController {
    private func defineCollectionViewDelegate() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func defineSearchBarDelegate() {
        searchBar.delegate = self
    }
}

// MARK: - Delegate Method
extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productsWillShow.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch self.currentArrangeMode {
        case .list:
            return configureListCell(indexPath: indexPath)
        case .grid:
            return configureGridCell(indexPath: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let detailViewController = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else {
            return
        }
        detailViewController.delegate = self
        let id = productsWillShow[indexPath.row].id
        RequestAssistant.shared.requestDetailAPI(productId: id) { result in
            switch result {
            case .success(let data):
                detailViewController.product = data
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(detailViewController, animated: true)
                }
            case .failure(_):
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.showAlert(title: OpenMarketConstant.loadFail)
                }
            }
        }
    }
}

extension MainViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        reloadableState = .disable
        pauseTimer()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        reloadableState = .able
        resumeTimer()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if products.count != productsWillShow.count {
            searchBar.text = nil
            productsWillShow = products
            collectionView.reloadData()
        }
        searchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        productsWillShow = products
        if searchText.count > 0 {
            let productsForSearch = products.filter({
                $0.name.contains(searchText)
            })
            productsWillShow = productsForSearch
        }
        collectionView.reloadData()
    }
}

// MARK: - Private Method
private extension MainViewController {
    private func setUpNavigationItems() {
        let plusButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showUpRegisterView))
        self.navigationItem.titleView = arrangeModeSegmentedControl
        self.navigationItem.rightBarButtonItem = plusButton
        self.navigationController?.navigationBar.backgroundColor = .systemGroupedBackground
    }
    
    private func setUpCollectionViewCellRegister() {
        collectionView
            .register(ListCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "listCell")
        collectionView
            .register(GridCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "gridCell")
    }
    
    private func setUpSearchBarConstraints() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        searchBar.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        searchBar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
    }
    
    private func requestProductListData() {
        if reloadableState == .disable {
            return
        }
        RequestAssistant.shared.requestListAPI(pageNumber: API.numbers, itemsPerPage: API.pages) { result in
            switch result {
            case .success(let data):
                self.products = data.pages
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.newProductButton.isHidden = true
                    self.collectionView.reloadData()
                }
            case .failure(_):
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.showAlert(title: OpenMarketConstant.loadFail)
                }
            }
        }
    }
    
    private func setUpSearchBarLayout() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    }
    
    private func setUpSegmentedControlLayout() {
        let normalTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemBlue, .font: UIFont.preferredFont(forTextStyle: .callout)]
        let selectedTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, .font: UIFont.preferredFont(forTextStyle: .callout)]
        
        arrangeModeSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        arrangeModeSegmentedControl.backgroundColor = .white
        arrangeModeSegmentedControl.selectedSegmentTintColor = .systemBlue
        arrangeModeSegmentedControl.setTitleTextAttributes(normalTextAttributes, for: .normal)
        arrangeModeSegmentedControl.setTitleTextAttributes(selectedTextAttributes, for: .selected)
        arrangeModeSegmentedControl.layer.borderColor = UIColor.systemBlue.cgColor
        arrangeModeSegmentedControl.layer.borderWidth = 1.0
        arrangeModeSegmentedControl.layer.cornerRadius = 1.0
        arrangeModeSegmentedControl.layer.masksToBounds = false
        arrangeModeSegmentedControl.setWidth(85, forSegmentAt: 0)
        arrangeModeSegmentedControl.setWidth(85, forSegmentAt: 1)
        arrangeModeSegmentedControl.apportionsSegmentWidthsByContent = true
        arrangeModeSegmentedControl.sizeToFit()
    }
    
    private func setUpNewProductButtonConstraints() {
        newProductButton.translatesAutoresizingMaskIntoConstraints = false
        newProductButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        newProductButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.2).isActive = true
        newProductButton.heightAnchor.constraint(equalTo: newProductButton.widthAnchor, multiplier: 0.3).isActive = true
        newProductButton.topAnchor.constraint(equalTo: self.searchBar.bottomAnchor).isActive = true
    }
    
    @objc private func showUpRegisterView(_ sender: UIBarButtonItem) {
        guard let registerViewController = self.storyboard?.instantiateViewController(withIdentifier: "RegisterViewController") as? RegisterViewController else {
            return
        }
        registerViewController.delegate = self
        self.navigationController?.pushViewController(registerViewController, animated: true)
    }
    
    @objc private func changeArrangement(_ sender: UISegmentedControl) {
        let mode = sender.selectedSegmentIndex
        if mode == ArrangeMode.list.value {
            self.currentArrangeMode = .list
        } else if mode == ArrangeMode.grid.value {
            self.currentArrangeMode = .grid
        }
        switch currentArrangeMode {
        case .list:
            collectionView.setCollectionViewLayout(listLayout, animated: true) { [weak self] _ in self?.collectionView.reloadData() }
            self.collectionView.reloadData()
        case .grid:
            collectionView.setCollectionViewLayout(gridLayout, animated: true) { [weak self] _ in self?.collectionView.reloadData() }
            self.collectionView.reloadData()
        }
    }
    
    private func setUpCollectionViewConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    private func setUpInitialState() {
        arrangeModeSegmentedControl.addTarget(self, action: #selector(changeArrangement(_:)), for: .valueChanged)
        arrangeModeSegmentedControl.selectedSegmentIndex = 0
        self.changeArrangement(arrangeModeSegmentedControl)
    }
    
    private func createActivityIndicator() -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.center = self.view.center
        activityIndicator.color = UIColor.systemBlue
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.medium
        return activityIndicator
    }
    
    private func configureListCell(indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "listCell", for: indexPath) as? ListCollectionViewCell else {
            return ListCollectionViewCell()
        }
        
        cell.accessories = [.disclosureIndicator()]
        cell.configureCellContents(product: productsWillShow[indexPath.row])
        
        return cell
    }
    
    private func configureGridCell(indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gridCell", for: indexPath) as? GridCollectionViewCell else {
            return GridCollectionViewCell()
        }
        
        cell.configureCellContents(product: productsWillShow[indexPath.row])
        
        cell.layer.borderWidth = 1.5
        cell.layer.borderColor = UIColor.systemGray.cgColor
        cell.layer.cornerRadius = 10.0
        
        return cell
    }
    
    private func startTimer() {
        let queue = DispatchQueue(label: "timer", attributes: .concurrent)
        timer?.cancel()
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer?.schedule(deadline: .now(), repeating: .seconds(5))
        timer?.setEventHandler(handler: {
            self.checkIfNewProductExist()
        })
        timer?.resume()
    }
    
    private func pauseTimer() {
        timer?.suspend()
    }
    
    private func resumeTimer() {
        timer?.resume()
    }
    
    private func checkIfNewProductExist() {
        guard let id = products.first?.id else {
            return
        }
        RequestAssistant.shared.requestDetailAPI(productId: (id + 1)) { result in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    self.newProductButton.isHidden = false
                }
            case .failure(.missingDestination):
                return
            case .failure(.invalidData), .failure(.invalidResponse), .failure(.unknownError), .failure(.failDecode):
                DispatchQueue.main.async {
                    self.showAlert(title: OpenMarketConstant.loadFail)
                }
            }
        }
    }
    
    @objc private func reloadAction() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .bottom, animated: true)
        }
        requestProductListData()
    }
}

// MARK: - Collection View Layout
extension MainViewController {
    private var listLayout: UICollectionViewCompositionalLayout {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .plain)
        
        listConfiguration.showsSeparators = true
        listConfiguration.backgroundColor = UIColor.clear
        
        return UICollectionViewCompositionalLayout.list(using: listConfiguration)
    }
    
    private var gridLayout: UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(self.view.frame.height * 0.30))
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        let section = NSCollectionLayoutSection(group: group)
        group.interItemSpacing = .fixed(10)
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}

extension MainViewController: ListUpdateDelegate {
    func refreshProductList() {
        requestProductListData()
    }
}
