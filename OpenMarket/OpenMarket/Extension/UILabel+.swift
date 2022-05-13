//
//  UILabel+.swift
//  OpenMarket
//
//  Created by dudu, safari on 2022/05/14.
//

import UIKit

extension UILabel {
    func addStrikethrough() {
        guard let text = self.text else { return }
        
        let attributeString = NSMutableAttributedString(string: text)
        attributeString.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0, attributeString.length))
        attributedText = attributeString
    }
}
