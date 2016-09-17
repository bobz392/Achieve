//
//  GroupUserDefault.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/3.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation

let GroupIdentifier = "group.bob.accomplish"
let WormholeIdentifier = "newTask"

let GroupTaskUUIDIndex = 0
let GroupTaskTitleIndex = 1
let GroupTaskPriorityIndex = 2
let GroupTaskEstimateIndex = 3
let GroupTaskFinishDateIndex = 4

struct GroupUserDefault {
    let groupDefault: UserDefaults
    let tasksKey = "all.task.today"
    let taskChangeKey = "task.changed.today"
    let todayFinishTaskKey = "task.finish.by.today"
    
    init?() {
        guard let groupDefault = UserDefaults(suiteName: GroupIdentifier) else {
            return nil
        }
        
        self.groupDefault = groupDefault
    }
    
    func taskHasChanged() -> Bool {
        return self.groupDefault.bool(forKey: taskChangeKey)
    }
    
    func setTaskChanged(_ changed: Bool) {
        self.groupDefault.set(changed, forKey: taskChangeKey)
        self.groupDefault.synchronize()
    }
    
    func allTasks() -> [GroupTask] {
        var tasks = [GroupTask]()
        guard let tasksArr = self.groupDefault.array(forKey: tasksKey) as? [[String]]
            else { return tasks }
        
        for task in tasksArr {
            let uuid = task[GroupTaskUUIDIndex]
            let prority = Int(task[GroupTaskPriorityIndex]) ?? 0
            let title = task[GroupTaskTitleIndex]
            let estimateDate = task[GroupTaskEstimateIndex]
            let groupTask = GroupTask(taskUUID: uuid, taskPriority: prority,
                                      taskTitle: title, taskEstimateDate: estimateDate,
                                      taskFinishDate: nil)
            
            tasks.append(groupTask)
        }
        
        return tasks
    }
    
    func writeTasks(_ tasks: [[String]]) {
        self.groupDefault.set(tasks, forKey: tasksKey)
        self.groupDefault.synchronize()
    }
    
    func getAllFinishTask() -> [[String]] {
        return (self.groupDefault.array(forKey: todayFinishTaskKey) as? [[String]]) ?? [[String]]()
    }
    
    fileprivate func setTaskFinish(_ finish: [String]) {
        var tasks = self.groupDefault.object(forKey: todayFinishTaskKey) as? [[String]]
        if tasks == nil {
            tasks = [[String]]()
        }
        
        tasks?.append(finish)
        self.groupDefault.set(tasks, forKey: todayFinishTaskKey)
    }
    
    func clearTaskFinish() {
        self.groupDefault.set(nil, forKey: todayFinishTaskKey)
        self.groupDefault.synchronize()
    }
    
    func moveTaskFinish(_ taskIndex: Int) {
        guard var tasks = self.groupDefault.array(forKey: tasksKey) as? [[String]]
            else { return }
        
        var finishTask = tasks.remove(at: taskIndex)
        finishTask.append(NSDate().formattedDate(withFormat: UUIDFormat))
        self.setTaskFinish(finishTask)
        self.writeTasks(tasks)
    }
}

struct GroupTask {
    let taskUUID: String
    let taskPriority: Int
    let taskTitle: String
    var taskEstimateDate: String? = nil
    var taskFinishDate: String? = nil
}
