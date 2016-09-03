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
    
}