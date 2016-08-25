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
    private let realm = try! Realm()
    
    static let shareManager = RealmManager()

    func createTask(task: Task) {
        try! realm.write {
            realm.add(task)
        }
    }
    
    func queryTodayTaskList(finished: Bool) -> Results<Task> {
        let queryDate = "'" + NSDate().formattedDateWithFormat(createdDateFormat) + "'"
        
        let tasks = realm
            .objects(Task.self)
            .filter("createdFormattedDate = \(queryDate) AND status \(finished ? "!=" : "==") \(kTaskRunning)")
        
        return tasks
    }
    
    func updateTaskStatus(task: Task, status: Int) {
        try! realm.write({ 
            task.status = status
            if status == kTaskFinish {
                task.finishedDate = NSDate()
            } else if status == kTaskRunning {
                task.finishedDate = nil
            } else {

            }
        })
    }
}