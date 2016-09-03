//
//  Reapter.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/1.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation
import RealmSwift

class Repeater: Object {
    dynamic var uuid: String = uuidGenerator()
    dynamic var repeatTaskUUID: String = ""
    dynamic var repeatType: Int = 0
    dynamic var notifyUUID: String? = nil
}