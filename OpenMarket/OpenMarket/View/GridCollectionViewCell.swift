//
//  CollectionViewGridCell.swift
//  OpenMarket
//
//  Created by 우롱차, Donnie on 2022/05/16.
//

import UIKit

final class GridCollectionViewCell: UICollectionViewCell, DetailCellSelectable {
    
    var productNumber: Int?
    
    private lazy var productImage = UIImageView()
    private let imageCache = ImageCache.shared
    private var lastDataTask: URLSessionDataTask?
    
    private lazy var productTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        return label
    }()
    
    private lazy var productPrice: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .callout)
        label.textColor = .gray
        return label
    }()
    
    private lazy var discountPrice: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .callout)
        label.textColor = .gray
        return label
    }()
    
    private lazy var stock: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .callout)
        return label
    }()
    
    private lazy var verticalStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [productImage, productTitle, productPrice, discountPrice, stock])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alignment = .center
        view.distribution = .equalSpacing
        view.axis = .vertical
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.borderColor = UIColor.gray.cgColor
        contentView.layer.borderWidth = 1
        contentView.layer.cornerRadius = 10
        setCellView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setCellView() {
        contentView.addSubview(verticalStackView)
        let inset: CGFloat = 20
        NSLayoutConstraint.activate([
            verticalStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: inset),
            verticalStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -inset),
            verticalStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            verticalStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            productImage.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8),
            productImage.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.5)
        ])
    }
    
    func configureContent(productInformation product: ProductInformation) {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        switch product.currency {
        case Currency.KRW.rawValue:
            numberFormatter.maximumFractionDigits = 0
        default:
            numberFormatter.maximumFractionDigits = 1
        }
        let stringPrice = numberFormatter.string(for: product.price) ?? ""
        let stringDiscountedPrice = numberFormatter.string(for: product.discountedPrice) ?? ""
        
        lastDataTask?.cancel()
        lastDataTask = imageCache.loadImage(
            urlString: product.thumbnail,
            completionHandler: { image in
                DispatchQueue.main.async { [weak self] in
                    self?.productImage.image = image
                }
            }
        )
        productTitle.text = product.name
        productNumber = product.id
        
        if product.discountedPrice == 0 {
            discountPrice.isHidden = true
            productPrice.text = "\(product.currency) \(stringPrice)"
        } else {
            discountPrice.isHidden = false
            let priceText = "\(product.currency) \(stringPrice)"
            productPrice.attributedText = NSMutableAttributedString(allText: priceText, redText: priceText)
            discountPrice.text = "\(product.currency) \(stringDiscountedPrice)"
        }
        
        if product.stock == 0 {
            stock.text = "품절"
            stock.textColor = .orange
        } else {
            stock.text = "잔여수량: \(product.stock)"
            stock.textColor = .gray
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        productPrice.attributedText = nil
        productImage.image = nil
    }
}
