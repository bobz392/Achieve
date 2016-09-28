//
//  GroupTasks.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/19.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation

let GroupTaskUUIDIndex = 0
let GroupTaskTitleIndex = 1
let GroupTaskPriorityIndex = 2
let GroupTaskEstimateIndex = 3
let GroupTaskFinishDateIndex = 4
let GroupTaskTagIndex = 5
let GroupTaskCreateDateIndex = 6

struct GroupTask {
    let taskUUID: String
    let taskPriority: Int
    let taskTitle: String
    var taskEstimateDate: String? = nil
    var taskFinishDate: String? = nil
    var taskCreateDate: String? = nil
    
    static func showTaskCountTitle(taskCount: Int) -> String {
        if taskCount == 0 {
            return String(format: Localized("noTaskToday"), taskCount)
        } else if taskCount == 1 {
            return String(format: Localized("taskToday"), taskCount)
        } else {
            return String(format: Localized("taskTodays"), taskCount)
        }
    }
}
