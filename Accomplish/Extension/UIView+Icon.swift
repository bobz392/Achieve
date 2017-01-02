//
//  UIButton+Icon.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/11.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

extension UIButton {
    
    func buttonWithIcon(icon: String, tintColor: UIColor = Colors.mainIconColor, backgroundColor: UIColor = UIColor.clear) {
        let image = UIImage(named:icon)?.withRenderingMode(.alwaysTemplate)
        self.contentMode = .scaleAspectFit
        self.setImage(image, for:.normal)
        self.tintColor = tintColor
        self.backgroundColor = backgroundColor
    }
}
