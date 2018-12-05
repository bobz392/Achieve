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
    @objc dynamic var tagUUID: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var createdAt: NSDate? = nil
}
