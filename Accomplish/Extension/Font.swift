//
//  Font.swift
//  Accomplish
//
//  Created by zhoubo on 2017/3/23.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit

extension UILabel {
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        self.font = appFont(size: self.font.pointSize)
    }
}

func appFont(size: CGFloat, weight: CGFloat = UIFontWeightRegular) -> UIFont {
    if currentPreferrenLang()?.hasPrefix("en") == true,
        let font = UIFont(name: "Avenir Next", size: size) {
        return font
    } else {
        return UIFont.systemFont(ofSize: size, weight: weight)
    }
}

func currentPreferrenLang() -> String? {
    return UserDefaults.standard.array(forKey: "AppleLanguages")?.first as? String
}
