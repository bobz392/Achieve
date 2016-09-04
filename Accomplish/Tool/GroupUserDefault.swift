//
//  GroupUserDefault.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/3.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation

struct GroupUserDefault {
    
    let groupDefault: NSUserDefaults
    let group = "group.bob.accomplish"
    let tasksKey = "all.task.today"
    let taskChangeKey = "task.changed.today"
    let todayFinishTaskKey = "task.finish.by.today"
    
    static let taskTitleIndex = 1
    static let taskSchemeIndex = 2
    
    init?() {
        guard let groupDefault = NSUserDefaults(suiteName: group) else {
            return nil
        }
        
        self.groupDefault = groupDefault
    }
    
    func taskHasChanged() -> Bool {
        return self.groupDefault.boolForKey(taskChangeKey)
    }
    
    func setTaskChanged(changed: Bool) {
        self.groupDefault.setBool(changed, forKey: taskChangeKey)
        self.groupDefault.synchronize()
    }
    
    func allTasks() -> [[String]] {
        guard let tasksArray = self.groupDefault.arrayForKey(tasksKey) as? [[String]]
            else { return [[String]]() }
        
        return tasksArray
    }
    
    func writeTasks(tasks: [[String]]) {
        self.groupDefault.setObject(tasks, forKey: tasksKey)
        self.groupDefault.synchronize()
    }
    
    func setTaskFinish(finish: [String]) {
        var tasks = self.groupDefault.objectForKey(todayFinishTaskKey) as? [[String]]
        if tasks == nil {
            tasks = [[String]]()
        }
        
        tasks?.append(finish)
        self.groupDefault.setObject(tasks, forKey: todayFinishTaskKey)
        self.groupDefault.synchronize()
    }
}