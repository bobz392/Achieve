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
        groupDefault.removeObject(forKey: tasksKey)
    }
    
    func updateTask(_ task: Task) {
        groupDefault.array(forKey: tasksKey)
    }
    
    func writeTasks(_ tasks: Results<Task>) {
        var tasksArr = [[String]]()
        for task in tasks {
            let title = task.getNormalDisplayTitle()
            let uuid = task.uuid
            let priority = task.priority
            let estimate = task.estimateDate?.formattedDate(withFormat: UUIDFormat) ?? ""
            
            let taskArray = [uuid, title, "\(priority)", estimate]
            tasksArr.append(taskArray)
        }
        
        Logger.log("write new task count = \(tasks.count)")
        self.groupDefault.set(tasksArr, forKey: tasksKey)
        
        self.setTaskChanged(true)
    }
}
