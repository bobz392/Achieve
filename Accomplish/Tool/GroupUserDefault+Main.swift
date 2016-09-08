//
//  GroupUserDefault+Today.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/3.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation
import RealmSwift

extension GroupUserDefault {
    
    func clearAllTask() {
        groupDefault.removeObjectForKey(tasksKey)
    }
    
    func updateTask(task: Task) {
        groupDefault.arrayForKey(tasksKey)
    }
    
    func writeTasks(tasks: Results<Task>) {
        var tasksArr = [[String]]()
        for task in tasks {
            let title = task.getNormalDisplayTitle()
            let uuid = task.uuid
            let priority = task.priority
            
            let taskArray = [uuid, title, "\(priority)"]
            tasksArr.append(taskArray)
        }
        
        debugPrint("write new task count = \(tasks.count)")
        self.groupDefault.setObject(tasksArr, forKey: tasksKey)
        
        self.setTaskChanged(true)
    }
}