//
//  RegisterViewModel.swift
//  OpenMarket
//
//  Created by 박세리 on 2022/05/24.
//
import UIKit

final class RegisterViewModel: ManagingViewModel, NotificationPostable {
    func requestPost(_ productUpload: ProductRequest, completion: @escaping () -> ()) {
        let endpoint = EndPointStorage.productPost(productUpload)
        
        productsAPIServie.registerProduct(with: endpoint) { [weak self] result in
            switch result {
            case .success():
                self?.postNotification()
                completion()
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.delegate?.showAlertRequestError(with: error)
                }
            }
        }
    }
    
    func setUpDefaultImage() {
        guard let plus = UIImage(named: Constants.plus)?.pngData() else { return }
        let plusImage = ImageInfo(fileName: Constants.plus, data: plus, type: Constants.png)
        applySnapshot(image: plusImage)
    }
    
    func insert(imageData: Data) {
        let imageInfo = ImageInfo(fileName: generateUUID(), data: imageData, type: Constants.jpg)
        
        DispatchQueue.main.async {
            guard let lastItem = self.snapshot?.itemIdentifiers.last else { return }
            self.snapshot?.insertItems([imageInfo], beforeItem: lastItem)
            guard let snapshot = self.snapshot else {
                return
            }
            self.datasource?.apply(snapshot)
        }
    }
    
    func removeLastImage() {
        guard let lastImage = snapshot?.itemIdentifiers.last else {
            return
        }
        snapshot?.deleteItems([lastImage])
    }
}
