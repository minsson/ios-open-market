import UIKit

class MainViewController: UIViewController {
    private let tableViewCellNibName = "ProductsTableViewCell"
    private let collectionViewCellNibName = "ProductsCollectionViewCell"
    private let productRegistrationStoryboardName = "ProductRegistration"
    private let productRegistrationViewControllerIdentifier = "ProductRegistrationViewController"
    private let loadingActivityIndicator = UIActivityIndicatorView()
    private var pageInformation: ProductsList?
    private let jsonParser: JSONParser = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SS"
        let jsonParser = JSONParser(
            dateDecodingStrategy: .formatted(formatter),
            dateEncodingStrategy: .formatted(formatter),
            keyDecodingStrategy: .convertFromSnakeCase,
            keyEncodingStrategy: .convertToSnakeCase
        )
        return jsonParser
    }()
    private lazy var networkTask = NetworkTask(jsonParser: jsonParser)
    private lazy var productsDataSource = ProductsDataSource(networkTask: networkTask)
    
    @IBOutlet private weak var viewSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSegmentedControl()
        changeSubview()
        startActivityIndicator()
        loadProductsList(pageNumber: 1)
    }
    
    private func loadProductsList(pageNumber: Int) {
        networkTask.requestProductList(pageNumber: pageNumber, itemsPerPage: 20) { result in
            switch result {
            case .success(let data):
                guard let productsList: ProductsList = try? self.jsonParser.decode(
                    from: data
                ) else { return }
                self.pageInformation = productsList
                self.productsDataSource.append(contentsOf: productsList.pages)
                DispatchQueue.main.async {
                    self.loadingActivityIndicator.stopAnimating()
                    let view = self.view as? ProductView
                    view?.reloadData()
                }
            case .failure(let error):
                self.showAlert(
                    title: "데이터를 불러오지 못했습니다",
                    message: error.localizedDescription
                )
                self.loadingActivityIndicator.stopAnimating()
            }
        }
    }
    
    private func loadNextPage(ifLastItemAt indexPath: IndexPath) {
        if productsDataSource.isLastIndex(at: indexPath.item),
           pageInformation?.hasNext == true,
           let num = pageInformation?.pageNumber {
            loadProductsList(pageNumber: num + 1)
        }
    }
    
    private func startActivityIndicator() {
        view.addSubview(loadingActivityIndicator)
        loadingActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingActivityIndicator.centerYAnchor.constraint(
            equalTo: view.centerYAnchor
        ).isActive = true
        loadingActivityIndicator.centerXAnchor.constraint(
            equalTo: view.centerXAnchor
        ).isActive = true
        loadingActivityIndicator.startAnimating()
    }
    
    private func setupSegmentedControl() {
        viewSegmentedControl.selectedSegmentTintColor = .systemBlue
        viewSegmentedControl.layer.borderColor = UIColor.systemBlue.cgColor
        viewSegmentedControl.layer.borderWidth = 1.0
        viewSegmentedControl.setTitleTextAttributes(
            [.foregroundColor: UIColor.white],
            for: .selected
        )
        viewSegmentedControl.setTitleTextAttributes(
            [.foregroundColor: UIColor.systemBlue],
            for: .normal
        )
    }
    
    private func changeSubview() {
        guard let selectedSegment = Segement(
            rawValue: viewSegmentedControl.selectedSegmentIndex
        ) else { return }
        self.view = loadView(from: selectedSegment)
    }
    
    private func reloadData() {
        productsDataSource.removeAllProducts()
        loadProductsList(pageNumber: 1)
    }
    
    @IBAction private func segmentedControlChanged(_ sender: UISegmentedControl) {
        changeSubview()
    }
    
    @IBAction func touchAddProductButton(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: productRegistrationStoryboardName, bundle: nil)
        let viewController = storyboard.instantiateViewController(
            identifier: productRegistrationViewControllerIdentifier
        ) { coder in
            let productRegistrationViewController = ProductRegistrationViewController(
                coder: coder,
                isModifying: false,
                networkTask: self.networkTask,
                jsonParser: self.jsonParser
            ) {
                self.showAlert(title: "등록 성공", message: nil)
                self.reloadData()
            }
            return productRegistrationViewController
        }
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }
}

extension MainViewController {
    private enum Segement: Int {
        case list
        case grid
    }
    
    private func loadView(from segment: Segement) -> UIView {
        switch segment {
        case .list:
            let nibName = UINib(nibName: tableViewCellNibName, bundle: nil)
            let tableView = UITableView()
            tableView.dataSource = productsDataSource
            tableView.delegate = self
            tableView.register(
                nibName,
                forCellReuseIdentifier: ProductsTableViewCell.reuseIdentifier
            )
            return tableView
        case .grid:
            let nibName = UINib(nibName: collectionViewCellNibName, bundle: nil)
            let layout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 10.0)
            layout.sectionInsetReference = .fromSafeArea
            
            let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
            collectionView.dataSource = productsDataSource
            collectionView.delegate = self
            collectionView.register(
                nibName,
                forCellWithReuseIdentifier: ProductsCollectionViewCell.reuseIdentifier
            )
            collectionView.backgroundColor = .systemBackground
            return collectionView
        }
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        loadNextPage(ifLastItemAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vendorId = productsDataSource.vendorId(at: indexPath.row),
           vendorId != 16 {
            showAlert(
                title: "다른 사람의 상품입니다",
                message: "Vedor Id: \(vendorId)"
            )
        }
        
        guard let productId = productsDataSource.productId(at: indexPath.row) else { return }
        networkTask.requestProductDetail(productId: productId) { result in
            switch result {
            case .success(let data):
                guard let product: Product = try? self.jsonParser.decode(from: data) else {
                    return
                }
                let storyboard = UIStoryboard(
                    name: self.productRegistrationStoryboardName,
                    bundle: nil
                )
                DispatchQueue.main.async {
                    let viewController = storyboard.instantiateViewController(
                        identifier: self.productRegistrationViewControllerIdentifier
                    ) { coder in
                        let productRegistrationViewController = ProductRegistrationViewController(
                            coder: coder,
                            isModifying: true,
                            productInformation: product,
                            networkTask: self.networkTask,
                            jsonParser: self.jsonParser
                        ) {
                            self.showAlert(title: "수정 성공", message: nil)
                            self.reloadData()
                        }
                        return productRegistrationViewController
                    }
                    let navigationController = UINavigationController(
                        rootViewController: viewController
                    )
                    navigationController.modalPresentationStyle = .fullScreen
                    self.present(navigationController, animated: true, completion: nil)
                }
            case .failure(let error):
                self.showAlert(
                    title: "데이터를 불러오지 못했습니다",
                    message: error.localizedDescription
                )
            }
        }
    }
}

extension MainViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        loadNextPage(ifLastItemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let productId = productsDataSource.productId(at: indexPath.item) else { return }
        networkTask.requestProductDetail(productId: productId) { result in
            switch result {
            case .success(let data):
                guard let product: Product = try? self.jsonParser.decode(from: data) else {
                    return
                }
                let storyboard = UIStoryboard(
                    name: self.productRegistrationStoryboardName,
                    bundle: nil
                )
                DispatchQueue.main.async {
                    let viewController = storyboard.instantiateViewController(
                        identifier: self.productRegistrationViewControllerIdentifier
                    ) { coder in
                        let productRegistrationViewController = ProductRegistrationViewController(
                            coder: coder,
                            isModifying: true,
                            productInformation: product,
                            networkTask: self.networkTask,
                            jsonParser: self.jsonParser
                        ) {
                            self.showAlert(title: "수정 성공", message: nil)
                            self.reloadData()
                        }
                        return productRegistrationViewController
                    }
                    let navigationController = UINavigationController(
                        rootViewController: viewController
                    )
                    navigationController.modalPresentationStyle = .fullScreen
                    self.present(navigationController, animated: true, completion: nil)
                }
            case .failure(let error):
                self.showAlert(
                    title: "데이터를 불러오지 못했습니다",
                    message: error.localizedDescription
                )
            }
        }
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let frameWidth = collectionView.frameLayoutGuide.layoutFrame.width
        let frameHeight = collectionView.frameLayoutGuide.layoutFrame.height
        let shortLength = frameWidth < frameHeight ? frameWidth : frameHeight
        let cellWidth = shortLength / 2 - 15
        return CGSize(width: cellWidth, height: cellWidth * 1.5)
    }
}
