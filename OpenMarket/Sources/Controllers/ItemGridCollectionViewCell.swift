//
//  ItemGridCollectionViewCell.swift
//  OpenMarket
//
//  Created by 이예은 on 2022/07/23.
//

import UIKit

class ItemGridCollectionViewCell: UICollectionViewCell {
    let imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()
    
    let priceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.textColor = .systemGray
        return label
    }()
    
   let stockLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.textColor = .systemGray
        return label
    }()
    
    private let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private func arrangeSubView() {
        verticalStackView.addSubview(imageView)
        verticalStackView.addSubview(nameLabel)
        verticalStackView.addSubview(priceLabel)
        verticalStackView.addSubview(stockLabel)
        
        contentView.addSubview(verticalStackView)
        
        NSLayoutConstraint.activate([
            verticalStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            verticalStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            verticalStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            verticalStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            
            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.9),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 0.9)
        ])
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        arrangeSubView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func prepareForReuse() {
        stockLabel.textColor = .systemGray
        priceLabel.textColor = .systemRed
    }
    
    func configureCell(item: ItemListPage.Item) {
        let imageData = item.thumbnail
//        guard let url = URL(string: imageData) else { return }
//        guard let imageData2 = try? Data(contentsOf: url) else { return }
//
//        let image = UIImage(data: imageData2)
        
        self.imageView.setImageURL(imageData)
//        self.productImageView.image = image
        self.stockLabel.text = "잔여수량 : \(item.stock)"
        self.priceLabel.text = "\(item.price)"
        self.nameLabel.text = "\(item.name)"
    }
    
   
    
//    func setViewItems(_ item: ItemListPage.Item) {
//        if let image = ImageCacheManager.shared.object(forKey: NSString(string: item.thumbnail)) {
//            productImageView.image = image
//        } else {
//            let request =
//        }
//    }
}
