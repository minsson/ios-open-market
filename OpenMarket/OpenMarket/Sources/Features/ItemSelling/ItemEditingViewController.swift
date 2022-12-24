//
//  ItemEditingViewController.swift
//  OpenMarket
//
//  Created by minsson on 2022/12/22.
//

import UIKit

final class ItemEditingViewController: ItemSellingViewController {
    
    // MARK: - Properties
    
    private var itemDetail: ItemDetail?
    
    // MARK: - UI Components
    
    private var imageViews: [UIImageView]?
    private var images: [UIImage]?
    
    // MARK: - Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRootView()
        setupUIComponents()
        configureDoneButton()
    }
    
}

// MARK: - Actions

extension ItemEditingViewController {
    
    func receiveData(_ itemDetail: ItemDetail?, _ images: [UIImage]) {
        self.itemDetail = itemDetail
        self.images = images
    }
    
}

// MARK: - Private Actions

private extension ItemEditingViewController {
    
    // MARK: - Actions for UI
    
    func setupRootView() {
        view.backgroundColor = .systemBackground
        viewTitleLabel.text = "상품수정"
        addingPhotoButtonImageView.isHidden = true
    }
    
    func setupUIComponents() {
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
    
    // MARK: - Actions for Done Button

    func configureDoneButton() {
        doneButton.addTarget(self, action: #selector(doneButtonDidTap), for: .touchUpInside)
    }
    
    @objc func doneButtonDidTap() {
        pushDataToServer(data: assembleInputData())
        dismiss(animated: true)
    }
    
    func assembleInputData() -> Data? {
        guard let name = nameTextField.text,
              let priceText = priceTextField.text,
              let price = Double(priceText),
              let discountedPriceText = discountedPriceTextField.text,
              let stockText = stockTextField.text,
              let descriptionText = textView.text else {
            return nil
        }

        let discountedPrice = Double(discountedPriceText) ?? 0
        let stock = Int(stockText) ?? 0
        let currency = currencySegmentedControl.selectedSegmentIndex == 0 ? Currency.krw : Currency.usd

        let requestItem = Item(
            name: name,
            price: price,
            discountedPrice: discountedPrice,
            currency: currency.rawValue,
            stock: stock,
            description: descriptionText
        )

        do {
            let requestItemData = try JSONEncoder().encode(requestItem)
            return requestItemData
        } catch {
            return nil
        }
    }

    func pushDataToServer(data: Data?) {
        guard let itemDetail = itemDetail else {
            return
        }

        guard let request = API.EditItem(productID: String(itemDetail.id), with: data).urlRequest else {
            return
        }
        
        // TODO: 네트워킹 방법 변경
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print(error)
                return
            }
        }.resume()

    }
    
}
