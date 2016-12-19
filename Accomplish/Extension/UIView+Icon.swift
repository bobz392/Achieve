//
//  UIButton+Icon.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/11.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

let backButtonIconString = "fa-arrow-left"

extension UIButton {
    
    func createIconButton(iconSize: CGFloat, imageSize: CGFloat = 0, icon: String,
                          color: UIColor, status: UIControlState = .normal) {
        guard let icon = try? FAKFontAwesome(identifier: icon, size: iconSize) else { return }
        icon.addAttribute(NSForegroundColorAttributeName, value: color)
        let size = imageSize > 0 ? CGSize(width: imageSize, height: imageSize) : CGSize(width: iconSize, height: iconSize)
        let iconImage = icon.image(with: size)
        self.tintColor = color
        self.setImage(iconImage, for: status)
    }
    
    func buttonColor(_ colors: Colors) {
        self.tintColor = Colors.mainIconColor
        self.backgroundColor = colors.cloudColor
    }
    
    func buttonWithIcon(icon: String) {
        let image = UIImage(named:icon)?.withRenderingMode(.alwaysTemplate)
        self.contentMode = .scaleAspectFit
        self.setImage(image, for:.normal)
        self.tintColor = Colors.mainIconColor
        self.backgroundColor = Colors.buttonBackgroundColor
    }
}

extension UILabel {
    func createIconText(iconSize: CGFloat, icon: String, color: UIColor) {
        let icon = try! FAKFontAwesome(identifier: icon, size: iconSize)
        icon.addAttribute(NSForegroundColorAttributeName, value: color)
        self.attributedText = icon.attributedString()
    }
}
