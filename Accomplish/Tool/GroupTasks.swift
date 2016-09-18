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

struct GroupTask {
    let taskUUID: String
    let taskPriority: Int
    let taskTitle: String
    var taskEstimateDate: String? = nil
    var taskFinishDate: String? = nil
}
