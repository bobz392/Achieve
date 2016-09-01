//
//  Trigger.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/26.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import RealmSwift

class Trigger: Object {
    dynamic var triggerTo: String = ""
    dynamic var condition: Int = 0
}

enum TriggerCondition: Int {
    case tIf = 0
    case tRepeat = 1
    case tElse = 2
}