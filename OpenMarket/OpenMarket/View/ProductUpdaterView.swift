//
//  ProductUpdaterView.swift
//  OpenMarket
//
//  Created by cathy, mmim.
//

import UIKit

class ProductUpdaterView: UIView {
  enum Constants {
    static let nameText = "상품명"
    static let priceText = "상품가격"
    static let discountedPriceText = "할인금액"
    static let stockText = "재고수량"
    static let buttonTitle = "+"
    static let secret = "pqnoec089z"
    static let textViewFontSize: Double = 17
    static let stackViewSpacing: Double = 5
    static let anchorSpacing: Double = 10
    static let currencyWidthScale: Double = 0.23
    static let scrollViewHeightScale: Double = 0.17
    static let textViewHeightScale: Double = 0.6
  }
  
  init() {
    super.init(frame: .zero)
    self.backgroundColor = .white
    self.translatesAutoresizingMaskIntoConstraints = false
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  //MARK: - image scroll part
  let imageScrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    return scrollView
  }()
  //MARK: - text field part
  let nameTextField: UITextField = {
    let textField = UITextField()
    textField.placeholder = Constants.nameText
    textField.borderStyle = .roundedRect
    textField.backgroundColor = .white
    textField.keyboardType = .default
    return textField
  }()
  
  let priceTextField: UITextField = {
    let textField = UITextField()
    textField.placeholder = Constants.priceText
    textField.borderStyle = .roundedRect
    textField.backgroundColor = .white
    textField.keyboardType = .numberPad
    return textField
  }()
  
  let currencySegmentedControl: UISegmentedControl = {
    let segmentedControl = UISegmentedControl(items: [Currency.won.text, Currency.dollar.text])
    segmentedControl.selectedSegmentIndex = Currency.won.optionNumber
    segmentedControl.translatesAutoresizingMaskIntoConstraints = false
    segmentedControl.setContentCompressionResistancePriority(.required, for: .horizontal)
    return segmentedControl
  }()
  
  let discountedPriceTextField: UITextField = {
    let textField = UITextField()
    textField.placeholder = Constants.discountedPriceText
    textField.borderStyle = .roundedRect
    textField.backgroundColor = .white
    textField.keyboardType = .numberPad
    return textField
  }()
  
  let stockTextField: UITextField = {
    let textField = UITextField()
    textField.placeholder = Constants.stockText
    textField.borderStyle = .roundedRect
    textField.backgroundColor = .white
    textField.keyboardType = .numberPad
    return textField
  }()
  //MARK: - description part
  let descriptionTextView: UITextView = {
    let textView = UITextView()
    textView.backgroundColor = .white
    textView.translatesAutoresizingMaskIntoConstraints = false
    textView.keyboardType = .default
    textView.font = .systemFont(ofSize: Constants.textViewFontSize)
    return textView
  }()
  //MARK: - stack view
  let imageStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.alignment = .fill
    stackView.distribution = .fill
    stackView.spacing = Constants.stackViewSpacing
    stackView.translatesAutoresizingMaskIntoConstraints = false
    return stackView
  }()
  
  let priceStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.alignment = .fill
    stackView.distribution = .fill
    stackView.spacing = Constants.stackViewSpacing
    return stackView
  }()
  
  let textFieldStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.alignment = .fill
    stackView.distribution = .fillEqually
    stackView.spacing = Constants.stackViewSpacing
    return stackView
  }()
  
  let totalStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.alignment = .fill
    stackView.distribution = .fill
    stackView.spacing = Constants.stackViewSpacing
    stackView.translatesAutoresizingMaskIntoConstraints = false
    return stackView
  }()
  
  func setupParams() -> Params? {
    let currentCurrency = verifyCurrency()
 
    guard let name = checkStringCondition(self.nameTextField.text),
          let price = checkNumberCondition(self.priceTextField.text),
          let discountedPrice = checkNumberCondition(self.discountedPriceTextField.text),
          let stock = checkNumberCondition(self.stockTextField.text),
          let descriptions = checkStringCondition(self.descriptionTextView.text)
    else {
      return nil
    }
    
    let params = Params(name: name,
                        price: price,
                        discountedPrice: discountedPrice,
                        stock: stock,
                        currency: currentCurrency,
                        descriptions: descriptions,
                        secret: Constants.secret)
    return params
  }
  
  private func checkStringCondition(_ text: String?) -> String? {
    guard let validText = text else {
      return nil
    }
    
    let trimmedText = validText.trimmingCharacters(in: .whitespaces)
    guard !trimmedText.isEmpty else {
      return nil
    }
    return trimmedText
  }
  
  private func checkNumberCondition(_ text: String?) -> Int? {
    guard let validText = text else {
      return nil
    }
    
    let trimmedText = validText.trimmingCharacters(in: .whitespaces)
    guard !trimmedText.isEmpty else {
      return nil
    }
    
    guard let number = trimmedText.integer else {
      return nil
    }
    
    return number
  }
  
  private func verifyCurrency() -> Currency {
    var currency: Currency
    switch self.currencySegmentedControl.selectedSegmentIndex {
    case Currency.won.optionNumber:
      currency = Currency.won
    case Currency.dollar.optionNumber:
      currency = Currency.dollar
    default:
      currency = Currency.won
    }
    return currency
  }
}
