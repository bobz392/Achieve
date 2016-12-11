//
//  RealmManager+ReadLater.swift
//  Accomplish
//
//  Created by zhoubo on 16/12/11.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation
import RealmSwift

extension RealmManager {
    
    func allReadLaters() -> Results<ReadLater> {
        return realm.objects(ReadLater.self)
    }
}
