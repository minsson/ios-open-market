import UIKit

final class ProductRegisterViewController: UIViewController {
    //MARK: - Inner Type
    enum ImageSection: Hashable {
        case main
    }
    //MARK: - Typelias
    typealias collectionViewDataSource = UICollectionViewDiffableDataSource<ImageSection,UIImage>
    //MARK: - Property
    private var imageDataSource: collectionViewDataSource?
    private var imagePicker = UIImagePickerController()
    private var images: [UIImage] = []
    private var registerImage = RegisterImageView()
    private let postManager = PostManager()
    private var params: ProductPost.Request.Params?
    private var readyToPost: Bool?
   //MARK: View Life Cycle Method
    override func viewDidLoad() {
        readyToPost = false
        super.viewDidLoad()
        view.backgroundColor = .white
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissKey))
        view.addGestureRecognizer(gesture)
        gesture.cancelsTouchesInView = true
        imagePicker.delegate = self
        postManager.delegate = self
        
        configureCellDataSource()
        
        addSubviews()
        configureNavigationItem()
        configureUIItemLayouts()
        layoutMainVerticalScrollView()
        
        addTargetToRegisterImage()
    }
    //MARK: Method
    private func configureNavigationItem() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissRegisterView))
        navigationItem.title = "상품수정"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(post)
        )
    }
    
    private func addTargetToRegisterImage() {
        registerImage.addIndicaterButton.addTarget(nil, action: #selector(updateImage), for: .touchUpInside)
    }
    
    private func checkReadyToPost() {
        if productNameTextField.text?.count ?? .zero < 4 {
            alertFailure(state: .lessWord)
            return
        }
        
        if productStockTextField.text == nil {
            alertFailure(state: .lessWord)
            return
        }
        
        if textView.text.count < 11 {
            alertFailure(state: .lessWord)
            return
        }
        
        if images.isEmpty {
            alertFailure(state: .NoImage)
            return
        }
        
        if params == nil {
            alertFailure(state: .NoParams)
            return
        }
        readyToPost = true
    }
    //MARK: Configure CollectionView
    private func makeImageHorizontalLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.75), heightDimension: .fractionalHeight(1.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .flexible(10.0)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        section.orthogonalScrollingBehavior = .continuous
        let layout = UICollectionViewCompositionalLayout(section: section)

        return layout
    }
    
    private func configureCellDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<ImageCollectionViewCell, UIImage> {
            (cell, indexPath, item) in
        }
        
        imageDataSource = collectionViewDataSource(collectionView: imageCollectionView) {
            (collectionView, indexPath, item) -> UICollectionViewCell? in
            let cell = collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: item
            )
            cell.updateImage(to: item)
            
            return cell
        }
    }
    
    private func applyImageSnapShot() {
        var snapshot = NSDiffableDataSourceSnapshot<ImageSection, UIImage>()
        snapshot.appendSections([.main])
        snapshot.appendItems(images)
        self.imageDataSource?.apply(snapshot, animatingDifferences: false)
        print(snapshot.itemIdentifiers)
    }
    //MARK: UI Item Property
    private lazy var mainScrollView: UIScrollView = {
        var scrollView = UIScrollView(frame: .zero)
        scrollView.addSubview(registerImage)
        scrollView.addSubview(imageCollectionView)
        scrollView.addSubview(textFieldStackView)
        scrollView.addSubview(textView)
        return scrollView
    }()
    
    private lazy var imageCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeImageHorizontalLayout())

        return collectionView
    }()

    private lazy var productNameTextField: UITextField = {
        var textfield = UITextField()
        textfield.placeholder = "상품명"
        textfield.keyboardType = .default
        textfield.borderStyle = .roundedRect
        textfield.backgroundColor = .white
        textfield.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return textfield
    }()
    
    private lazy var productPriceTextField: UITextField = {
        var textfield = UITextField()
        textfield.placeholder = "가격"
        textfield.keyboardType = .numberPad
        textfield.borderStyle = .roundedRect
        textfield.backgroundColor = .white
        textfield.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return textfield
    }()
    
    private lazy var currencySegmentedControl: UISegmentedControl = {
        let items: [String] = ["KRW","USD"]
        var segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()
    
    private lazy var priceSegmentedStackview: UIStackView = {
       let stackView = UIStackView(arrangedSubviews: [
       productPriceTextField,
       currencySegmentedControl
       ])
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    private lazy var discountedProductTextField: UITextField = {
        var textfield = UITextField()
        textfield.placeholder = "할인"
        textfield.keyboardType = .numberPad
        textfield.borderStyle = .roundedRect
        textfield.backgroundColor = .white
        textfield.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return textfield
    }()
    
    private lazy var productStockTextField: UITextField = {
        var textfield = UITextField()
        textfield.placeholder = "재고"
        textfield.keyboardType = .numberPad
        textfield.borderStyle = .roundedRect
        textfield.backgroundColor = .white
        textfield.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return textfield
    }()
    
    private lazy var textFieldStackView: UIStackView = {
       var stackView = UIStackView(
        arrangedSubviews:[
        productNameTextField,
        priceSegmentedStackview,
        discountedProductTextField,
        productStockTextField
        ]
       )
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        return stackView
    }()
    
    private let textView: UITextView = {
        var textView = UITextView(frame: .zero)
        textView.backgroundColor = .white
        textView.insertText("상품의 정보를 입력하세요", alternatives: [""], style: .none)
        return textView
    }()
    //MARK: Action Method
    @objc private func dismissKey() {
        self.mainScrollView.endEditing(true)
    }
    
    @objc private func updateImage() {
        self.imagePicker.sourceType = .photoLibrary
        self.imagePicker.allowsEditing = true
        if images.count < 5 {
            self.present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    @objc private func dismissRegisterView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func post() {
        makeParams()
        givePostComponents()
        checkReadyToPost()
        
        if readyToPost ?? false {
            postManager.makeMultiPartFormData()
            alertSucess(state: .post)
        }
    }
   
    //MARK: AutoLayout
    private func addSubviews() {
        view.addSubview(mainScrollView)
    }
    
    private func configureUIItemLayouts() {
        layoutMainVerticalScrollView()
        layoutRegisterImage()
        layoutTextFieldStackView()
        layoutTextView()
        layoutImageCollectionView()
    }
    
    private func layoutRegisterImage() {
        registerImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            registerImage.leadingAnchor.constraint(equalTo: mainScrollView.frameLayoutGuide.leadingAnchor),
            registerImage.trailingAnchor.constraint(equalTo: mainScrollView.frameLayoutGuide.trailingAnchor),
            registerImage.topAnchor.constraint(equalTo: mainScrollView.contentLayoutGuide.topAnchor, constant: 10),
            registerImage.bottomAnchor.constraint(equalTo: textFieldStackView.topAnchor, constant: -20),
            registerImage.widthAnchor.constraint(equalTo: mainScrollView.frameLayoutGuide.widthAnchor, multiplier: 0.35),
            registerImage.heightAnchor.constraint(equalTo: mainScrollView.frameLayoutGuide.heightAnchor, multiplier: 0.25)
        ])
    }
    
    private func layoutImageCollectionView() {
        imageCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageCollectionView.topAnchor.constraint(equalTo: mainScrollView.contentLayoutGuide.topAnchor, constant: 10),
            imageCollectionView.leadingAnchor.constraint(equalTo: registerImage.trailingAnchor, constant: 5),
            imageCollectionView.bottomAnchor.constraint(equalTo: textFieldStackView.topAnchor, constant: -20),
            imageCollectionView.trailingAnchor.constraint(equalTo: mainScrollView.frameLayoutGuide.trailingAnchor)
        ])
    }
    
    private func layoutTextFieldStackView() {
        productNameTextField.translatesAutoresizingMaskIntoConstraints = false
        productPriceTextField.translatesAutoresizingMaskIntoConstraints = false
        currencySegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        priceSegmentedStackview.translatesAutoresizingMaskIntoConstraints = false
        discountedProductTextField.translatesAutoresizingMaskIntoConstraints = false
        productStockTextField.translatesAutoresizingMaskIntoConstraints = false
        textFieldStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            productPriceTextField.leadingAnchor.constraint(equalTo: mainScrollView.frameLayoutGuide.leadingAnchor, constant: 10),
            productPriceTextField.trailingAnchor.constraint(equalTo: currencySegmentedControl.leadingAnchor, constant: -10),
        ])
        NSLayoutConstraint.activate([
            currencySegmentedControl.trailingAnchor.constraint(
                equalTo: mainScrollView.frameLayoutGuide.trailingAnchor,
                constant: -10
            ),
        ])
        NSLayoutConstraint.activate([
            textFieldStackView.topAnchor.constraint(equalTo: registerImage.bottomAnchor, constant: 20),
            textFieldStackView.leadingAnchor.constraint(equalTo: mainScrollView.frameLayoutGuide.leadingAnchor, constant: 10),
            textFieldStackView.trailingAnchor.constraint(equalTo: mainScrollView.frameLayoutGuide.trailingAnchor, constant: -10)
        ])
    }
    
    private func layoutMainVerticalScrollView() {
        mainScrollView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mainScrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            mainScrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            mainScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func layoutTextView() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false
        
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: mainScrollView.frameLayoutGuide.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: mainScrollView.frameLayoutGuide.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo:mainScrollView.contentLayoutGuide.bottomAnchor),
            textView.topAnchor.constraint(equalTo: textFieldStackView.bottomAnchor, constant: 10)
        ])
    }
}
    //MARK: -ImagePickerController Extension 
extension ProductRegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var newImage: UIImage? = nil
       
       if let possibleImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
           newImage = possibleImage
       } else if let possibleImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
           newImage = possibleImage
       }
        guard let image = newImage?.resizing(size: CGSize(width: 50, height: 80)) else {
            return
        }
        
        images.append(image)
        applyImageSnapShot()
        imagePicker.dismiss(animated: true, completion: nil)
       }
}
    //MARK: - Alert
extension ProductRegisterViewController {
    
    enum PostMessage {
        enum Failure {
            case lessWord
            case NoImage
            case NoParams
            
            var description: String {
                switch self {
                case .lessWord:
                    return "글자수를 확인하세요."
                case .NoImage:
                    return "이미지를 1개 이상 등록해주세요."
                case .NoParams:
                    return "이미지를 1개 이상 등록해주세요."
                }
            }
        }
        
        enum Suceess {
            case post
            
            var description: String {
                switch self {
                case .post:
                    return "상품이 등록되었습니다."
                }
            }
        }
}
    
    func alertFailure(state: PostMessage.Failure) {
        let alert = UIAlertController(title: "상품등록 실패", message: state.description, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default))
        self.present(alert, animated: true, completion: nil)
    }
    
    func alertSucess(state: PostMessage.Suceess) {
        let alert = UIAlertController(title: "상품등록 성공", message: state.description, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { action in
            self.dismiss(animated: false)
        }
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}
    
extension ProductRegisterViewController: PostManagerDelegate {
    func makeParams() {
        let secretKey = "$4VptmhDPzSD3#zg"
        
        guard let price = Double(productPriceTextField.text ?? "0.0") else {
            return
        }
        
        guard let name = productNameTextField.text else {
            return
        }
        
        let discountPrice: Double = Double(discountedProductTextField.text ?? "0.0") ?? 0.0
        
        guard let stock: Int = Int(productStockTextField.text ?? "0") else {
            return
        }
        
        guard let currency: Currency = currencySegmentedControl.selectedSegmentIndex == 0 ? .KRW : .USD else {
            return
        }
        
        guard let description = textView.text else {
            return
        }
        
        params = ProductPost.Request.Params(
            name: name,
            descriptions: description,
            price: price,
            currency: currency,
            discountedPrice: discountPrice,
            stock: stock,
            secret: secretKey
        )
    }

    func givePostComponents() {
        guard let params = params else {
            return
        }
        postManager.loadComponents(images: images, params: params)
    }
}
