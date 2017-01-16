//
//  BuildInTaskCreator {.swift
//  Accomplish
//
//  Created by zhoubo on 2017/1/16.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import Foundation

struct BuildInTaskCreator {
    
    func create() {

        var tasks = [Task]()
        var subtasks = [Subtask]()

        let now = NSDate().subtractingSeconds(10) as NSDate
        
        let welcomeTask = Task()
        welcomeTask.createdDate = now
        welcomeTask.createDefaultTask("Welcome to Achieve")
        welcomeTask.taskType = TaskType.guild.type()
        tasks.append(welcomeTask)

        let deleteTask = Task()
        deleteTask.createdDate = now.addingSeconds(1) as NSDate
        deleteTask.createDefaultTask("Swipe left to delete task or use time management")
        deleteTask.taskType = TaskType.guild.type()
        tasks.append(deleteTask)

        let useTouchTask = Task()
        useTouchTask.createdDate = now.addingSeconds(2) as NSDate
        useTouchTask.createDefaultTask("Preview task detail by press task cell")
        useTouchTask.taskType = TaskType.guild.type()
        tasks.append(useTouchTask)

        let menuTask = Task()
        menuTask.createdDate = now.addingSeconds(3) as NSDate
        menuTask.createDefaultTask("Swipe right to show menu, press me to check more detail")
        menuTask.taskType = TaskType.guild.type()
        menuTask.subTaskCount = 3
        tasks.append(menuTask)

        let menuSubtask1 = Subtask()
        menuSubtask1.createdDate = now.addingSeconds(3) as NSDate
        menuSubtask1.createDefaultSubtask(todo: "Calendar", rootTaskUUID: menuTask.uuid)
        subtasks.append(menuSubtask1)
        let menuSubtask2 = Subtask()
        menuSubtask2.createdDate = now.addingSeconds(4) as NSDate
        menuSubtask2.createDefaultSubtask(todo: "Tag", rootTaskUUID: menuTask.uuid)
        subtasks.append(menuSubtask2)
        let menuSubtask3 = Subtask()
        menuSubtask3.createdDate = now.addingSeconds(5) as NSDate
        menuSubtask3.createDefaultSubtask(todo: "Time Management", rootTaskUUID: menuTask.uuid)
        subtasks.append(menuSubtask3)

        let calendarTask = Task()
        calendarTask.createdDate = now.addingSeconds(4) as NSDate
        calendarTask.createDefaultTask("In calendar, you can check schedule and daily or monthly info")
        tasks.append(calendarTask)

        let tagTask = Task()
        tagTask.createdDate = now.addingSeconds(5) as NSDate
        tagTask.createDefaultTask("In tag, you can classify your tasks")
        tasks.append(tagTask)

        let tmTask = Task()
        tmTask.createdDate = now.addingSeconds(6) as NSDate
        tmTask.createDefaultTask("In Time Management, you can custom your own time management method.")
        tasks.append(tmTask)

        let helpTask = Task()
        helpTask.createdDate = now.addingSeconds(7) as NSDate
        helpTask.createDefaultTask("If you have any question or suggestion, your can mail us or replay us on App Store.")
        tasks.append(helpTask)
        
        let thankTask = Task()
        thankTask.createdDate = now.addingSeconds(8) as NSDate
        thankTask.createDefaultTask("Thank your for use Achieve. We wish everyone achieve your dream.")
        tasks.append(thankTask)

        RealmManager.shared.writeObjects(subtasks)
        RealmManager.shared.writeObjects(tasks)
    }

}
