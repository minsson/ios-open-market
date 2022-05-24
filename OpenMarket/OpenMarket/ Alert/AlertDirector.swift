//
//  AlertDirector.swift
//  OpenMarket
//
//  Created by dudu, safari on 2022/05/20.
//

import UIKit

final class AlertDirector {
    private let viewController: UIViewController
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func createErrorAlert() {
        AlertBuilder(viewController: viewController)
            .setTitle("에러 발생")
            .setMessage("데이터를 불러오지 못했습니다.")
            .setOkActionTitle("확인")
            .show()
    }
    
    func createImageSelectActionSheet(albumAction: @escaping (UIAlertAction) -> Void, cameraAction: @escaping (UIAlertAction) -> Void) {
        AlertBuilder(viewController: viewController)
            .setPreferredStyle(.actionSheet)
            .setTitle("대충타이틀")
            .setMessage("대충메시지")
            .setOkActionTitle("앨범")
            .setCencelActionTitle("카메라")
            .setOkAction(albumAction)
            .setCencelAction(cameraAction)
            .show()
    }
}
