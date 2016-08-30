//
//  NSDate+Convenient.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/29.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation

let uuidFormat: String = "yyMMddHHmmssZ"
let createdDateFormat: String = "yyyy.MM.dd"
let timeDateFormat: String = "hh: mm a"

// TASK
extension NSDate {
    func createTaskUUID() -> String {
        return self.formattedDateWithFormat(uuidFormat)
    }
}
