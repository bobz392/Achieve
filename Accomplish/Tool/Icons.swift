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
    case listEmpty
    case search
    case timeManagement
    case delete
    
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
        case .listEmpty:
            return "empty_list"
        case .search:
            return "search"
        case .timeManagement:
            return "time_management"
        case .delete:
            return "delete"
            
        }
    }
    
    func iconImage() -> UIImage? {
        return UIImage(named: self.iconString())?.withRenderingMode(.alwaysTemplate)
    }
}
