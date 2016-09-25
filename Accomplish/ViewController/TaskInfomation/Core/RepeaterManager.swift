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
        let userDefault = AppUserDefault()
        let now = NSDate()
        
        guard let lastDateString = userDefault.readString(kLastFetchDateKey) else {
            userDefault.write(kLastFetchDateKey, value:now.createdFormatedDateString())
            return false
        }
        
        let lastDate: NSDate = lastDateString.dateFromCreatedFormatString() as NSDate
        
        Logger.log("last date is today = \(lastDate.isToday()) and is earlier then today = \(lastDate.isEarlierThan(now as Date!))")
        if !lastDate.isToday() && lastDate.isEarlierThan(now as Date!) {
//             do some use repeater create todays task
            self.repeaterTaskCreate()
            userDefault.write(kLastFetchDateKey, value: now.createdFormatedDateString())
            // 加入昨天的check in
            // 以及任务完成率
            self.createCheckIn(now: now)
            AppUserDefault().write(kNeedMoveUnfinishTaskToToday, value: true)
            return true
        } else {
            return false
        }
    }
    
    fileprivate func createCheckIn(now: NSDate) {
        let checkIn = CheckIn()
        let checkInDate = now.subtractingDays(1) as NSDate
        checkIn.checkInDate = checkInDate
        checkIn.formatedDate = checkInDate.createdFormatedDateString()
        let task = RealmManager.shareManager.queryTaskCount(date: checkInDate)
        checkIn.completedCount = task.complete
        checkIn.createdCount = task.created
        
        RealmManager.shareManager.saveCheckIn(checkIn)
    }
    
    fileprivate func repeaterTaskCreate() {
        Logger.log("repeater task create")
        let manager = RealmManager.shareManager
        let all = manager.allRepeater()
        let today = NSDate()
        
        for repeater in all {
            guard let task = manager.queryTask(repeater.repeatTaskUUID),
                let createDate = task.createdDate,
                let repeatTime = RepeaterTimeType(rawValue: repeater.repeatType)
                else { return }
            
            let createTask: Bool
            switch repeatTime {
            case .daily:
                createTask = true
            case .annual:
                createTask = today.month() == createDate.month() && createDate.day() == today.day()
            case .everyMonth:
                createTask = today.day() == createDate.day()
            case .weekday:
                createTask = !today.isWeekend()
            case .everyWeek:
                createTask = today.weekday() == createDate.weekday()
            }
            
            if createTask {
                let newTask = self.copyTask(task)
                manager.updateObject({
                    repeater.repeatTaskUUID = newTask.uuid
                })
                manager.writeObject(newTask)
            }
        }
    }
    
    fileprivate func copyTask(_ task: Task) -> Task {
        let newTask = Task()
        let now = NSDate()
        let createDate = task.createdDate ?? now
        
        newTask.createdDate = NSDate(year: now.year(), month: now.month(), day: now.day(), hour: createDate.hour(), minute: createDate.minute(), second: createDate.second())
        newTask.createDefaultTask(task.taskToDo, priority: task.priority)
        newTask.canPostpone = task.canPostpone
        newTask.finishedDate = nil
        if let notify = task.notifyDate {
            newTask.notifyDate = NSDate(year: now.year(), month: now.month(), day: now.day(), hour: notify.hour(), minute: notify.minute(), second: notify.second())
        }
        newTask.subTaskCount = task.subTaskCount
        newTask.status = kTaskRunning
        newTask.tagUUID = task.tagUUID
        newTask.taskNote = task.taskNote
        newTask.taskType = task.taskType
        newTask.trigger = nil
        
        let shareManager = RealmManager.shareManager
        let subtasks = shareManager.querySubtask(task.uuid)
        for (index, sub) in subtasks.enumerated() {
            let subtask = Subtask()
            subtask.rootUUID = newTask.uuid
            subtask.taskToDo = sub.taskToDo
            let subtaskCreateDate = now.addingMinutes(index) as NSDate
            subtask.createdDate = subtaskCreateDate
            subtask.uuid = subtaskCreateDate.createTaskUUID()
            shareManager.writeObject(subtask)
        }
        Logger.log("copy task with name = \(task.taskToDo) and subtask count = \(task.subTaskCount)")
        
        return newTask

    }
}
