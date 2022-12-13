//
//  ItemRegistrationViewController.swift
//  OpenMarket
//
//  Created by minsson on 2022/08/14.
//

import UIKit

final class ItemRegistrationViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceHorizontal = true
        return scrollView
    }()
    
    private let addingPhotoButtonImageView: UIImageView = {
        let addingPhotoButtonImageView = UIImageView()
        addingPhotoButtonImageView.translatesAutoresizingMaskIntoConstraints = false
        addingPhotoButtonImageView.image = UIImage(systemName: "camera")
        addingPhotoButtonImageView.contentMode = .scaleAspectFit
        addingPhotoButtonImageView.tintColor = .systemGray
        addingPhotoButtonImageView.backgroundColor = .clear
        addingPhotoButtonImageView.layer.borderWidth = 0.3
        addingPhotoButtonImageView.layer.cornerRadius = 10
        addingPhotoButtonImageView.clipsToBounds = true
        return addingPhotoButtonImageView
    }()
    
    private let photoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        return stackView
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
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 2
        return stackView
    }()
    
    private lazy var discountedPriceTextField = editingTextField(placeholder: "할인금액")
    
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
    
    private var selectedPhotos: [UIImageView] = []
    
    // MARK: - Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUIComponents()
        configureComponents()
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
            
            addingPhotoButtonImageView.widthAnchor.constraint(equalToConstant: 100),
            addingPhotoButtonImageView.heightAnchor.constraint(equalToConstant: 100),
            
            photoStackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            photoStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            photoStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            photoStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            photoStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
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
        
        scrollView.addSubview(photoStackView)
        photoStackView.addArrangedSubview(addingPhotoButtonImageView)
        
        entireVerticalStackView.addArrangedSubview(scrollView)
        entireVerticalStackView.addArrangedSubview(nameTextField)
        entireVerticalStackView.addArrangedSubview(firstRowHorizontalStackView)
        entireVerticalStackView.addArrangedSubview(discountedPriceTextField)
        entireVerticalStackView.addArrangedSubview(stockTextField)
        entireVerticalStackView.addArrangedSubview(textView)
    }
}

// MARK: - Actions for configuration of Components

private extension ItemRegistrationViewController {

    func configureComponents() {
        configureDoneButton()
        configureImagePicker()
        configureAddingPhotoButtonImageView()
    }

    // MARK: - Actions for Done Button

    func configureDoneButton() {
        let doneButton = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(pushDataToServer)
        )

        self.navigationItem.rightBarButtonItem = doneButton
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
        
        let requestItem = RequestItem(
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

    @objc func pushDataToServer() {
        // TODO: 실제 선택된 이미지 모두 전송하도록 수정
        // TODO: 이미지 최대 5장까지 선택할 수 있도록 수정
        let image: UIImage = addingPhotoButtonImageView.image ?? UIImage()
        
        guard let inputData = assembleInputData() else {
            return
        }
        
        guard let request = OpenMarketAPIRequestPost(jsonData: inputData, image: image).urlRequest else {
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

extension ItemRegistrationViewController: UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        let selectedPhoto = UIImageView(image: image)
        selectedPhoto.layer.cornerRadius = 10
        selectedPhoto.clipsToBounds = true
        
        photoStackView.addArrangedSubview(selectedPhoto)
        selectedPhotos.append(selectedPhoto)
        
        dismiss(animated: true)
    }
}

// MARK: - UINavigationControllerDelegate

extension ItemRegistrationViewController: UINavigationControllerDelegate {

}

// MARK: - Nested Type

extension ItemRegistrationViewController {
    
    struct RequestItem: Encodable {
        
        let name: String?
        let price, discountedPrice: Double
        let currency: String
        let stock: Int
        let description: String
        let secret: String = "ebs12345"
        
        private enum CodingKeys: String, CodingKey {
            case name, price, currency, stock, description, secret
            case discountedPrice = "discounted_price"
        }
        
    }
    
}
