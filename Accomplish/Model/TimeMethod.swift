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
    dynamic var name: String = ""
    dynamic var useTimes: Int = 0
    dynamic var repeatTimes: Int = 0
    dynamic var timeMethodAliase: String = Localized("defaultAliase")
    
    let groups = List<TimeMethodGroup>()
}

class TimeMethodGroup: Object {
    let items = List<TimeMethodItem>()
    dynamic var repeatTimes: Int = 1
}

class TimeMethodItem: Object {
    dynamic var name: String = ""
    dynamic var interval: Int = 0
}
