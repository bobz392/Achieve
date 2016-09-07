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
    var checkInDate: NSDate?
    var formatedDate: String = ""
    
    var createdCount = 0
    var completedCount = 0
}