//
//  GroupUserDefault.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/3.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation

let GroupIdentifier = "group.zhoubo.achieve"

struct GroupUserDefault {
    let groupDefault: UserDefaults
    let ExtensionTasksKey = "all.task.today"
    let ExtensionTaskChangeKey = "task.changed.today"
    let TodayExtensionFinishTaskKey = "task.finish.by.today"
    let TodayExtensionTimeMethodKey = "today.time.method"
    
    init?() {
        guard let groupDefault = UserDefaults(suiteName: GroupIdentifier) else {
            return nil
        }
        
        self.groupDefault = groupDefault
    }
    
    func taskHasChanged() -> Bool {
        return self.groupDefault.bool(forKey: ExtensionTaskChangeKey)
    }
    
    func setTaskChanged(_ changed: Bool) {
        self.groupDefault.set(changed, forKey: ExtensionTaskChangeKey)
        self.groupDefault.synchronize()
    }
    
    func runningTasksForExtension() -> [GroupTask] {
        var tasks = [GroupTask]()
        guard let tasksArr = self.groupDefault.array(forKey: ExtensionTasksKey) as? [[String]]
            else { return tasks }
        
        for task in tasksArr {
            let uuid = task[GroupTaskUUIDIndex]
            let prority = Int(task[GroupTaskPriorityIndex]) ?? 0
            let title = task[GroupTaskTitleIndex]
            let estimateDate = task[GroupTaskEstimateIndex]
            let finishDate = task[GroupTaskFinishDateIndex]
            let createDate = task[GroupTaskCreateDateIndex]
            let groupTask = GroupTask(taskUUID: uuid, taskPriority: prority,
                                      taskTitle: title, taskEstimateDate: estimateDate,
                                      taskFinishDate: finishDate, taskCreateDate: createDate)
            
            tasks.append(groupTask)
        }
        
        return tasks
    }
    
    internal func setTaskFinish(_ finish: [String]) {
        var tasks = self.groupDefault.object(forKey: TodayExtensionFinishTaskKey) as? [[String]]
        if tasks == nil {
            tasks = [[String]]()
        }
        
        tasks?.append(finish)
        self.groupDefault.set(tasks, forKey: TodayExtensionFinishTaskKey)
    }
}

// MARK: - watch
extension GroupUserDefault {
    func allTaskArrayForWatchExtension() -> [[String]] {
        guard let tasksArray = self.groupDefault.array(forKey: ExtensionTasksKey) as? [[String]]
            else { return [[String]]() }
        
        return tasksArray
    }
}
