//
//  Reapter.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/1.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation
import RealmSwift

class Repeater: Object {
    dynamic var uuid: String = NSDate().formattedDate(withFormat: UUIDFormat) + "-Repeater"
    // this uuid was newest uuid in tasks that created by repeater
    // 这个字段永远是在更新的，保持repeater 跟最新的一个 task 相关联；
    dynamic var repeatTaskUUID: String = ""
    // this uuid never change
    /**
     这个字段用于标识Notification 的标识符， 永远不会被改变
     同时这个字段也表明的这个 repeater 最先开始的任务；
     **/
    dynamic var repeatQueryTaskUUID: String = ""
    dynamic var repeatType: Int = 0
}
