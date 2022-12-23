//
//  ItemDetailViewController.swift
//  OpenMarket
//
//  Created by minsson on 2022/12/17.
//

import UIKit

final class ItemDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    private var productID: String?
    private var itemDetail: ItemDetail?
    private var imageRequests: [URLSessionTask?] = []
    private var imageViews: [UIImageView] = []
    
    // MARK: - UI Properties
    
    private let entireVerticalScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let imagesScrollView: UIScrollView = {
        let imagesScrollView = UIScrollView()
        imagesScrollView.translatesAutoresizingMaskIntoConstraints = false
        imagesScrollView.showsHorizontalScrollIndicator = false
        imagesScrollView.isPagingEnabled = true
        return imagesScrollView
    }()
    
    private let imagesHorizontalStackView: UIStackView = {
        let imagesHorizontalStackView = UIStackView()
        imagesHorizontalStackView.alignment = .center
        imagesHorizontalStackView.axis = .horizontal
        imagesHorizontalStackView.distribution = .fillEqually
        imagesHorizontalStackView.backgroundColor = .systemGray
        imagesHorizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        return imagesHorizontalStackView
    }()
    
    private let detailInformationLabelsVerticalStackView: UIStackView = {
        let entireVerticalStackView = UIStackView()
        entireVerticalStackView.alignment = .center
        entireVerticalStackView.axis = .vertical
        entireVerticalStackView.spacing = 12
        entireVerticalStackView.distribution = .fill
        entireVerticalStackView.translatesAutoresizingMaskIntoConstraints = false
        return entireVerticalStackView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = Color.priceLabel
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()
    
    private let bargainPriceLabel: UILabel = {
        let label = UILabel()
        label.textColor = Color.bargainPriceLabel
        label.textAlignment = .left
        return label
    }()
    
    private let stockLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textAlignment = .right
        label.textColor = Color.stockLabel
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.numberOfLines = 0
        return descriptionLabel
    }()
    
    // MARK: - Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubViews()
        setupLayoutConstraints()
        
        retrieveItemDetail()
        configureEditButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        imageRequests.forEach { urlSessionTask in
            urlSessionTask?.cancel()
        }
    }
}

// MARK: - Actions

extension ItemDetailViewController {
    
    func setupProductID(productID: String) {
        self.productID = productID
    }
    
}


// MARK: - Private Actions

private extension ItemDetailViewController {
    
    func retrieveItemDetail() {
        guard let productID = productID,
              let urlRequest = API.LookUpItemDetail(productID: productID).urlRequest else {
            return
        }
        
        NetworkManager.execute(urlRequest) { result in
            switch result {
            case .success(let data):
                self.itemDetail = NetworkManager.decode(data, into: ItemDetail.self)
                
                guard let itemDetail = self.itemDetail else {
                    return
                }
                
                DispatchQueue.main.async { [weak self] in
                    self?.setupUIComponents(with: itemDetail)
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func setupLayoutConstraints() {
        let imageHeight = view.frame.height / CGFloat(2) - CGFloat(50)
        
        NSLayoutConstraint.activate([
            imagesScrollView.topAnchor.constraint(equalTo: entireVerticalScrollView.topAnchor),
            imagesScrollView.leadingAnchor.constraint(equalTo: entireVerticalScrollView.leadingAnchor),
            imagesScrollView.trailingAnchor.constraint(equalTo: entireVerticalScrollView.trailingAnchor),
            imagesScrollView.bottomAnchor.constraint(equalTo: detailInformationLabelsVerticalStackView.topAnchor),
            
            imagesHorizontalStackView.heightAnchor.constraint(equalToConstant: imageHeight),
            imagesHorizontalStackView.heightAnchor.constraint(equalTo: imagesScrollView.heightAnchor),
            imagesHorizontalStackView.topAnchor.constraint(equalTo: imagesScrollView.topAnchor),
            imagesHorizontalStackView.bottomAnchor.constraint(equalTo: imagesScrollView.contentLayoutGuide.bottomAnchor),
            imagesHorizontalStackView.leadingAnchor.constraint(equalTo: imagesScrollView.contentLayoutGuide.leadingAnchor),
            imagesHorizontalStackView.trailingAnchor.constraint(equalTo: imagesScrollView.contentLayoutGuide.trailingAnchor),

            detailInformationLabelsVerticalStackView.widthAnchor.constraint(equalTo: entireVerticalScrollView.widthAnchor),
            detailInformationLabelsVerticalStackView.topAnchor.constraint(equalTo: imagesScrollView.bottomAnchor),
            detailInformationLabelsVerticalStackView.bottomAnchor.constraint(equalTo: entireVerticalScrollView.contentLayoutGuide.bottomAnchor),
            detailInformationLabelsVerticalStackView.leadingAnchor.constraint(equalTo: entireVerticalScrollView.contentLayoutGuide.leadingAnchor),
            detailInformationLabelsVerticalStackView.trailingAnchor.constraint(equalTo: entireVerticalScrollView.contentLayoutGuide.trailingAnchor),
            
            entireVerticalScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            entireVerticalScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            entireVerticalScrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            entireVerticalScrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    
    func addSubViews() {
        view.addSubview(entireVerticalScrollView)
        
        entireVerticalScrollView.addSubview(imagesScrollView)
        entireVerticalScrollView.addSubview(detailInformationLabelsVerticalStackView)
        
        imagesScrollView.addSubview(imagesHorizontalStackView)
        
        detailInformationLabelsVerticalStackView.addArrangedSubview(nameLabel)
        detailInformationLabelsVerticalStackView.addArrangedSubview(priceLabel)
        detailInformationLabelsVerticalStackView.addArrangedSubview(bargainPriceLabel)
        detailInformationLabelsVerticalStackView.addArrangedSubview(stockLabel)
        detailInformationLabelsVerticalStackView.addArrangedSubview(descriptionLabel)
    }
    
    func setupUIComponents(with itemDetail: ItemDetail) {
        view.backgroundColor = .systemBackground
    
        itemDetail.images.forEach { image in
            let imageView = UIImageView()
            imageView.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
            imagesHorizontalStackView.addArrangedSubview(imageView)
            imageViews.append(imageView)
            
            let imageRequest: URLSessionTask? = imageView.setImageURL(image.url)
            imageRequests.append(imageRequest)
        }
        
        nameLabel.text = itemDetail.name
        priceLabel.text = itemDetail.price.applyFormat(currency: itemDetail.currency)
        priceLabel.textColor = Color.priceLabel
        bargainPriceLabel.text = itemDetail.bargainPrice.applyFormat(currency: itemDetail.currency)
        
        if itemDetail.discountedPrice == 0 {
            bargainPriceLabel.isHidden = true
        } else {
            bargainPriceLabel.isHidden = false
            priceLabel.textColor = Color.priceLabelDiscounted
            priceLabel.applyStrikethrough()
        }
        
        if itemDetail.stock == 0 {
            stockLabel.textColor = Color.stockLabelSoldOut
            stockLabel.text = "품절"
        } else {
            stockLabel.textColor = Color.stockLabel
            stockLabel.text = "잔여수량: \(itemDetail.stock)"
        }
        
        descriptionLabel.text = itemDetail.description
    }
    
    func configureEditButton() {
        let composeButton = UIBarButtonItem(
            barButtonSystemItem: .compose,
            target: self,
            action: #selector(presentItemEditingView)
        )

        self.navigationItem.rightBarButtonItem = composeButton
    }
    
    @objc func presentItemEditingView() {
        var images: [UIImage] = []
        imageViews.forEach { imageView in
            guard let image = imageView.image else {
                return
            }
            images.append(image)
        }

        let itemEditingViewController: ItemEditingViewController = {
            let itemEditingViewController = ItemEditingViewController()
            itemEditingViewController.view.backgroundColor = .systemBackground
            itemEditingViewController.modalPresentationStyle = .fullScreen
            itemEditingViewController.receiveData(itemDetail, images)
            return itemEditingViewController
        }()
        
        present(itemEditingViewController, animated: true)
    }
    
}
