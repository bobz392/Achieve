//
//  RealmManager.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/25.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation
import RealmSwift

class RealmManager {
    
    typealias RealmBlock = () -> Void
    
    internal let realm = try! Realm()
    
    static let shareManager = RealmManager()
    
    func writeObject(object: Object) {
        try! realm.write {
            realm.add(object)
        }
    }
    
    func deleteObject(object: Object) {
        try! realm.write {
            realm.delete(object)
        }
    }
    
    func updateObject(@noescape updateBlock: RealmBlock) {
        try! realm.write({
            updateBlock()
        })
    }
    
    func writeObjects(objects: [Object]) {
        realm.beginWrite()
        realm.add(objects)
        try! realm.commitWrite()
    }
    
    func queryAll(clz: AnyClass) {
        let result = realm.objects(clz as! Object.Type)
        debugPrint(result)
    }
    
    func queryTodayTaskList(finished finished: Bool) -> Results<Task> {
        let queryDate = NSDate().createdFormatedDateString()
        
        let tasks = realm
            .objects(Task.self)
            .filter("createdFormattedDate = '\(queryDate)' AND status \(finished ? "!=" : "==") \(kTaskRunning)")
            .sorted("createdDate")
        
        return tasks
    }
    
    func queryYesterdayTaskCount() -> (finish: Int, running: Int) {
        let queryDate = NSDate().dateBySubtractingDays(1).createdFormatedDateString()
        
        let runningCount = realm.objects(Task.self)
            .filter("createdFormattedDate = '\(queryDate)' AND status  = \(kTaskRunning)")
            .count
        let finishCount = realm
            .objects(Task.self)
            .filter("createdFormattedDate = '\(queryDate)' AND status != \(kTaskRunning)")
            .count
        
        return (finishCount, runningCount)
    }
    
    func queryTask(taskUUID: String) -> Task? {
        return realm.objects(Task.self).filter("uuid = '\(taskUUID)'").first
    }
    
    func querySubtask(rootUUID: String) -> Results<Subtask> {
        return realm.objects(Subtask.self)
            .filter("rootUUID = '\(rootUUID)'")
            .sorted("createdDate")
    }
    
    func deleteTask(task: Task) {
    }
    
    func copyTask(task: Task) -> Task {
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
        
        let subtasks = querySubtask(task.uuid)
        for (index, sub) in subtasks.enumerate() {
            let subtask = Subtask()
            subtask.rootUUID = newTask.uuid
            subtask.taskToDo = sub.taskToDo
            let subtaskCreateDate = now.dateByAddingMinutes(index)
            subtask.createdDate = subtaskCreateDate
            subtask.uuid = subtaskCreateDate.createTaskUUID()
            writeObject(subtask)
        }
        debugPrint("copy task with name = \(task.taskToDo) and subtask count = \(task.subTaskCount)")
        
        return newTask
    }
    
    func updateTaskStatus(task: Task, status: Int, updateDate: NSDate? = nil) {
        try! realm.write({
            task.status = status
            if status == kTaskFinish {
                let now = NSDate()
                let subtasks = querySubtask(task.uuid)
                for subtask in subtasks {
                    subtask.finishedDate = updateDate ?? now
                }
                task.finishedDate = updateDate ?? now
            } else if status == kTaskRunning {
                task.finishedDate = nil
            } else {
                
            }
        })
    }
}

extension RealmManager {
    func queryCheckIn(year: Int, month: Int, day: Int) -> CheckIn? {
        return realm.objects(CheckIn.self)
            .filter("year = \(year) and month = \(month) and day = \(day)")
            .first
    }
    
    func saveCheckIn(checkIn: CheckIn) {
        if let old = queryCheckIn(checkIn.year, month: checkIn.month, day: checkIn.day) {
            deleteObject(old)
        }
        
        writeObject(checkIn)
    }
}

