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
    dynamic var checkInDate: NSDate?
    dynamic var formatedDate: String = ""
    
    dynamic var createdCount: Int = 0
    dynamic var completedCount: Int = 0
}
