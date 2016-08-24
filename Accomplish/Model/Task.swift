//
//  Task.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/24.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation
import RealmSwift

let kTaskRunning: Int = 0
let kTaskFinish: Int = 1
let kTaskPostpone: Int = 2
let kTaskFailure: Int = 3

let kPriorityLow: Int = 0
let kPriorityNormal: Int = 1
let kPriorityHigh: Int = 2

class Task: Object {
    dynamic var uuid = ""
    dynamic var title = ""
    dynamic var content = ""
    dynamic var status = 0
    dynamic var priority = 1
    dynamic var createdFormattedDate: String = ""
    dynamic var startedDate: NSDate?
    dynamic var finishedDate: NSDate?

    override class func primaryKey() -> String? {
        return "uuid"
    }
    
    func config() {
        let now = NSDate()
        createdFormattedDate = now.formattedDateWithFormat("yyyy.MM.dd")
        uuid = now.formattedDateWithFormat("yyMMddHHmmssZ")
    }
}