//
//  SystemItem.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/26.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation

/**
 ** most importent
 ** action 的内容数据
 **/
struct SystemActionContent {
    let type: SystemActionType
    let name: String
    let urlSchemeInfo: String
}