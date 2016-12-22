//
//  Task.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/24.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation
import RealmSwift

//let kTaskRunning: Int = 0
//let kTaskFinish: Int = 1
//let kTaskFailure: Int = 3
//let kTaskCancel: Int = 4

//let kTaskPriorityLow: Int = 0
//let kTaskPriorityNormal: Int = 1
//let kTaskPriorityHigh: Int = 2

//let kCustomTaskType: Int = 0
//let kSystemTaskType: Int = 1
//let kAssociatTaskType: Int = 2
//let kSubtaskType: Int = 3

enum TaskStatus {
    case preceed
    case completed
    
    func status() -> Int {
        if self == .preceed {
            return 0
        } else {
            return 1
        }
    }
}

enum TaskPriority {
    case low
    case high
    case normal
    
    func priority() -> Int {
        switch self {
        case .low:
            return 0
        case .normal:
            return 1
        case .high:
            return 2
        }
    }
}

enum TaskType {
    case custom
    case system
    case subtask
    
    func type() -> Int {
        switch self {
        case .custom:
            return 0
        case .system:
            return 1
        case .subtask:
            return 3
        }
    }
}

class Task: Object {
    dynamic var uuid = ""
    dynamic var taskToDo = ""
    dynamic var taskNote = ""
    
    dynamic var status = TaskStatus.preceed.status()
    dynamic var taskType = TaskType.custom.type()
    dynamic var priority = TaskPriority.normal.priority()
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
    
    func createDefaultTask(_ taskToDo: String, priority: Int = TaskPriority.normal.priority()) {
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
        case TaskType.system.type():
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
        case TaskType.system.type():
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
    
    func taskStatus() -> TaskStatus {
        switch status {
        case TaskStatus.completed.status():
            return .completed
        default:
            return .preceed
        }
    }
    
    func typeOfTask() -> TaskType {
        switch self.taskType {
        case TaskType.subtask.type():
            return .subtask
        case TaskType.system.type():
            return .system
        default:
            return .custom
        }
    }
    
    func taskPriority() -> TaskPriority {
        switch priority {
        case TaskPriority.high.priority():
            return .high
        case TaskPriority.normal.priority():
            return .normal
        default:
            return .low
        }
    }
    
    func taskToDoCanChange() -> Bool {
        return taskToDo.components(separatedBy: kSpliteTaskIdentity).count < 2
    }
}
