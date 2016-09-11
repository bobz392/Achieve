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
    
    func createIconButton(iconSize iconSize: CGFloat, imageSize: CGFloat,
                                   icon: String, color: UIColor, status: UIControlState) {
        let icon = try! FAKFontAwesome(identifier: icon, size: iconSize)
        icon.addAttribute(NSForegroundColorAttributeName, value: color)
        let iconImage = icon.imageWithSize(CGSize(width: imageSize, height: imageSize))
        self.tintColor = color
        self.setImage(iconImage, forState: status)
    }
    
    func buttonColor(colors: Colors) {
        self.tintColor = colors.mainGreenColor
        self.backgroundColor = colors.cloudColor
    }
}