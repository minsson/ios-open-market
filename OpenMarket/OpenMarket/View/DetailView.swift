//
//  DetailView.swift
//  OpenMarket
//
//  Created by cathy, mmim.
//

import UIKit

final class DetailView: UIView {
  enum Constants {
    static let title: Double = 16.0
    static let body: Double = 15.0
    static let spacing: Double = 5.0
    static let margin: Double = 20.0
    static let heightScale: Double = 0.4
  }
  
  init() {
    super.init(frame: .zero)
    self.backgroundColor = .white
    self.translatesAutoresizingMaskIntoConstraints = false
    configureLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  //MARK: - Top part of View
  private let imageScrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.isPagingEnabled = true
    scrollView.isScrollEnabled = true
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.backgroundColor = .white
    return scrollView
  }()
  
  private let pageControl: UIPageControl = {
    let pageControl = UIPageControl()
    pageControl.pageIndicatorTintColor = .systemGray5
    pageControl.currentPageIndicatorTintColor = .systemGray
    return pageControl
  }()
  
  //MARK: - Middle part of View
  private let nameLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .left
    label.font = .systemFont(ofSize: Constants.title, weight: .bold)
    label.numberOfLines = 0
    return label
  }()
  
  private let priceLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .right
    label.font = .systemFont(ofSize: Constants.body)
    label.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    label.textColor = .systemGray
    return label
  }()
  
  private let bargainPriceLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .right
    label.font = .systemFont(ofSize: Constants.body)
    return label
  }()
  
  private let stockLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .right
    label.font = .systemFont(ofSize: Constants.body)
    return label
  }()
  
  private let verticalStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.alignment = .trailing
    stackView.distribution = .fillEqually
    stackView.spacing = Constants.spacing
    stackView.setContentCompressionResistancePriority(.required, for: .horizontal)
    return stackView
  }()
  
  private let infoStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.alignment = .top
    stackView.distribution = .fill
    stackView.layoutMargins = UIEdgeInsets(
      top: Constants.margin,
      left: 0,
      bottom: Constants.margin,
      right: 0
    )
    stackView.isLayoutMarginsRelativeArrangement = true
    return stackView
  }()
  
  //MARK: - Bottom part of View
  private let descriptionScrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.isScrollEnabled = true
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    return scrollView
  }()
  
  private let descriptionView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  private let descriptionLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 0
    label.textAlignment = .left
    label.font = .systemFont(ofSize: Constants.body)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private let totalStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.alignment = .fill
    stackView.distribution = .fill
    stackView.translatesAutoresizingMaskIntoConstraints = false
    return stackView
  }()
  
  private func configureLayout() {
    self.addSubview(totalStackView)
    totalStackView.addArrangedSubviews(
      imageScrollView,
      pageControl,
      infoStackView,
      descriptionScrollView
    )
    infoStackView.addArrangedSubviews(
      nameLabel,
      verticalStackView
    )
    verticalStackView.addArrangedSubviews(
      stockLabel,
      priceLabel,
      bargainPriceLabel
    )
    descriptionScrollView.addSubview(descriptionView)
    descriptionView.addSubview(descriptionLabel)
    
    NSLayoutConstraint.activate([
      totalStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      totalStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      totalStackView.topAnchor.constraint(equalTo: self.topAnchor),
      totalStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
      
      imageScrollView.heightAnchor.constraint(
        equalTo: self.heightAnchor,
        multiplier: Constants.heightScale
      ),
      
      descriptionLabel.leadingAnchor.constraint(equalTo: descriptionView.leadingAnchor),
      descriptionLabel.trailingAnchor.constraint(equalTo: descriptionView.trailingAnchor),
      descriptionLabel.topAnchor.constraint(equalTo: descriptionView.topAnchor),
      descriptionLabel.bottomAnchor.constraint(equalTo: descriptionView.bottomAnchor),
      
      descriptionView.leadingAnchor.constraint(
        equalTo: descriptionScrollView.contentLayoutGuide.leadingAnchor
      ),
      descriptionView.trailingAnchor.constraint(
        equalTo: descriptionScrollView.contentLayoutGuide.trailingAnchor
      ),
      descriptionView.topAnchor.constraint(
        equalTo: descriptionScrollView.contentLayoutGuide.topAnchor
      ),
      descriptionView.bottomAnchor.constraint(
        equalTo: descriptionScrollView.contentLayoutGuide.bottomAnchor
      ),
      descriptionView.widthAnchor.constraint(
        equalTo: descriptionScrollView.widthAnchor, multiplier: 1
      ),
      pageControl.topAnchor.constraint(equalTo: imageScrollView.bottomAnchor)
    ])
  }
  
  func setUpDetailInformation(of detailProduct: DetailProduct?) {
    guard let price = detailProduct?.price?.formatToDecimal(),
          let bargainPrice = detailProduct?.bargainPrice?.formatToDecimal(),
          let stock = detailProduct?.stock?.formatToDecimal(),
          let images = detailProduct?.images,
          let currency = detailProduct?.currency.text
    else {
      return
    }
    pageControl.numberOfPages = images.count
    
    self.nameLabel.text = detailProduct?.name
    self.descriptionLabel.text = detailProduct?.description
    
    if detailProduct?.discountedPrice == 0 {
      self.priceLabel.isHidden = true
      self.bargainPriceLabel.text = "\(currency) \(bargainPrice)"
    } else {
      self.priceLabel.textColor = .systemRed
      self.priceLabel.attributedText = "\(currency) \(price)".strikeThrough()
      self.bargainPriceLabel.text = "\(currency) \(bargainPrice)"
    }
    
    if detailProduct?.stock == 0 {
      self.stockLabel.textColor = .systemYellow
      self.stockLabel.text = "품절"
    } else {
      self.stockLabel.textColor = .systemGray
      self.stockLabel.text = "남은 수량 : \(stock)"
    }
  }
  
  func setCurrentPage(_ pageNumber: Int) {
    pageControl.currentPage = pageNumber
  }
  
  func setScrollViewDelegate(delegate: UIScrollViewDelegate?) {
    self.imageScrollView.delegate = delegate
  }
  
  func addInScrollView(_ imageView: UIImageView, _ index: Int) {
    let width = self.imageScrollView.frame.width
    let height = self.imageScrollView.frame.height
    let margin = (width - height) / 2
    let originX = (self.frame.width * CGFloat(index)) + margin
    imageView.frame = CGRect(
      x: originX,
      y: 0,
      width: self.imageScrollView.frame.height,
      height: self.imageScrollView.frame.height
    )
    self.imageScrollView.addSubview(imageView)
    let scrollViewContentWidth = self.imageScrollView.frame.width * CGFloat(index + 1)
    self.imageScrollView.contentSize.width = scrollViewContentWidth
  }
}
