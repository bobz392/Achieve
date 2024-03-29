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
        groupDefault.removeObject(forKey: ExtensionTasksKey)
    }
    
    func updateTask(_ task: Task) {
        groupDefault.array(forKey: ExtensionTasksKey)
    }
    
    func writeTasks(_ tasks: Results<Task>) {
        var tasksArr = [[String]]()
        let realmManager = RealmManager.shared
        for task in tasks {
            let title = task.realTaskToDo()
            let uuid = task.uuid
            let priority = task.priority
            let estimate = task.estimateDate?.formattedDate(withFormat: TimeDateFormat) ?? ""
            let finish = task.finishedDate?.formattedDate(withFormat: TimeDateFormat) ?? ""
            let create = task.createdDate?.formattedDate(withFormat: TimeDateFormat) ?? ""
            
            let tagName: String
            if let tagUUID = task.tagUUID,
                let tag = realmManager.queryTag(usingName: false, query: tagUUID) {
                tagName = tag.name
            } else {
                tagName = ""
            }
            
            let taskArray = [uuid, title, "\(priority)", estimate, finish, tagName, create]
            tasksArr.append(taskArray)
        }
        
        Logger.log("write new task count = \(tasks.count)")
        self.groupDefault.set(tasksArr, forKey: ExtensionTasksKey)
        
        self.setTaskChanged(true)
    }
    
    func writeRunningTimeMethod(taskName: String? = nil) {
        Logger.log("writeRunningTimeMethod taskName = \(taskName)")
        if let name = taskName {
            self.groupDefault.set(name, forKey: TodayExtensionTimeMethodKey)
        } else {
            self.groupDefault.removeObject(forKey: TodayExtensionTimeMethodKey)
        }
        self.groupDefault.synchronize()
    }
    
    func getAllFinishTask() -> [[String]] {
        return (self.groupDefault.array(forKey: TodayExtensionFinishTaskKey) as? [[String]]) ?? [[String]]()
    }
    
    func clearTaskFinish() {
        self.groupDefault.set(nil, forKey: TodayExtensionFinishTaskKey)
        self.groupDefault.synchronize()
    }
    
}
