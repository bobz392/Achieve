//
//  FontAwsomes.swift
//  Accomplish
//
//  Created by zhoubo on 16/12/19.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation

enum Icons {
    case barMenu
    case plus
    case check
    case uncheck
    
    func iconString() -> String {
        switch self {
        case .barMenu:
            return "menu"
        case .plus:
            return "plus"
        case .check:
            return "check"
        case .uncheck:
            return "uncheck"
        }
    }
}
