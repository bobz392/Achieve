//
//  Range+Array.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/26.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation

protocol ArrayRepresentable {
    associatedtype ArrayType
    
    func toArray() -> [ArrayType]
}

extension Range : ArrayRepresentable {

    func toArray() -> [Element] {
        return [Element](self)
    }
}