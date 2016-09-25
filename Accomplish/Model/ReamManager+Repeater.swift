//
//  ReamManager+Repeater.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/3.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation
import RealmSwift

// repeater
extension RealmManager {

    // 更新指定的update，如果不存在直接创建一个
    func repeaterUpdate(_ task: Task, repeaterTimeType: RepeaterTimeType) {
        // 返回指定 task uuid 的repeater， 如果不存在创建一个
        if let repeater = self.queryRepeaterWithTask(task.uuid) {
            self.updateObject({
                repeater.repeatType = repeaterTimeType.rawValue
            })
            Logger.log("update type = \(repeaterTimeType.getCalendarUnit())")
        } else {
            let repeater = Repeater()
            repeater.repeatTaskUUID = task.uuid
            repeater.repeatQueryTaskUUID = task.uuid
            repeater.repeatType = repeaterTimeType.rawValue
            self.writeObject(repeater)
            
            Logger.log("create type = \(repeaterTimeType.getCalendarUnit())")
        }
        LocalNotificationManager().update(task)
    }
    
    func queryRepeaterWithTask(_ taskUUID: String) -> Repeater? {
        let repeater = realm.allObjects(ofType: Repeater.self)
            .filter(using: "repeatTaskUUID = '\(taskUUID)'")
            .first
        
        Logger.log("queryRepeaterWithTask = \(repeater)")
        return repeater
    }
    
    func allRepeater() -> Results<Repeater> {
        return realm.allObjects(ofType: Repeater.self)
    }
    
    func deleteRepeater(_ task: Task) {
        guard let repeater = self.queryRepeaterWithTask(task.uuid) else {
            return
        }
        
        self.deleteObject(repeater)
    }
}
