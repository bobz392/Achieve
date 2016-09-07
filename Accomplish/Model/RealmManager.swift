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
    
    func queryYesterdayTaskCount() -> (complete: Int, created: Int) {
        let yesterday = NSDate().dateBySubtractingDays(1)
        return queryTaskCount(yesterday)
    }
    
    func queryTaskCount(date: NSDate) -> (complete: Int, created: Int) {
        let task = realm.objects(Task.self)
            .filter("createdFormattedDate = '\(date.createdFormatedDateString())'")
        
        let created = task.count
        let complete = task.filter("status == \(kTaskFinish)").count
        
        return (complete, created)
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

// 以后为多个年的chekc in 优化
extension RealmManager {
    func queryFirstCheckIn() -> CheckIn? {
        return realm.objects(CheckIn.self).sorted("checkInDate", ascending: true).first
    }
    
    func queryCheckIn(formatedDate: String) -> CheckIn? {
        return realm.objects(CheckIn.self)
            .filter("formatedDate = '\(formatedDate)'")
            .first
    }
    
    func saveCheckIn(checkIn: CheckIn) {
        if let old = queryCheckIn(checkIn.formatedDate) {
            deleteObject(old)
        }
        
        writeObject(checkIn)
    }
    
    func allCheckIn() -> Results<CheckIn> {
        return realm.objects(CheckIn.self)
    }
}

