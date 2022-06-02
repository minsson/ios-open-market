//
//  ProductGridCell.swift
//  OpenMarket
//
//  Created by papri, Tiana on 17/05/2022.
//

import UIKit

class ProductGridCell: UICollectionViewCell, ContentUpdatable {
    static let reuseIdentifier = "product-grid-cell-reuse-Identifier"
    let cellUIComponent = CellUIComponent()
    var item: Product? = nil
    private var imageFetchTask: URLSessionDataTask?
    
    //MARK: - stackView
    private let baseStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 2
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ProductGridCell {
    private func addSubViews() {
        contentView.layer.borderWidth = CGFloat(1)
        contentView.layer.cornerRadius = CGFloat(10)
        contentView.layer.borderColor = UIColor.systemGray.cgColor
        contentView.addSubview(baseStackView)
        baseStackView.addArrangedSubviews(cellUIComponent.thumbnailImageView, cellUIComponent.nameLabel, cellUIComponent.priceLabel, cellUIComponent.bargainPriceLabel, cellUIComponent.stockLabel)
    }
    
    private func layout() {
        let thumbnail = cellUIComponent.thumbnailImageView
        
        let inset = CGFloat(10)
        NSLayoutConstraint.activate([
            baseStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
            baseStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
            baseStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: inset),
            baseStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -inset)
        ])
        
        NSLayoutConstraint.activate([
            thumbnail.widthAnchor.constraint(equalToConstant: contentView.frame.width * 0.7),
            thumbnail.heightAnchor.constraint(equalTo: thumbnail.widthAnchor)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageFetchTask?.cancel()
        cellUIComponent.thumbnailImageView.image = UIImage(systemName: "swift")
        cellUIComponent.stockLabel.textColor = .systemGray
        cellUIComponent.priceLabel.textColor = .systemGray
        cellUIComponent.bargainPriceLabel.isHidden = false
        cellUIComponent.priceLabel.attributedText = nil
    }
}

@available(iOS 14.0, *)
extension ProductGridCell {    
    override var configurationState: UICellConfigurationState {
        var state = super.configurationState
        state.item = self.item
        return state
    }
}

@available(iOS 14.0, *)
extension ProductGridCell {
    private func setupViewsIfNeeded() {
        layout()
    }
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        guard let product = state.item else { return }
        
        cellUIComponent.nameLabel.text = product.name
        cellUIComponent.bargainPriceLabel.text = product.currency + String(product.bargainPrice)
        cellUIComponent.priceLabel.text = product.currency + String(product.price)
        
        setUpStockLabel(stock: product.stock)
        setUpPriceLabel(price: product.price, bargainPrice: product.bargainPrice)
        
        imageFetchTask = DataProvider.shared.fetchImage(urlString: product.thumbnail) { [weak self] image in
            DispatchQueue.main.async { [weak self] in
                self?.cellUIComponent.thumbnailImageView.image = image
            }
        }
    }
    
    private func setUpStockLabel(stock: Int) {
        switch stock {
        case 0:
            cellUIComponent.stockLabel.text = "품절"
            cellUIComponent.stockLabel.textColor = .systemYellow
        default:
            cellUIComponent.stockLabel.text = "잔여수량 : " + String(stock)
        }
    }
    
    private func setUpPriceLabel(price: Int, bargainPrice: Int) {
        switch bargainPrice == price {
        case true:
            cellUIComponent.bargainPriceLabel.isHidden = true
        case false:
            cellUIComponent.priceLabel.attributedText = cellUIComponent.priceLabel.text?.strikeThrough()
            cellUIComponent.priceLabel.textColor = .systemRed
        }
    }
}
