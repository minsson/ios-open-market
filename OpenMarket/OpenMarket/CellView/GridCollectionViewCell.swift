//
//  GridCollectionViewCell.swift
//  OpenMarket
//
//  Created by Grumpy, OneTool on 2022/05/13.
//

import UIKit

final class GridCollectionViewCell: UICollectionViewCell, OpenMarketCell {
    
    var productNameLabel: UILabel = UILabel()
    var productImageView: UIImageView = UIImageView()
    var productPriceLabel: UILabel = UILabel()
    var productBargainPriceLabel: UILabel = UILabel()
    var productStockLabel: UILabel = UILabel()
    var mainStackView: UIStackView = UIStackView()
    var priceStackView: UIStackView = UIStackView()
    var informationStackView: UIStackView = UIStackView()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setUpSubViewStructure()
        setUpLayoutConstraints()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.productNameLabel = createLabel(font: .preferredFont(for: .title3, weight: .semibold), textColor: .black, alignment: .center)
        self.productImageView = createImageView(contentMode: .scaleAspectFit)
        self.productPriceLabel = createLabel(font: .preferredFont(forTextStyle: .body), textColor: .systemGray, alignment: .center)
        self.productBargainPriceLabel = createLabel(font: .preferredFont(forTextStyle: .body), textColor: .systemGray, alignment: .center)
        self.productStockLabel = createLabel(font: .preferredFont(forTextStyle: .body), textColor: .systemGray, alignment: .center)
        self.mainStackView = createStackView(axis: .vertical, alignment: .center, distribution: .fill, spacing: 5, margin: UIEdgeInsets(top: 10, left: 10, bottom: 5, right: 10))
        self.priceStackView = createStackView(axis: .vertical, alignment: .center, distribution: .fillProportionally, spacing: 0)
        self.informationStackView = createStackView(axis: .vertical, alignment: .center, distribution: .fillEqually, spacing: 5)
        
        setUpSubViewStructure()
        setUpLayoutConstraints()
    }

    func setUpSubViewStructure() {
        contentView.addSubview(mainStackView)
        mainStackView.addArrangedSubview(productImageView)
        mainStackView.addArrangedSubview(informationStackView)
        informationStackView.addArrangedSubview(productNameLabel)
        informationStackView.addArrangedSubview(priceStackView)
        informationStackView.addArrangedSubview(productStockLabel)
        priceStackView.addArrangedSubview(productPriceLabel)
        priceStackView.addArrangedSubview(productBargainPriceLabel)
        
    }
    
    func setUpLayoutConstraints() {
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        productImageView.heightAnchor.constraint(equalTo: mainStackView.heightAnchor, multiplier: 0.5).isActive = true
    }
}

extension GridCollectionViewCell {
    override func prepareForReuse() {
        super.prepareForReuse()
        productNameLabel.text = ""
        productPriceLabel.attributedText = nil
        productPriceLabel.textColor = .systemGray
        productPriceLabel.text = ""
        
        productStockLabel.textColor = .systemGray
        productStockLabel.text = ""
        productBargainPriceLabel.textColor = .systemGray
        productBargainPriceLabel.text = ""
        
        productImageView.heightAnchor.constraint(equalTo: mainStackView.heightAnchor, multiplier: 0.5).isActive = true
    }
}
