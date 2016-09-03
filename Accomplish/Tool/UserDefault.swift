//
//  UserDefault.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/25.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation

let kIsFullScreenSizeKey = "com.zhoubo.currentScreenSizeKey"
let kLastFetchDateKey = "com.zhoubo.last.fetch"

struct UserDefault {
    let def = NSUserDefaults.standardUserDefaults()
    
    func write(key: String, value: AnyObject) {
        debugPrint("write to user default with key = \(key) and value = \(value)")
        def.setObject(value, forKey: key)
        def.synchronize()
    }
    
    func readBool(key: String) -> Bool {
        return def.boolForKey(key)
    }
    
    func readString(key: String) -> String? {
        return def.stringForKey(key)
    }
    
    func remove(key: String) {
        def.removeObjectForKey(key)
        def.synchronize()
    }
}

