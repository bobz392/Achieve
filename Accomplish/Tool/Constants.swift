//
//  Constants.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/24.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation

let kSmallAnimationDuration: TimeInterval = 0.15
let kNormalAnimationDuration: TimeInterval = 0.35
let kNormalLongAnimationDuration: TimeInterval = 0.5
let kLongAnimationDuration: TimeInterval = 1
let kCardViewCornerRadius: CGFloat = 4
let kCardViewSmallCornerRadius: CGFloat = 6
let kKeyboardAnimationDelay: TimeInterval = 0.1

let kBackButtonCorner: CGFloat = 21

enum UrlType {
    case taskDetail
    case home
    
    func absoluteString() -> String {
        let scheme = "achieve://"
        switch self {
        case .taskDetail:
            return "\(scheme)\(self.pathString())"
        case .home:
            return "\(scheme)\(self.pathString())"
        }
    }
    
    func pathString() -> String {
        switch self {
        case .taskDetail:
            return "task/detail/"
        case .home:
            return "task/all/"
        }
    }
    
}
