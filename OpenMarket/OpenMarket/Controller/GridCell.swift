import UIKit

final class GridCell: UICollectionViewCell, CustomCell {
    
    private let cellStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let thumbnailImageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "flame")
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let informationStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        return stackView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name Label"
        label.contentMode = .scaleAspectFit
        return label
    }()
    
    private let pricestackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.text = "Price Label"
        label.textColor = .lightGray
        return label
    }()
    
    private let bargenLabel: UILabel = {
        let label = UILabel()
        label.text = "Bargen Label"
        label.textColor = .lightGray
        return label
    }()
    
    private let stockLabel: UILabel = {
        let label = UILabel()
        label.text = "Stock Label"
        label.textColor = .lightGray
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBorder()
        addSubViews()
        constraintLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBorder() {
        let border = layer.addBorder(edges: [.all], color: .systemGray, thickness: 1.5, radius: 15)
        layer.addSublayer(border)
    }
    
    func configure(data: Product) {
        loadImage(data: data)
        loadName(data: data)
        loadStock(data: data)
        loadPrice(data: data)
    }
    
    private func loadImage(data: Product) {
        
        guard let stringUrl = data.thumbnail else {
            return
        }
        
        guard let url = URL(string: stringUrl) else {
            return
        }
        
        thumbnailImageView.fetchImage(url: url) { image in
            DispatchQueue.main.async {
                self.thumbnailImageView.image = image
            }
        }
    }
    
    private func loadName(data: Product) {
        nameLabel.text = data.name
    }
    
    private func loadStock(data: Product) {
        
        if data.stock == 0 {
            stockLabel.text = "품절"
            stockLabel.textColor = .systemYellow
        } else {
            guard let stock = data.stock else {
                return
            }
            stockLabel.text = "재고수량: \(stock)"
        }
    }
    
    private func loadPrice(data: Product) {
        
        guard let currency = data.currency else {
            return
        }
        
        let price = Formatter.convertNumber(by: data.price?.description)
        let bargenPrice = Formatter.convertNumber(by: data.bargainPrice?.description)
        
        if data.discountedPrice == 0 {
            priceLabel.text = "\(currency) \(price)"
            bargenLabel.text = ""
        } else {
            priceLabel.textColor = .systemRed
            priceLabel.attributedText = "\(currency) \(price) ".strikeThrough()
            
            bargenLabel.text = "\(currency) \(bargenPrice)"
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        priceLabel.attributedText = nil
        bargenLabel.text = nil
        priceLabel.text = nil
        priceLabel.textColor = .lightGray
        stockLabel.textColor = .lightGray
    }
}

extension GridCell {
    private func addSubViews() {
        contentView.addsubViews(thumbnailImageView, cellStackView)
        cellStackView.addArrangedsubViews(informationStackView)
        informationStackView.addArrangedsubViews(nameLabel, pricestackView, stockLabel)
        pricestackView.addArrangedsubViews(priceLabel, bargenLabel)
    }
    
    private func constraintLayout() {
        NSLayoutConstraint.activate([
            thumbnailImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            thumbnailImageView.bottomAnchor.constraint(equalTo: cellStackView.topAnchor),
            thumbnailImageView.widthAnchor.constraint(equalToConstant: 150),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 150),
            thumbnailImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            cellStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            cellStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cellStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
}
