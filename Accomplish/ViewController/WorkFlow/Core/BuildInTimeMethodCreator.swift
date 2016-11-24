//
//  BuildInTimeMethodCreator.swift
//  Accomplish
//
//  Created by zhoubo on 16/11/2.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation

let kTimeMethodInfiniteRepeat = -1

struct BuildInTimeMethodCreator {
    
    func pomodoroCreator() {
        
        let timeMethod = TimeMethod()
        timeMethod.repeatTimes = kTimeMethodInfiniteRepeat
        timeMethod.name = Localized("pomodoro")
        
        let group1 = TimeMethodGroup()
        group1.repeatTimes = 3
        
        let workItem1 = TimeMethodItem()
        workItem1.name = Localized("pomodoroWork")
        workItem1.interval = 25
        
        let restItem1 = TimeMethodItem()
        restItem1.name = Localized("pomodoroRest")
        restItem1.interval = 5
        
        group1.items.append(workItem1)
        group1.items.append(restItem1)
        
        timeMethod.groups.append(group1)
        
        let group2 = TimeMethodGroup()
        group2.repeatTimes = 1
        
        let workItem2 = TimeMethodItem()
        workItem2.name = Localized("pomodoroWork")
        workItem2.interval = 25
        
        let restItem2 = TimeMethodItem()
        restItem2.name = Localized("pomodoroLongRest")
        restItem2.interval = 25
        
        group2.items.append(workItem2)
        group2.items.append(restItem2)
        
        timeMethod.groups.append(group2)
        
        RealmManager.shared.writeObjects([timeMethod])
    }
    
}
