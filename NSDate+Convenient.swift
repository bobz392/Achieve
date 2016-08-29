//
//  NSDate+Convenient.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/29.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation


// TASK
extension NSDate {
    func createTaskUUID() -> String {
        return self.formattedDateWithFormat(uuidFormat)
    }
}
