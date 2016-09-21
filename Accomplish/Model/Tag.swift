//
//  Tag.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/15.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation
import RealmSwift

class Tag: Object {
    dynamic var tagUUID: String = ""
    dynamic var name: String = ""
    dynamic var createdAt: NSDate? = nil
}
