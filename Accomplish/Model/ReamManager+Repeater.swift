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
    
    func allRepeater() -> Results<Repeater> {
        return realm.objects(Repeater.self)
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