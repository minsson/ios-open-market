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
    private var imageRequest: URLSessionTask?
    
    // MARK: - UI Properties
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let entireVerticalStackView: UIStackView = {
        let entireVerticalStackView = UIStackView()
        entireVerticalStackView.alignment = .center
        entireVerticalStackView.axis = .vertical
        entireVerticalStackView.spacing = 12
        entireVerticalStackView.distribution = .fill
        entireVerticalStackView.translatesAutoresizingMaskIntoConstraints = false
        return entireVerticalStackView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.text = "TEST"
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        imageRequest?.cancel()
    }
}

// MARK: - Private Actions

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
        NSLayoutConstraint.activate([
            entireVerticalStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            entireVerticalStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            entireVerticalStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            entireVerticalStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            entireVerticalStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            imageView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    func addSubViews() {
        view.addSubview(scrollView)
        
        scrollView.addSubview(entireVerticalStackView)
        
        entireVerticalStackView.addArrangedSubview(imageView)
        entireVerticalStackView.addArrangedSubview(nameLabel)
        entireVerticalStackView.addArrangedSubview(priceLabel)
        entireVerticalStackView.addArrangedSubview(bargainPriceLabel)
        entireVerticalStackView.addArrangedSubview(stockLabel)
        entireVerticalStackView.addArrangedSubview(descriptionLabel)
    }
    
    func setupUIComponents(with itemDetail: ItemDetail) {
        view.backgroundColor = .systemBackground
        
        imageRequest = imageView.setImageURL(itemDetail.images[0].url)
        
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
    
}
