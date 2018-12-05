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
    @objc dynamic var uuid: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var link: String = ""
    @objc dynamic var createdAt: NSDate? = nil
    @objc dynamic var cacheed: Bool = false
    @objc dynamic var previewImageLink: String?
}
