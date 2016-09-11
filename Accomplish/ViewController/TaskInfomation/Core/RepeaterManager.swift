//
//  RepeaterManager.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/3.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation

struct RepeaterManager {
    
    // 检查最后一次检查时间，并创建重复task
    func isNewDay() -> Bool {
        // check last check is today or not
        let userDefault = UserDefault()
        let now = NSDate()
        
        guard let lastDateString = userDefault.readString(kLastFetchDateKey) else {
            userDefault.write(kLastFetchDateKey, value:now.createdFormatedDateString())
            return false
        }
        
        let lastDate = lastDateString.dateFromCreatedFormatString()
        
        debugPrint("last date is today = \(lastDate.isToday()) and is earlier then today = \(lastDate.isEarlierThan(now))")
        if !lastDate.isToday() && lastDate.isEarlierThan(now) {
//             do some use repeater create todays task
            self.repeaterTaskCreate()
            userDefault.write(kLastFetchDateKey, value: now.createdFormatedDateString())
            // 加入昨天的check in
            // 以及任务完成率
            createCheckIn(now)
            
            return true
        } else {
            return false
        }
    }
    
    private func createCheckIn(now: NSDate) {
        let checkIn = CheckIn()
        let checkInDate = now.dateBySubtractingDays(1)
        checkIn.checkInDate = checkInDate
        checkIn.formatedDate = checkInDate.createdFormatedDateString()
        let task = RealmManager.shareManager.queryTaskCount(checkInDate)
        checkIn.completedCount = task.complete
        checkIn.createdCount = task.created
        
        RealmManager.shareManager.saveCheckIn(checkIn)
    }
    
    private func repeaterTaskCreate() {
        beginDebugPrint("repeater task create")
        let manager = RealmManager.shareManager
        let all = manager.allRepeater()
        let today = NSDate()
        let _ = all.map({ (repeater) -> Void in
            guard let task = manager.queryTask(repeater.repeatTaskUUID),
                let createDate = task.createdDate,
                let repeatTime = RepeaterTimeType(rawValue: repeater.repeatType)
                else { return }
            
            let createTask: Bool
            switch repeatTime {
            case .Daily:
                createTask = true
            case .Annual:
                createTask = today.month() == createDate.month() && createDate.day() == today.day()
            case .EveryMonth:
                createTask = today.day() == createDate.day()
            case .Weekday:
                createTask = !today.isWeekend()
            case .EveryWeek:
                createTask = today.weekday() == createDate.weekday()
            }
            
            if createTask {
                let newTask = self.copyTask(task)
                manager.updateObject({ 
                    repeater.repeatTaskUUID = newTask.uuid
                })
                manager.writeObject(newTask)
            }
            
        })
        
        endDebugPrint("repeater task create")
    }
    
    private func copyTask(task: Task) -> Task {
        let newTask = Task()
        let now = NSDate()
        let createDate = task.createdDate ?? now
        newTask.createdDate = NSDate(year: now.year(), month: now.month(), day: now.day(), hour: createDate.hour(), minute: createDate.minute(), second: createDate.second())
        newTask.createDefaultTask(task.taskToDo, priority: task.priority)
        newTask.canPostpone = task.canPostpone
        newTask.finishedDate = nil
        newTask.notifyDate = task.notifyDate
        newTask.subTaskCount = task.subTaskCount
        newTask.status = kTaskRunning
        newTask.tag = task.tag
        newTask.taskNote = task.taskNote
        newTask.taskType = task.taskType
        newTask.trigger = nil
        
        let shareManager = RealmManager.shareManager
        let subtasks = shareManager.querySubtask(task.uuid)
        for (index, sub) in subtasks.enumerate() {
            let subtask = Subtask()
            subtask.rootUUID = newTask.uuid
            subtask.taskToDo = sub.taskToDo
            let subtaskCreateDate = now.dateByAddingMinutes(index)
            subtask.createdDate = subtaskCreateDate
            subtask.uuid = subtaskCreateDate.createTaskUUID()
            shareManager.writeObject(subtask)
        }
        debugPrint("copy task with name = \(task.taskToDo) and subtask count = \(task.subTaskCount)")
        
        return newTask

    }
}