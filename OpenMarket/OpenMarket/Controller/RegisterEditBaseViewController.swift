//
//  RegisterEditViewController.swift
//  OpenMarket
//
//  Created by 우롱차, Donnie on 2022/05/24.
//

import UIKit

class RegisterEditBaseViewController: UIViewController {
    
    private enum Constant {
        static let rightNavigationButtonText = "Done"
        static let leftNavigationButtonText = "Cancel"
        static let nameTextFieldPlaceHolder = "상품명"
        static let priceTextFieldPlaceHolder = "상품가격"
        static let discountPriceTextFieldPlaceHolder = "할인가격"
        static let stockTextFieldPlaceHolder = "재고수량"
        static let priceDefaultValue = "0"
        static let discountePriceTextValue = "0"
        static let stockDefaultValue = "0"
    }
    
    var keyBoardSize: CGFloat = 0
    
    private lazy var rightNavigationButton = UIBarButtonItem(
        title: Constant.rightNavigationButtonText,
        style: .plain,
        target: self,
        action: #selector(registerEditViewRightBarButtonTapped)
    )
    
    private lazy var leftNavigationButton: UIBarButtonItem = UIBarButtonItem(
        title: Constant.leftNavigationButtonText,
        style: .plain,
        target: self,
        action: #selector(registerEditViewLeftBarButtonTapped)
    )
    
    private lazy var baseScrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private(set) lazy var addImageScrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private(set) lazy var addImageHorizontalStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.spacing = 10
        view.alignment = .leading
        view.distribution = .equalSpacing
        return view
    }()
    
    private(set) lazy var baseVerticalStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [
            nameTextField,
            priceCurrencyStackView,
            discountPriceTextField,
            stockTextField,
            textView
        ])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = 10
        return view
    }()
    
    private lazy var priceCurrencyStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [priceTextField, currencySegmentedControl])
        view.axis = .horizontal
        view.spacing = 10
        return view
    }()
    
    private lazy var nameTextField = generateTextField(placeholder: Constant.nameTextFieldPlaceHolder, keyboardType: .default)
    private lazy var priceTextField = generateTextField(placeholder: Constant.priceTextFieldPlaceHolder, keyboardType: .decimalPad)
    private lazy var discountPriceTextField = generateTextField(placeholder: Constant.discountPriceTextFieldPlaceHolder, keyboardType: .decimalPad)
    private lazy var stockTextField = generateTextField(placeholder: Constant.stockTextFieldPlaceHolder, keyboardType: .numberPad)
    
    private(set) lazy var currencySegmentedControl: UISegmentedControl = {
        let segment = UISegmentedControl(items: [Currency.KRW.rawValue, Currency.USD.rawValue])
        segment.translatesAutoresizingMaskIntoConstraints = false
        segment.selectedSegmentIndex = 0
        return segment
    }()
    
    private(set) lazy var textView: UITextView = {
        let view = UITextView()
        view.font = .preferredFont(forTextStyle: .body)
        view.layer.borderColor = UIColor.systemGray4.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 5
        view.delegate = self
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeDownAction))
        gesture.direction = .down
        view.addGestureRecognizer(gesture)
        return view
    }()
}

// MARK: - Lifecycle Method

extension RegisterEditBaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setNavigationTitle()
        setConstraint()
        registerForKeyboardNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeRegisterForKeyboardNotification()
    }
}

// MARK: - Method

extension RegisterEditBaseViewController {
    
    private func setNavigationTitle() {
        navigationItem.rightBarButtonItem = rightNavigationButton
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = leftNavigationButton
    }
    
    func wrapperRegistrationParameter() -> RegistrationParameter? {
        guard let name = nameTextField.text else {
            return nil
        }
        guard let descriptions = textView.text else {
            return nil
        }
        guard let price = Double(priceTextField.text ?? Constant.priceDefaultValue) else {
            return nil
        }
        guard let selectedText = currencySegmentedControl.titleForSegment(at: currencySegmentedControl.selectedSegmentIndex), let currency = Currency(rawValue: selectedText) else {
            return nil
        }
        guard let discountedPrice = Double(discountPriceTextField.text ?? Constant.discountePriceTextValue) else {
            return nil
        }
        guard let stock = Int(stockTextField.text ?? Constant.stockDefaultValue) else {
            return nil
        }
        
        let secret = setSecret()
        
        return RegistrationParameter(name: name, descriptions: descriptions, price: price, currency: currency, discountedPrice: discountedPrice, stock: stock, secret: secret)
    }
    
    func setSecret() -> String {
        return Secret.registerSecret
    }
    
    func setConstraint() {
        view.addSubview(baseScrollView)
        NSLayoutConstraint.activate([
            baseScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            baseScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            baseScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            baseScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        baseScrollView.addSubview(addImageScrollView)
        NSLayoutConstraint.activate([
            addImageScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            addImageScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            addImageScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            addImageScrollView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.2)
        ])
        
        addImageScrollView.addSubview(addImageHorizontalStackView)
        NSLayoutConstraint.activate([
            addImageHorizontalStackView.leadingAnchor.constraint(equalTo: addImageScrollView.leadingAnchor),
            addImageHorizontalStackView.trailingAnchor.constraint(equalTo: addImageScrollView.trailingAnchor),
            addImageHorizontalStackView.topAnchor.constraint(equalTo: addImageScrollView.topAnchor),
            addImageHorizontalStackView.bottomAnchor.constraint(equalTo: addImageScrollView.bottomAnchor)
        ])
        
        baseScrollView.addSubview(baseVerticalStackView)
        NSLayoutConstraint.activate([
            baseVerticalStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            baseVerticalStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            baseVerticalStackView.topAnchor.constraint(equalTo: addImageScrollView.bottomAnchor, constant: 15),
            baseVerticalStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            currencySegmentedControl.widthAnchor.constraint(equalTo: baseScrollView.widthAnchor, multiplier: 0.25)
        ])
    }
    
    private func generateTextField(placeholder: String, keyboardType: UIKeyboardType) -> UITextField {
        let field = UITextField()
        field.placeholder = "\(placeholder)"
        field.layer.borderColor = UIColor.systemGray4.cgColor
        field.layer.borderWidth = 1
        field.layer.cornerRadius = 5
        field.addLeftPadding()
        field.keyboardType = keyboardType
        NSLayoutConstraint.activate([
            field.heightAnchor.constraint(equalToConstant: 35)
        ])
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeDownAction))
        gesture.direction = .down
        field.addGestureRecognizer(gesture)
        return field
    }
}

// MARK: - Keyboard Method

extension RegisterEditBaseViewController {
    
    private func registerForKeyboardNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyBoardShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
     }
    
    private func removeRegisterForKeyboardNotification() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
     }
    
    @objc private func keyBoardShow(notification: NSNotification) {
        guard let userInfo: NSDictionary = notification.userInfo as? NSDictionary else {
            return
        }
        let keyboardFrame: NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        keyBoardSize = keyboardRectangle.height
    }
}

// MARK: - Action Method

extension RegisterEditBaseViewController {
    
    @objc func registerEditViewRightBarButtonTapped() {
        
    }
    
    @objc private func registerEditViewLeftBarButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    
    @objc func swipeDownAction(_ sender: UISwipeGestureRecognizer) {
        self.view.endEditing(true)
    }
}

extension RegisterEditBaseViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.view.frame.origin.y = 0 - keyBoardSize
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.view.frame.origin.y = 0
    }
}

