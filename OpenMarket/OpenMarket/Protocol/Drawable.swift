//
//  Drawable.swift
//  OpenMarket
//
//  Created by Eddy, marisol on 2022/05/28.
//

import UIKit

private enum Product {
    static let productName = "상품명"
    static let price = "상품가격"
    static let discountedPrice = "할인금액"
    static let stock = "재고수량"
}

protocol Drawable: UIView {
    var entireStackView: UIStackView { get }
    var productInfoStackView: UIStackView { get }
    var priceStackView: UIStackView { get }
    var priceTextField: UITextField { get }
    var segmentedControl: UISegmentedControl { get }
    var productNameTextField: UITextField { get }
    var discountedPriceTextField: UITextField { get }
    var stockTextField: UITextField { get }
    var descriptionTextView: UITextView { get }
    
    func configureView()
    func configurePriceStackView()
    func configureProductInfoStackView()
    func configureEntireStackViewLayout()
    func makeStackView(axis: NSLayoutConstraint.Axis, alignment: UIStackView.Alignment, distribution: UIStackView.Distribution, spacing: CGFloat) -> UIStackView
}

extension Drawable {
    func configureView() {
        self.addSubview(entireStackView)
        entireStackView.addArrangedSubview([productInfoStackView, descriptionTextView])
        productInfoStackView.addArrangedSubview([productNameTextField, priceStackView, discountedPriceTextField, stockTextField])
        priceStackView.addArrangedSubview([priceTextField, segmentedControl])
        
        configureEntireStackViewLayout()
        configureProductInfoStackView()
        configurePriceStackView()
    }
    
    func configurePriceStackView() {
        priceTextField.borderStyle = .roundedRect
        priceTextField.placeholder = Product.price
        priceTextField.keyboardType = .numberPad
        segmentedControl.selectedSegmentIndex = 0
        
        segmentedControl.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        priceTextField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        segmentedControl.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    func configureProductInfoStackView() {
        productNameTextField.borderStyle = .roundedRect
        productNameTextField.placeholder = Product.productName
        
        discountedPriceTextField.borderStyle = .roundedRect
        discountedPriceTextField.placeholder = Product.discountedPrice
        discountedPriceTextField.keyboardType = .numberPad
        
        stockTextField.borderStyle = .roundedRect
        stockTextField.placeholder = Product.stock
        stockTextField.keyboardType = .numberPad
    }
    
    func configureEntireStackViewLayout() {
        entireStackView.translatesAutoresizingMaskIntoConstraints = false
        productInfoStackView.translatesAutoresizingMaskIntoConstraints = false
        priceStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.entireStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            self.entireStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            self.entireStackView.topAnchor.constraint(equalTo: self.topAnchor),
            self.entireStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.entireStackView.heightAnchor.constraint(equalTo: self.heightAnchor)
        ])
    }
    
    func makeStackView(axis: NSLayoutConstraint.Axis, alignment: UIStackView.Alignment, distribution: UIStackView.Distribution, spacing: CGFloat) -> UIStackView {
        let stackView = UIStackView()
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = axis
        stackView.alignment = alignment
        stackView.distribution = distribution
        stackView.spacing = spacing
        
        return stackView
    }
}
