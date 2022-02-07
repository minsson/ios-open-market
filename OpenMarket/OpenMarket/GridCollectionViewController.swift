import UIKit

final class GridCollectionViewController: UIViewController {
    
    typealias Product = NetworkingAPI.ProductListQuery.Response.Page
    
    enum LayoutAttribute {
        static let estimatedHeight: CGFloat = 220
        static let itemsPerGroup = 2
        static let largeSpacing: CGFloat = 10
        static let smallSpacing: CGFloat = 5
    }
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, Product>!
    weak var viewPresentationDelegate: MainViewController?
    
    //MARK: - Life Cycle
    override func loadView() {
        super.loadView()
        create()
        organizeViewHierarchy()
        configure()
    }
    
    func applySnapShot(products: [Product]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Product>()
        snapshot.appendSections([.main])
        snapshot.appendItems(products)
        self.dataSource.apply(snapshot, animatingDifferences: false)
    }
}

//MARK: - Private Method
extension GridCollectionViewController: UICollectionViewDelegate {
    private func create() {
        createCollectionView()
        createDataSource()
    }
    
    private func organizeViewHierarchy() {
        view.addSubview(collectionView)
    }
    
    private func configure() {
        configureCollectionView()
        configureCollectionViewDelegate()
    }

    //MARK: - CollectionView
    private func createCollectionView() {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(LayoutAttribute.estimatedHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(LayoutAttribute.estimatedHeight)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: item,
            count: LayoutAttribute.itemsPerGroup
        )
        group.interItemSpacing = .fixed(LayoutAttribute.largeSpacing)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = LayoutAttribute.largeSpacing
        section.contentInsets.leading = LayoutAttribute.smallSpacing
        section.contentInsets.trailing = LayoutAttribute.smallSpacing
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
    }
    
    private func configureCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    //MARK: - DataSource
    private enum Section: Hashable {
        case main
    }

    private func createDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<CollectionViewGridCell, Product> {
            (cell, indexPath, item) in
        }
      
        dataSource = UICollectionViewDiffableDataSource<Section, Product>(collectionView: collectionView) {
            (collectionView, indexPath, item) -> UICollectionViewCell? in
            let cell = collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: item
            )
            cell.currentThumbnailURL = item.thumbnail
            cell.update(from: item)
            
            return cell
        }
    }

    //MARK: - Delegate
    private func configureCollectionViewDelegate() {
        collectionView.delegate = self
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let id = dataSource.itemIdentifier(for: indexPath)?.id else {
            collectionView.deselectItem(at: indexPath, animated: true)
            return
        }
        
        NetworkingAPI.ProductDeleteSecretQuery.request(session: URLSession.shared,
                                                       productId: id,
                                                       identifier: Vendor.identifier,
                                                       secret: Vendor.secret) {
            
            result in
            
            switch result {
            case .success(let data):
                print("상품 \(id)의 secret은 \(String(decoding: data, as: UTF8.self))입니다")
            case .failure(let error):
                UIAlertController.simpleAlert(message: "상품 secret 조회에 실패했습니다\n\(error.description)", presentationDelegate: self)
            }
        }
        
        viewPresentationDelegate?.pushViewController(ProductDetailViewController(), withProductId: id)
    }
}
