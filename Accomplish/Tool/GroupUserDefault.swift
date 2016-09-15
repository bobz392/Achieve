//
//  GroupUserDefault.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/3.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation

let group = "group.bob.accomplish"
let wormholeIdentifier = "newTask"

struct GroupUserDefault {
    let groupDefault: UserDefaults
    let tasksKey = "all.task.today"
    let taskChangeKey = "task.changed.today"
    let todayFinishTaskKey = "task.finish.by.today"
    
    static let GroupTaskUUIDIndex = 0
    static let GroupTaskTitleIndex = 1
    static let GroupTaskPriorityIndex = 2
    static let GroupTaskFinishDateIndex = 3
    
    init?() {
        guard let groupDefault = UserDefaults(suiteName: group) else {
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
    
    func allTasks() -> [[String]] {
        guard let tasksArray = self.groupDefault.array(forKey: tasksKey) as? [[String]]
            else { return [[String]]() }
        
        return tasksArray
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
        finishTask.append((Date() as NSDate).formattedDate(withFormat: uuidFormat))
        self.setTaskFinish(finishTask)
        self.writeTasks(tasks)
    }
}
