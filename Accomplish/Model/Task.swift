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
let kTaskFailure: Int = 3
let kTaskCancel: Int = 4

let kTaskPriorityLow: Int = 0
let kTaskPriorityNormal: Int = 1
let kTaskPriorityHigh: Int = 2

let kCustomTaskType: Int = 0
let kSystemTaskType: Int = 1
let kAssociatTaskType: Int = 2
let kSubtaskType: Int = 3

let uuidFormat: String = "yyMMddHHmmssZ"
let createdDateFormat: String = "yyyy.MM.dd"
let timeDateFormat: String = "hh: mm a"

class Task: Object {
    dynamic var uuid = ""
    dynamic var taskToDo = ""
    dynamic var taskNote = ""
    dynamic var status = kTaskRunning
    dynamic var taskType = kCustomTaskType
    dynamic var taskRepeat: Int8 = 0
    dynamic var priority = kTaskPriorityNormal
    dynamic var createdFormattedDate: String = ""
    dynamic var createdDate: NSDate?
    dynamic var notifyDate: NSDate?
    dynamic var finishedDate: NSDate?
    
    dynamic var trigger: Trigger?
    
    dynamic var subTaskCount: Int = 0
    
    override class func primaryKey() -> String? {
        return "uuid"
    }
    
    func createDefaultTask(taskToDo: String, priority: Int = kTaskPriorityNormal) {
        if let date = self.createdDate {
            self.createdFormattedDate = date.formattedDateWithFormat(createdDateFormat)
            self.uuid = date.formattedDateWithFormat(uuidFormat)
        } else {
            let now = NSDate()
            self.createdDate = now
            self.createdFormattedDate = now.formattedDateWithFormat(createdDateFormat)
            self.uuid = now.formattedDateWithFormat(uuidFormat)
        }
        
        self.priority = priority
        self.taskToDo = taskToDo
    }
}