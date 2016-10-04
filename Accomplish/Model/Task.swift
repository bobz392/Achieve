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

class Task: Object {
    dynamic var uuid = ""
    dynamic var taskToDo = ""
    dynamic var taskNote = ""
    
    dynamic var status = kTaskRunning
    dynamic var taskType = kCustomTaskType
    dynamic var priority = kTaskPriorityNormal
    // for query
    dynamic var createdFormattedDate: String = ""
    dynamic var createdDate: NSDate?
    dynamic var notifyDate: NSDate?
    dynamic var finishedDate: NSDate?
    dynamic var estimateDate: NSDate?
    dynamic var postponeTimes: Int = 0
    dynamic var tagUUID: String?
    
    dynamic var trigger: Trigger?
    dynamic var repeaterUUID: String?
    dynamic var subTaskCount: Int = 0
    
    override class func primaryKey() -> String? {
        return "uuid"
    }
    
    func createDefaultTask(_ taskToDo: String, priority: Int = kTaskPriorityNormal) {
        if let date = self.createdDate {
            self.createdFormattedDate = date.createdFormatedDateString()
            self.uuid = date.createTaskUUID()
        } else {
            let now = NSDate()
            self.createdDate = now
            self.createdFormattedDate = now.createdFormatedDateString()
            self.uuid = now.createTaskUUID()
        }
        
        self.priority = priority
        self.taskToDo = taskToDo
    }
    
    func getNormalDisplayTitle() -> String {
        switch self.taskType {
        case kSystemTaskType:
            if let action = TaskManager().parseTaskToDoText(self.taskToDo) {
                return action.type.ationNameWithType() + action.name
            } else {
                return self.taskToDo
            }
            
        default:
            return self.taskToDo
        }
    }
    
    func taskScheme() -> String {
        switch self.taskType {
        case kSystemTaskType:
            if let action = TaskManager().parseTaskToDoText(self.taskToDo) {
                guard let scheme = action.type.actionScheme() else { return "" }
                return scheme + action.name
            } else {
                return ""
            }
            
        default:
            return ""
        }
    }
    
    func taskToDoCanChange() -> Bool {
        return taskToDo.components(separatedBy: kSpliteTaskIdentity).count < 2
    }
}
