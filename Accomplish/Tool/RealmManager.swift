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
        let queryDate = "'" + NSDate().formattedDateWithFormat(createdDateFormat) + "'"
        
        let tasks = realm
            .objects(Task.self)
            .filter("createdFormattedDate = \(queryDate) AND status \(finished ? "!=" : "==") \(kTaskRunning)")
            .sorted("createdDate")
        
        return tasks
    }
    
    func querySubtask(rootUUID: String) -> Results<Subtask> {
        return realm.objects(Subtask.self).filter("rootUUID = '\(rootUUID)'").sorted("createdDate")
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