//
//  ProductImageCell.swift
//  OpenMarket
//
//  Created by dudu, safari on 2022/05/24.
//

import UIKit

final class ProductImageCell: UICollectionViewCell {
    private let productImageView: UIImageView = {
        let imageView = UIImageView()
            
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let removeButton: UIButton = {
        let button = UIButton()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    var removeImage: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLayout() {
        contentView.addSubview(productImageView)
        
        NSLayoutConstraint.activate([
            productImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            productImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            productImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            productImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        
        contentView.addSubview(removeButton)
        
        NSLayoutConstraint.activate([
            removeButton.topAnchor.constraint(equalTo: productImageView.topAnchor, constant: -8),
            removeButton.trailingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: 8)
        ])
    }
    
    func configure(image: UIImage) {
        productImageView.image = image
        removeButton.addTarget(self, action: #selector(removeButtonTapped), for: .touchUpInside)
                
        if productImageView.image == UIImage(named: "plus") {
            removeButton.isHidden = true
        }
    }
    
    func hideRemoveButton() {
        removeButton.isHidden = true
    }
    
    override func prepareForReuse() {
        productImageView.image = nil
        removeButton.isHidden = false
    }
    
    @objc private func removeButtonTapped() {
        removeImage?()
    }
}
