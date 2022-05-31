//
//  String+Extension.swift
//  OpenMarket
//
//  Created by 우롱차, Donnie on 2022/05/24.
//

import UIKit

extension NSMutableAttributedString {
    convenience init(allText: String, redText: String) {
        self.init(string: allText)
        self.addAttribute(.foregroundColor, value: UIColor.red, range: (allText as NSString).range(of: redText))
        self.addAttribute(.strikethroughColor, value: UIColor.red, range: (allText as NSString).range(of: redText))
        self.addAttribute(.strikethroughStyle, value: 1, range: (allText as NSString).range(of: redText))
    }
}
