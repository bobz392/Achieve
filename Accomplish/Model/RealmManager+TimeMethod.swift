//
//  RealmManager+TimeMethod.swift
//  Accomplish
//
//  Created by zhoubo on 16/11/2.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation
import RealmSwift

extension RealmManager {

    func allTimeMethods() -> Results<TimeMethod> {
        return realm.objects(TimeMethod.self)
    }
    
    func queryTimeMethod(uuid: String) -> TimeMethod? {
        return realm.objects(TimeMethod.self).filter("uuid = '\(uuid)'").first
    }
}
