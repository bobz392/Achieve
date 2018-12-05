//
//  TimeMethod.swift
//  Accomplish
//
//  Created by zhoubo on 16/11/1.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation
import RealmSwift

class TimeMethod: Object {
    @objc dynamic var uuid: String = NSDate().createTimeManagerUUID()
    @objc dynamic var name: String = ""
    @objc dynamic var useTimes: Int = 0
    @objc dynamic var repeatTimes: Int = 0
    @objc dynamic var timeMethodAliase: String = Localized("defaultAliase")
    
    let groups = List<TimeMethodGroup>()
}

class TimeMethodGroup: Object {
    let items = List<TimeMethodItem>()
    @objc dynamic var repeatTimes: Int = 1
    
    func addDefaultGroupAndItem() {
        let item = TimeMethodItem()
        item.name = Localized("enterItemName")
        item.interval = 5
        self.items.append(item)
    }
}

class TimeMethodItem: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var interval: Int = 0
}
