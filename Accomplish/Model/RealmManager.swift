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
    
    private let realm = try! Realm()
    
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
//        guard let queryDate = UserDefault().readString(kLastFetchDateKey) else {
//            fatalError("some bug with kLastFetchDateKey not exist")
//        }
//        
        let queryDate = NSDate().createdFormatedDateString()
        
        let tasks = realm
            .objects(Task.self)
            .filter("createdFormattedDate = '\(queryDate)' AND status \(finished ? "!=" : "==") \(kTaskRunning)")
            .sorted("createdDate")
        
        return tasks
    }
    
    func queryTask(taskUUID: String) -> Task? {
        return realm.objects(Task.self).filter("uuid = '\(taskUUID)'").first
    }
    
    func querySubtask(rootUUID: String) -> Results<Subtask> {
        return realm.objects(Subtask.self)
            .filter("rootUUID = '\(rootUUID)'")
            .sorted("createdDate")
    }
    
    func allRepeater() -> Results<Repeater> {
        return realm.objects(Repeater.self)
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
    
    func updateTaskStatus(task: Task, status: Int) {
        try! realm.write({
            task.status = status
            if status == kTaskFinish {
                let now = NSDate()
                let subtasks = querySubtask(task.uuid)
                for subtask in subtasks {
                    subtask.finishedDate = now
                }
                task.finishedDate = now
            } else if status == kTaskRunning {
                task.finishedDate = nil
            } else {
                
            }
        })
    }
}

// repeater
extension RealmManager {
    
    // 更新指定的update，如果不存在直接创建一个
    // 暂时没有考虑notify date
    func repeaterUpdate(task: Task, repeaterTimeType: RepeaterTimeType) {
        // 返回指定 task uuid 的repeater， 如果不存在创建一个
        if let repeater = queryRepeaterWithTask(task.uuid) {
            updateObject({
                repeater.repeatType = repeaterTimeType.rawValue
            })
            debugPrint("update type = \(repeaterTimeType.getCalendarUnit())")
        } else {
            let repeater = Repeater()
            repeater.repeatTaskUUID = task.uuid
            repeater.repeatType = repeaterTimeType.rawValue
            writeObject(repeater)
            
            debugPrint("create type = \(repeaterTimeType.getCalendarUnit())")
        }
        LocalNotificationManager().updateNotify(task, repeatInterval: repeaterTimeType.getCalendarUnit())
        print("notfiy = \(LocalNotificationManager().notifyWithUUID(task.uuid))")
    }
    
    func queryRepeaterWithTask(taskUUID: String) -> Repeater? {
        let repeater = realm.objects(Repeater.self)
            .filter("repeatTaskUUID = '\(taskUUID)'")
            .first
        return repeater
    }
    
    func deleteRepeater(task: Task) {
        if let repeater = queryRepeaterWithTask(task.uuid) {
            deleteObject(repeater)
        }
        
        LocalNotificationManager().updateNotify(task, repeatInterval: NSCalendarUnit(rawValue: 0))
    }
    
    func updateRepeater(repeater: Repeater) {
        
    }
}