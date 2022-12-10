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

// MARK: - Actions for configuration of Components

private extension ItemRegistrationViewController {

    func configureComponents() {
        configureDoneButton()
        configureImagePicker()
        configureTargetForSegmentedControl()
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

    @objc func pushDataToServer() {
        // TODO: 실제 TextField에 입력된 데이터를 모아 request에 넣기
        
        let image: UIImage = addingPhotoButtonImageView.image ?? UIImage()
        
        guard let request = OpenMarketAPIRequestPost(image: image).urlRequest else {
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

    // MARK: - Actions for Segmented Control

    func configureTargetForSegmentedControl() {
        currencySegmentedControl.addTarget(
            self,
            action: #selector(switchCurrency),
            for: .valueChanged
        )
    }

    @objc func switchCurrency(segmentedControl: UISegmentedControl) {
        // TODO: 환율 고르는 게 POST 할 때 반영되도록 수정
        print("TODO: 환율 고르는 게 POST 할 때 반영되도록 수정")
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
        if let image = info[.originalImage] as? UIImage {
            self.addingPhotoButtonImageView.image = image
        }

        dismiss(animated: true)
    }
}

// MARK: - UINavigationControllerDelegate

extension ItemRegistrationViewController: UINavigationControllerDelegate {

}
