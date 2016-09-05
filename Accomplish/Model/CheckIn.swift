//
//  CheckIn.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/5.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation
import RealmSwift

class CheckIn: Object {
    var month: Int = 0
    var year: Int = 0
    var day: Int = 0
    
    var finishCount = 0
    var runningCount = 0
}