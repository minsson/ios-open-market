//
//  ItemSellingViewController.swift
//  OpenMarket
//
//  Created by minsson on 2022/12/22.
//

import UIKit

class ItemSellingViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let headerStackView: UIStackView = {
        let headerStackView = UIStackView()
        headerStackView.translatesAutoresizingMaskIntoConstraints = false
        headerStackView.axis = .horizontal
        headerStackView.distribution = .equalCentering
        return headerStackView
    }()
    
    private let closeButton: UIButton = {
        let closeButton = UIButton()
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .label
        return closeButton
    }()
    
    let viewTitleLabel: UILabel = {
        let viewTitleLabel = UILabel()
        viewTitleLabel.text = ""
        viewTitleLabel.textAlignment = .center
        return viewTitleLabel
    }()
    
    let doneButton: UIButton = {
        let doneButton = UIButton()
        doneButton.setTitle("완료", for: .normal)
        doneButton.setTitleColor(.systemPurple, for: .normal)
        return doneButton
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceHorizontal = true
        return scrollView
    }()
    
    let addingPhotoButtonImageView: UIImageView = {
        let addingPhotoButtonImageView = UIImageView()
        addingPhotoButtonImageView.image = UIImage(systemName: "camera")
        addingPhotoButtonImageView.contentMode = .scaleAspectFit
        addingPhotoButtonImageView.tintColor = .systemGray
        addingPhotoButtonImageView.backgroundColor = .clear
        addingPhotoButtonImageView.layer.borderWidth = 0.3
        addingPhotoButtonImageView.layer.cornerRadius = 10
        addingPhotoButtonImageView.clipsToBounds = true
        return addingPhotoButtonImageView
    }()
    
    let photoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    lazy var nameTextField = editingTextField(placeholder: "상품명")
    
    lazy var priceTextField = editingTextField(placeholder: "상품가격")
    
    let currencySegmentedControl: UISegmentedControl = {
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
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 2
        return stackView
    }()
    
    lazy var discountedPriceTextField = editingTextField(placeholder: "할인금액")
    
    lazy var stockTextField = editingTextField(placeholder: "재고수량")
    
    let textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.keyboardDismissMode = .interactive
        textView.font = .preferredFont(forTextStyle: .body)
        return textView
    }()
    
    private let entireVerticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fill
        return stackView
    }()
    
    // MARK: - Properties
    
    private let imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        return imagePicker
    }()
    
    var selectedPhotos: [UIImage] = []
    
    // MARK: - Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCloseButton()
        setupUIComponents()
        configureComponents()
    }
}

// MARK: - Private Actions for UI

private extension ItemSellingViewController {
    
    func setupRootView() {
        view.backgroundColor = .systemBackground
    }
    
    func setupUIComponents() {
        addSubViews()
        setupLayoutConstraints()
    }
    
    func addSubViews() {
        view.addSubview(headerStackView)
        view.addSubview(entireVerticalStackView)
        
        headerStackView.addArrangedSubview(closeButton)
        headerStackView.addArrangedSubview(viewTitleLabel)
        headerStackView.addArrangedSubview(doneButton)

        entireVerticalStackView.addArrangedSubview(scrollView)
        entireVerticalStackView.addArrangedSubview(nameTextField)
        entireVerticalStackView.addArrangedSubview(firstRowHorizontalStackView)
        entireVerticalStackView.addArrangedSubview(discountedPriceTextField)
        entireVerticalStackView.addArrangedSubview(stockTextField)
        entireVerticalStackView.addArrangedSubview(textView)
        
        scrollView.addSubview(photoStackView)
        
        firstRowHorizontalStackView.addArrangedSubview(priceTextField)
        firstRowHorizontalStackView.addArrangedSubview(currencySegmentedControl)
        
        photoStackView.addArrangedSubview(addingPhotoButtonImageView)
    }
    
    func setupLayoutConstraints() {
        let spaceToEdge: CGFloat = 16
        
        NSLayoutConstraint.activate([
            headerStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: spaceToEdge),
            headerStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -spaceToEdge),
            
            closeButton.leadingAnchor.constraint(equalTo: headerStackView.leadingAnchor),
            viewTitleLabel.centerXAnchor.constraint(equalTo: headerStackView.centerXAnchor),
            doneButton.trailingAnchor.constraint(equalTo: headerStackView.trailingAnchor),
             
            photoStackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            photoStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            photoStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            photoStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            photoStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
            addingPhotoButtonImageView.widthAnchor.constraint(equalToConstant: 100),
            addingPhotoButtonImageView.heightAnchor.constraint(equalToConstant: 100),
            
            entireVerticalStackView.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: spaceToEdge),
            entireVerticalStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            entireVerticalStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: spaceToEdge),
            entireVerticalStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -spaceToEdge),
            
            currencySegmentedControl.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
    
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
    
}

// MARK: - Actions for configuration of Components

private extension ItemSellingViewController {
    
    func configureComponents() {
        configureImagePicker()
        configureAddingPhotoButtonImageView()
    }

    // MARK: - Actions for Close Button
    
    func configureCloseButton() {
        closeButton.addTarget(self, action: #selector(closeButtonDidTap), for: .touchUpInside)
    }
    
    @objc func closeButtonDidTap() {
        dismiss(animated: true)
    }
    
    // MARK: - Actions for Image Picker

    func configureImagePicker() {
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
    }

    @objc func openImagePicker() {
        present(imagePicker, animated: true)
    }

    // MARK: - Actions for AddingPhotoButtonImageView

    func configureAddingPhotoButtonImageView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openImagePicker))
        addingPhotoButtonImageView.addGestureRecognizer(tapGesture)
        addingPhotoButtonImageView.isUserInteractionEnabled = true
    }
}

// MARK: - UIImagePickerControllerDelegate

extension ItemSellingViewController: UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        let selectedPhoto = UIImageView(image: image)
        selectedPhoto.layer.cornerRadius = 10
        selectedPhoto.clipsToBounds = true
        photoStackView.addArrangedSubview(selectedPhoto)
        
        selectedPhotos.append(image)
        
        dismiss(animated: true)
    }
    
}

// MARK: - UINavigationControllerDelegate

extension ItemSellingViewController: UINavigationControllerDelegate {

}

// MARK: - Nested Type

extension ItemSellingViewController {
    
    struct Item: Encodable {
        
        let name: String?
        let price, discountedPrice: Double
        let currency: String
        let stock: Int
        let description: String
        let secret: String = "ebs12345"
        let thumbnailID: Int? = nil
        
        private enum CodingKeys: String, CodingKey {
            case name, price, currency, stock, description, secret
            case discountedPrice = "discounted_price"
            case thumbnailID = "thumbnail_id"
        }
        
    }
    
}
