//
//  ItemEditingViewController.swift
//  OpenMarket
//
//  Created by minsson on 2022/12/22.
//

import UIKit

final class ItemEditingViewController: ItemSellingViewController {
    
    private var itemDetail: ItemDetail?
    private var imageViews: [UIImageView]?
    private var images: [UIImage]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupUIComponents()
        addingPhotoButtonImageView.isHidden = true
    }
    
    func receiveData(_ itemDetail: ItemDetail?, _ images: [UIImage]) {
        self.itemDetail = itemDetail
        self.images = images
    }
    
    private func setupUIComponents() {
        guard let itemDetail = itemDetail else {
            return
        }
        
        nameTextField.text = itemDetail.name
        priceTextField.text = String(itemDetail.price)
        
        if itemDetail.price.truncatingRemainder(dividingBy: 1) == 0.0 {
            priceTextField.text = String(Int(itemDetail.price))
        } else {
            priceTextField.text = String(itemDetail.price)
        }
        
        if itemDetail.discountedPrice.truncatingRemainder(dividingBy: 1) == 0.0 {
            discountedPriceTextField.text = String(Int(itemDetail.discountedPrice))
        } else {
            discountedPriceTextField.text = String(itemDetail.discountedPrice)
        }
        
        stockTextField.text = String(itemDetail.stock)
        textView.text = itemDetail.description
        
        images?.forEach({ image in
            let imageView = UIImageView(image: image)
            imageView.layer.cornerRadius = 10
            imageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
            imageView.clipsToBounds = true
            photoStackView.addArrangedSubview(imageView)
        })
    }
    
}
