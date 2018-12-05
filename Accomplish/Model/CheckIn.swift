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
    @objc dynamic var checkInDate: NSDate?
    @objc dynamic var formatedDate: String = ""
    
    @objc dynamic var createdCount: Int = 0
    @objc  dynamic var completedCount: Int = 0
    
    @objc dynamic var asynced: Bool = false
}
