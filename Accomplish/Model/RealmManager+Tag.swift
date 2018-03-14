//
//  RealmManager+Tag.swift
//  Accomplish
//
//  Created by zhoubo on 16/12/11.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation
import RealmSwift

extension RealmManager {
    func saveTag(_ tag: Tag) -> Bool {
        if let _ = queryTag(usingName: true, query: tag.name) {
            return false
        }
        
        writeObject(tag)
        return true
    }
    
    func queryTag(usingName name: Bool, query: String) -> Tag? {
        let q = name == true ? "name" : "tagUUID"
        return realm
            .objects(Tag.self)
            .filter("\(q) = '\(query)'")
            .first
    }
    
    func allTags() -> Results<Tag> {
        return realm.objects(Tag.self)
            .sorted(byKeyPath: "createdAt")
    }
}
