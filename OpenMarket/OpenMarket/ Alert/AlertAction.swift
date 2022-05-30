//
//  AlertAction.swift
//  OpenMarket
//
//  Created by dudu, safari on 2022/05/20.
//

import UIKit

struct AlertAction {
    var title: String?
    var style: UIAlertAction.Style = .default
    var action: ((UIAlertAction) -> Void)?
}
