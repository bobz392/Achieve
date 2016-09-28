//
//  UserDefault.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/25.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation

let kIsFullScreenSizeKey = "com.zhoubo.currentScreenSizeKey"
let kWeekStartKey = "com.date.start"
let kCloseDueTodayKey = "com.due.today"
let kCloseHintKey = "com.close.hint"
let kCloseSoundKey = "com.close.finish.sound"
let kBackgroundKey = "com.background"
let kWatchDateHasNewKey = "com.watch.date.is.new"
let kCurrentTagUUIDKey = "com.current.tag"
let kUserFirstTimeCallNoitification = "com.call.notification"
let kCheckMoveUnfinishTaskKey = "com.check.unfinish.task"

struct AppUserDefault {
    let def = UserDefaults.standard
    
    func write(_ key: String, value: Any) {
//        Logger.log("write to user default with key = \(key) and value = \(value)")
        def.set(value, forKey: key)
        def.synchronize()
    }
    
    func readBool(_ key: String) -> Bool {
        return def.bool(forKey: key)
    }
    
    func readString(_ key: String) -> String? {
        return def.string(forKey: key)
    }
    
    func readInt(_ key: String) -> Int {
        return def.integer(forKey: key)
    }
    
    func remove(_ key: String) {
        def.removeObject(forKey: key)
        def.synchronize()
    }
}

