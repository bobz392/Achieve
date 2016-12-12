//
//  ReadLater.swift
//  Accomplish
//
//  Created by zhoubo on 16/12/11.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation
import RealmSwift

class ReadLater: Object {
    dynamic var uuid: String = ""
    dynamic var name: String = ""
    dynamic var link: String = ""
    dynamic var createdAt: NSDate? = nil
    dynamic var cacheed: Bool = false
    dynamic var previewImageLink: String?
}
