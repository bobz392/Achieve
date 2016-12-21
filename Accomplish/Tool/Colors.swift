//
//  Colors.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/24.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

struct Colors {
    fileprivate static var type: Int? = nil
    static var backgroundType: MainColorType {
        get {
            guard let t = self.type else {
                let ud = AppUserDefault()
                let background = ud.readInt(kUserDefaultBackgroundKey)
                self.type = background
                return MainColorType(rawValue: background) ?? .greenSea
            }
            return MainColorType(rawValue: t) ?? .greenSea
        }
        
        set (value) {
            self.type = value.rawValue
            AppUserDefault().write(kUserDefaultBackgroundKey, value: value.rawValue)
        }
    }
    
    let mainGreenColor = Colors.backgroundType.mianColor()
    let selectedColor = Colors.backgroundType.selectedColor()
    
    let cloudColor = UIColor(red:0.93, green:0.94, blue:0.95, alpha:1.00)
    let separatorColor = UIColor(red:0.74, green:0.76, blue:0.78, alpha:1.00)
    let priorityHighColor = UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.00)
    let priorityNormalColor = UIColor(red:0.93, green:0.94, blue:0.95, alpha:1.00)
    let priorityLowColor = UIColor(red:0.95, green:0.77, blue:0.06, alpha:1.00)
    
    let placeHolderTextColor = UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.00)
    let linkTextColor = UIColor(red:0.20, green:0.60, blue:0.86, alpha:1.00)
    let progressColor = UIColor(red:0.98, green:0.75, blue:0.23, alpha:1.00)
    let systemGreenColor = UIColor(red:0.34, green:0.85, blue:0.42, alpha:1.00)
    let systemRedColor = UIColor(red:0.98, green:0.24, blue:0.22, alpha:1.00)
    
    static let mainBackgroundColor = UIColor(red:0.95, green:0.95, blue:0.97, alpha:1.00)
    static let mainIconColor = UIColor(red:0.59, green:0.62, blue:0.69, alpha:1.00)
    static let cellCardColor = UIColor(red:0.99, green:0.99, blue:1.00, alpha:1.00)
    static let buttonBackgroundColor = UIColor(red:0.93, green:0.94, blue:0.95, alpha:1.00)
    static let mainTextColor = UIColor(red:0.17, green:0.24, blue:0.31, alpha:1.00)
    static let secondaryTextColor = UIColor(red:0.58, green:0.65, blue:0.65, alpha:1.00)
    static let headerTextColor = UIColor(red:0.80, green:0.81, blue:0.85, alpha:1.00)
    static let linkButtonTextColor = UIColor(red:0.20, green:0.60, blue:0.86, alpha:1.00)
}

enum MainColorType: Int {
    case greenSea = 0
    case teal
    case nephritis
    case belizeHole
    case wisteria
    case wetAsphalt
    case coffee
    case redWine
    
    static func count() -> Int {
        return 8
    }
    
    func mianColor() -> UIColor {
        
        switch self {
            
        case .greenSea:
            return UIColor(red:0.09, green:0.63, blue:0.52, alpha:1.00)
        case .nephritis:
            return UIColor(red:0.15, green:0.68, blue:0.38, alpha:1.00)
        case .wisteria:
            return UIColor(red:0.71, green:0.19, blue:0.40, alpha:1.00)
        case .belizeHole:
            return UIColor(red:0.16, green:0.50, blue:0.73, alpha:1.00)
        case .redWine:
            return UIColor(red:0.86, green:0.27, blue:0.33, alpha:1.00)
        case .wetAsphalt:
            return UIColor(red:0.20, green:0.29, blue:0.37, alpha:1.00)
        case .teal:
            return UIColor(red:0.00, green:0.59, blue:0.53, alpha:1.00)
        case .coffee:
            return UIColor(red:0.56, green:0.44, blue:0.25, alpha:1.00)
        }
    }
    
    func selectedColor() -> UIColor {
        switch self {
        case .greenSea:
            return UIColor(red:0.09, green:0.63, blue:0.52, alpha:0.3)
        case .nephritis:
            return UIColor(red:0.15, green:0.68, blue:0.38, alpha:0.3)
        case .wisteria:
            return UIColor(red:0.71, green:0.19, blue:0.40, alpha:0.3)
        case .belizeHole:
            return UIColor(red:0.16, green:0.50, blue:0.73, alpha:0.3)
        case .redWine:
            return UIColor(red:0.86, green:0.27, blue:0.33, alpha:0.3)
        case .wetAsphalt:
            return UIColor(red:0.20, green:0.29, blue:0.37, alpha:0.3)
        case .teal:
            return UIColor(red:0.00, green:0.59, blue:0.53, alpha:0.3)
        case .coffee:
            return UIColor(red:0.56, green:0.44, blue:0.25, alpha:0.3)
        }
    }
    
    func setThisColorForMain() {
        Colors.backgroundType = self
    }
}
