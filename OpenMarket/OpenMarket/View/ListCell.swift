//
//  ListCell.swift
//  OpenMarket
//
//  Created by cathy, mmim.
//

import UIKit

final class ListCell: UICollectionViewCell {
  static var identifier: String {
    return String(describing: self)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureListCell()
    self.contentView.layer.addBottomBorder()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  private let thumbnailImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()
  
  private let nameLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .left
    label.font = .systemFont(ofSize: FontSize.title, weight: .bold)
    return label
  }()
  
  private let priceLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .left
    label.font = .systemFont(ofSize: FontSize.body)
    label.textColor = .systemGray
    return label
  }()
  
  private let bargainPriceLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .left
    label.font = .systemFont(ofSize: FontSize.body)
    return label
  }()
  
  private let stockLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .right
    label.font = .systemFont(ofSize: FontSize.body)
    return label
  }()
  
  private let priceStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.alignment = .bottom
    stackView.distribution = .fill
    stackView.spacing = 5
    return stackView
  }()
  
  private let verticalStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.alignment = .leading
    stackView.distribution = .fill
    stackView.spacing = 5
    return stackView
  }()
  
  private let totalStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.alignment = .top
    stackView.distribution = .fill
    stackView.spacing = 5
    stackView.translatesAutoresizingMaskIntoConstraints = false
    return stackView
  }()
  
  override func prepareForReuse() {
    super.prepareForReuse()
    self.thumbnailImageView.image = UIImage(systemName: "goforward")
    self.nameLabel.text = nil
    self.stockLabel.text = nil
    self.bargainPriceLabel.text = nil
    self.priceLabel.text = nil
    self.priceLabel.attributedText = nil
    self.priceLabel.isHidden = false
  }
  
  private func configureListCell() {
    contentView.addSubview(totalStackView)
    totalStackView.axis = .horizontal
    totalStackView.addArrangedSubviews(thumbnailImageView, verticalStackView, stockLabel)
    verticalStackView.addArrangedSubviews(nameLabel, priceStackView)
    priceStackView.addArrangedSubviews(priceLabel, bargainPriceLabel)
    
    NSLayoutConstraint.activate([
      totalStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
      totalStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
      totalStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
      totalStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
      
      thumbnailImageView.widthAnchor.constraint(equalTo: thumbnailImageView.heightAnchor,
                                                multiplier: 1.1),
      
      verticalStackView.widthAnchor.constraint(equalTo: contentView.widthAnchor,
                                               multiplier: 0.4)
    ])
  }
  
  func setUpListCell(page: Page) {
    self.thumbnailImageView.load(urlString: page.thumbnail)
    self.nameLabel.text = page.name
    
    if page.discountedPrice == 0 {
      self.priceLabel.isHidden = true
      self.bargainPriceLabel.text = "\(page.currency)\(page.bargainPrice.convertCurrency())"
      self.bargainPriceLabel.textColor = .systemGray
    } else {
      self.priceLabel.textColor = .systemRed
      self.priceLabel.attributedText = "\(page.currency)\(page.price.convertCurrency())".strikeThrough()
      self.bargainPriceLabel.text = "\(page.currency)\(page.bargainPrice.convertCurrency())"
      self.bargainPriceLabel.textColor = .systemGray
    }
    
    if page.stock == 0 {
      self.stockLabel.textColor = .systemYellow
      self.stockLabel.text = "품절"
    } else {
      self.stockLabel.textColor = .systemGray
      makeStockLabel(page.stock)
    }
  }
  
  private func makeStockLabel(_ stock: Int) {
    let attributedString = NSMutableAttributedString(string: "잔여수량 : \(stock)")
    let imageAttachment = NSTextAttachment()
    imageAttachment.image = UIImage(systemName: "chevron.right")?.withRenderingMode(.alwaysTemplate)
    attributedString.append(NSAttributedString(attachment: imageAttachment))
    self.stockLabel.attributedText = attributedString
  }
}

