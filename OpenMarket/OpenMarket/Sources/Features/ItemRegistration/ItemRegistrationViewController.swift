//
//  ItemRegistrationViewController.swift
//  OpenMarket
//
//  Created by minsson on 2022/08/14.
//

import UIKit

final class ItemRegistrationViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let addingPhotoButtonImageView: UIImageView = {
        // TODO: 추후 Image Picker 및 선택된 사진들을 보여주기 위한 컬렉션 뷰로 대체
        let addingPhotoButtonImageView = UIImageView()
        addingPhotoButtonImageView.image = UIImage(systemName: "plus")
        addingPhotoButtonImageView.backgroundColor = .gray
        addingPhotoButtonImageView.layer.cornerRadius = 10
        addingPhotoButtonImageView.clipsToBounds = true
        return addingPhotoButtonImageView
    }()
    
    private lazy var nameTextField = editingTextField(placeholder: "상품명")
    
    private lazy var priceTextField = editingTextField(placeholder: "상품가격")
    
    private let currencySegmentedControl: UISegmentedControl = {
        let selectionItems = [
            UIImage(systemName: "wonsign"),
            UIImage(systemName: "dollarsign")
        ]
        let segmentedControl = UISegmentedControl(items: selectionItems as [Any])
        segmentedControl.selectedSegmentIndex = Currency.krw.index
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()
    
    private let firstRowHorizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 2
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var bargainPriceTextField = editingTextField(placeholder: "할인금액")
    
    private lazy var stockTextField = editingTextField(placeholder: "재고수량")
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.keyboardDismissMode = .interactive
        textView.font = .preferredFont(forTextStyle: .body)
        return textView
    }()
    
    private let entireVerticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Properties
    
    private let imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        return imagePicker
    }()
    
    // MARK: - Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUIComponents()
    }
}

// MARK: - Private Actions for UI

private extension ItemRegistrationViewController {
    
    // MARK: - Private Actions for AutoLayout
    
    func setupUIComponents() {
        addViews()
        addArrangedSubViews()
        setupLayoutConstraints()
    }
    
    func setupLayoutConstraints() {
        NSLayoutConstraint.activate([
            currencySegmentedControl.widthAnchor.constraint(equalToConstant: 100),
            
            addingPhotoButtonImageView.heightAnchor.constraint(equalToConstant: 80),
            
            entireVerticalStackView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            entireVerticalStackView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor
            ),
            entireVerticalStackView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 16
            ),
            entireVerticalStackView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -16
            )
        ])
    }
    
    // MARK: - Actions for Adding UIComponents
    
    func editingTextField(placeholder: String) -> UITextField {
        let editingTextField: UITextField = {
            let editingTextField = UITextField()
            editingTextField.placeholder = placeholder
            editingTextField.font = .boldSystemFont(ofSize: 18)
            editingTextField.borderStyle = .roundedRect
            return editingTextField
        }()
        
        return editingTextField
    }
    
    func addViews() {
        view.addSubview(entireVerticalStackView)
    }
    
    func addArrangedSubViews() {
        firstRowHorizontalStackView.addArrangedSubview(priceTextField)
        firstRowHorizontalStackView.addArrangedSubview(currencySegmentedControl)
        
        entireVerticalStackView.addArrangedSubview(addingPhotoButtonImageView)
        entireVerticalStackView.addArrangedSubview(nameTextField)
        entireVerticalStackView.addArrangedSubview(firstRowHorizontalStackView)
        entireVerticalStackView.addArrangedSubview(bargainPriceTextField)
        entireVerticalStackView.addArrangedSubview(stockTextField)
        entireVerticalStackView.addArrangedSubview(textView)
    }
}
