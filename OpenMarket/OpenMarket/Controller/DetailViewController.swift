//
//  DetailViewController.swift
//  OpenMarket
//
//  Created by 우롱차, Donnie on 2022/05/31.
//

import UIKit

final class DetailViewController: UIViewController {
    
    var productNumber: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        view = DetailView(frame: .zero)
    }
}
