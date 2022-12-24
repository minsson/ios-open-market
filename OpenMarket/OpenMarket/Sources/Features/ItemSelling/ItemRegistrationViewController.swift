//
//  ItemRegistrationViewController.swift
//  OpenMarket
//
//  Created by minsson on 2022/08/14.
//

import UIKit

class ItemRegistrationViewController: ItemSellingViewController {
 
    // MARK: - Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRootView()
        configureDoneButton()
    }
    
}

// MARK: - Private Actions

private extension ItemRegistrationViewController {
    
    func setupRootView() {
        view.backgroundColor = .systemBackground
        viewTitleLabel.text = "상품등록"
    }
    
    // MARK: - Actions for Done Button

    func configureDoneButton() {
        doneButton.addTarget(self, action: #selector(doneButtonDidTap), for: .touchUpInside)
    }
    
    @objc func doneButtonDidTap() {
        guard let inputData = assembleInputData() else {
            return
        }
        
        pushDataToServer(data: inputData)
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

    func pushDataToServer(data: Data) {
        guard let request = API.RegisterItem(jsonData: data, images: selectedPhotos).urlRequest else {
            return
        }
        
        // TODO: 네트워킹 방법 변경
        URLSession.shared.dataTask(with: request) { Data, response, error in
            if let error = error {
                print(error)
                return
            }
        }.resume()
    }
    
}
