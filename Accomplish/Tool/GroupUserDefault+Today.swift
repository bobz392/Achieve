//
//  GroupUserDefault+Today.swift
//  Accomplish
//
//  Created by zhoubo on 2016/9/29.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation

let WormholeNewTaskIdentifier = "wormhole.new.task"

extension GroupUserDefault {
    
    func todayExtensionMoveTaskFinish(_ taskIndex: Int) {
        guard var tasks = self.groupDefault.array(forKey: ExtensionTasksKey) as? [[String]]
            else { return }
        
        var finishTask = tasks.remove(at: taskIndex)
        finishTask.append(NSDate().formattedDate(withFormat: UUIDFormat))
        self.setTaskFinish(finishTask)
        self.writeTasks(tasks)
    }
    
    func getRunningTimeMethod() -> String? {
        return self.groupDefault.string(forKey: TodayExtensionTimeMethodKey)
    }
    
    fileprivate func writeTasks(_ tasks: [[String]]) {
        self.groupDefault.set(tasks, forKey: ExtensionTasksKey)
        self.groupDefault.synchronize()
    }
}
