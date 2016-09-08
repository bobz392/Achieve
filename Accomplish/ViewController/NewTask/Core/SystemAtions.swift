//
//  SystemItem.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/26.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation

/**
 ** action 的内容数据
 **/
struct SystemActionContent {
    let type: SystemActionType
    let name: String
    let urlSchemeInfo: String
}

/**
 ** action 对应的功能展现
 ** such 从 address book 中取回数据
 **/
enum ActionFeaturePresent {
    case AddressBook
    case AddressBookEmail
    case CreateSubtasks
    case None
}
