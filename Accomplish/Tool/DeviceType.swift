//
//  DeviceType.swift
//  Accomplish
//
//  Created by zhoubo on 2017/1/2.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import UIKit
struct DeviceSzie {
    
    enum DeviceType {
        case iphone4
        case iphone5
        case iphone6
        case iphone6p
        case unknown
    }
    
    //判断屏幕类型
    static func currentSize() -> DeviceType {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        switch (screenWidth, screenHeight) {
        case (320, 480),(480, 320):
            return .iphone4
        case (320, 568),(568, 320):
            return .iphone5
        case (375, 667),(667, 375):
            return .iphone6
        case (414, 736),(736, 414):
            return .iphone6p
        default:
            return .unknown
        }
    }
    
    static func isSmallDevice() -> Bool {
        let current = DeviceSzie.currentSize()
        return current == .iphone4 || current == .iphone5
    }
}
