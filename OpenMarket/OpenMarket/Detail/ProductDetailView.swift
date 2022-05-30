//
//  ProductDetailView.swift
//  OpenMarket
//
//  Created by dudu, safari on 2022/05/30.
//

import UIKit

final class ProductDetailView: UIView {
    private let baseScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var baseStackView: UIStackView = {
        let stackview = UIStackView(arrangedSubviews: [
            productImageCollectionView,
            nameAndStockStackView,
            priceStackView,
            descriptionLabel
        ])
        
        stackview.translatesAutoresizingMaskIntoConstraints = false
        stackview.axis = .vertical
        return stackview
    }()
    
    private let productImageCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .horizontalFullGrid)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        return collectionView
    }()
    
    private lazy var nameAndStockStackView: UIStackView = {
        let stackview = UIStackView(arrangedSubviews: [
            nameLabel,
            stockLabel
        ])
        return stackview
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .bold)
        return label
    }()
    
    private let stockLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray3
        label.textAlignment = .right
        label.setContentHuggingPriority(.lowest, for: .horizontal)
        return label
    }()
    
    private lazy var priceStackView: UIStackView = {
        let stackview = UIStackView(arrangedSubviews: [
            priceLabel,
            bargainPriceLabel
        ])
        stackview.axis = .vertical
        stackview.alignment = .trailing
        return stackview
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    private let bargainPriceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray3
        label.textAlignment = .center
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLayout() {
        addSubview(baseScrollView)
        baseScrollView.addSubview(baseStackView)
        
        NSLayoutConstraint.activate([
            baseScrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            baseScrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            baseScrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            baseScrollView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            baseStackView.topAnchor.constraint(equalTo: baseScrollView.topAnchor),
            baseStackView.bottomAnchor.constraint(equalTo: baseScrollView.bottomAnchor),
            baseStackView.leadingAnchor.constraint(equalTo: baseScrollView.leadingAnchor),
            baseStackView.trailingAnchor.constraint(equalTo: baseScrollView.trailingAnchor),
            baseStackView.widthAnchor.constraint(equalTo: baseScrollView.widthAnchor)
        ])
    }
    
    func configure(data: Product) {
        nameLabel.text = data.name
        
        priceLabel.text = data.price?.priceFormat(currency: data.currency?.rawValue)
        bargainPriceLabel.text = data.bargainPrice?.priceFormat(currency: data.currency?.rawValue)
        
        if data.price == data.bargainPrice {
            bargainPriceLabel.isHidden = true
            priceLabel.textColor = .systemGray3
        } else {
            bargainPriceLabel.isHidden = false
            priceLabel.textColor = .systemRed
            priceLabel.addStrikethrough()
        }
        
        stockLabel.textColor = data.stock == .zero ? .systemOrange : .systemGray3
        stockLabel.text = data.stock == .zero ? "품절" : "잔여수량: \(data.stock ?? .zero)"
        
        descriptionLabel.text = data.description
        descriptionLabel.text = """
                dummy Data dummy Data dummy Data dummy Data dummy Data dummy Data
                dummy Data dummy Data dummy Data dummy Data dummy Data dummy Data
                dummy Data dummy Data dummy Data dummy Data dummy Data dummy Data
                dummy Data dummy Data dummy Data dummy Data dummy Data dummy Data
                dummy Data dummy Data dummy Data dummy Data dummy Data dummy Data
                dummy Data dummy Data dummy Data dummy Data dummy Data dummy Data
                dummy Data dummy Data dummy Data dummy Data dummy Data dummy Data
                dummy Data dummy Data dummy Data dummy Data dummy Data dummy Data
                dummy Data dummy Data dummy Data dummy Data dummy Data dummy Data
        """
    }
}

// MARK: - CollectionView Layout

private extension UICollectionViewLayout {
    static let horizontalFullGrid: UICollectionViewCompositionalLayout = {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalHeight(1), heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }()
}

