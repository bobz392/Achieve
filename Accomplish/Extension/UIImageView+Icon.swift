//
//  UIImage+Icon.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/11.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func createIconImage(iconSize: CGFloat, imageSize: CGFloat,
                         icon: String, color: UIColor) {
        let icon = try! FAKFontAwesome(identifier: icon, size: iconSize)
        icon.addAttribute(NSForegroundColorAttributeName, value: color)
        let iconImage = icon.image(with: CGSize(width: imageSize, height: imageSize))
        self.image = iconImage
    }
}
