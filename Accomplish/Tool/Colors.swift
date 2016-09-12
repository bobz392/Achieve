//
//  Colors.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/24.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

struct Colors {
    private static var type: Int? = nil
    static var backgroundType: MainColorType {
        get {
            guard let t = self.type else {
                let ud = UserDefault()
                let background = ud.readInt(kBackgroundKey)
                self.type = background
                return MainColorType(rawValue: background) ?? .GreenSea
            }
            return MainColorType(rawValue: t) ?? .GreenSea
        }
        
        set (value) {
            self.type = value.rawValue
            UserDefault().write(kBackgroundKey, value: value.rawValue)
        }
    }
    
    let mainGreenColor = Colors.backgroundType.mianColor()
    let selectedColor = Colors.backgroundType.selectedColor()
    
    let cloudColor = UIColor(red:0.93, green:0.94, blue:0.95, alpha:1.00)
    let separatorColor = UIColor(red:0.74, green:0.76, blue:0.78, alpha:1.00)
    let priorityHighColor = UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.00)
    let priorityNormalColor = UIColor(red:0.93, green:0.94, blue:0.95, alpha:1.00)
    let priorityLowColor = UIColor(red:0.95, green:0.77, blue:0.06, alpha:1.00)
    let mainTextColor = UIColor(red:0.17, green:0.24, blue:0.31, alpha:1.00)
    let secondaryTextColor = UIColor(red:0.58, green:0.65, blue:0.65, alpha:1.00)
    let placeHolderTextColor = UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.00)
    let linkTextColor = UIColor(red:0.20, green:0.60, blue:0.86, alpha:1.00)
    let progressColor = UIColor(red:0.98, green:0.75, blue:0.23, alpha:1.00)
}

enum MainColorType: Int {
    case GreenSea = 0
    case Teal
    case Nephritis
    case BelizeHole
    case Wisteria
    case WetAsphalt
    case Coffee
    case RedWine
    
    static func count() -> Int {
        return 8
    }
    
    func mianColor() -> UIColor {
        
        switch self {
        case .GreenSea:
            return UIColor(red:0.09, green:0.63, blue:0.52, alpha:1.00)
        case .Nephritis:
            return UIColor(red:0.15, green:0.68, blue:0.38, alpha:1.00)
        case .Wisteria:
            return UIColor(red:0.71, green:0.19, blue:0.40, alpha:1.00)
        case .BelizeHole:
            return UIColor(red:0.16, green:0.50, blue:0.73, alpha:1.00)
        case .RedWine:
            return UIColor(red:0.67, green:0.16, blue:0.18, alpha:1.00)
        case .WetAsphalt:
            return UIColor(red:0.20, green:0.29, blue:0.37, alpha:1.00)
        case .Teal:
            return UIColor(red:0.00, green:0.59, blue:0.53, alpha:1.00)
        case .Coffee:
            return UIColor(red:0.56, green:0.44, blue:0.25, alpha:1.00)
        }
    }
    
    func selectedColor() -> UIColor {
        switch self {
        case .GreenSea:
            return UIColor(red:0.09, green:0.63, blue:0.52, alpha:0.3)
        case .Nephritis:
            return UIColor(red:0.15, green:0.68, blue:0.38, alpha:0.3)
        case .Wisteria:
            return UIColor(red:0.71, green:0.19, blue:0.40, alpha:0.4)
        case .BelizeHole:
            return UIColor(red:0.16, green:0.50, blue:0.73, alpha:0.3)
        case .RedWine:
            return UIColor(red:0.67, green:0.16, blue:0.18, alpha:0.3)
        case .WetAsphalt:
            return UIColor(red:0.20, green:0.29, blue:0.37, alpha:0.3)
        case .Teal:
            return UIColor(red:0.00, green:0.59, blue:0.53, alpha:0.3)
        case .Coffee:
            return UIColor(red:0.56, green:0.44, blue:0.25, alpha:0.3)
        }
    }
    
    func setThisColorForMain() {
        Colors.backgroundType = self
    }
}