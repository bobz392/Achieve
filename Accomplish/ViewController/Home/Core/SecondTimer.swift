//
//  DateTimer.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/2.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation

struct SecondTimer {
    fileprivate let fetchSecondInterval: Int
    
    fileprivate var queue: DispatchQueue
    fileprivate var timer: DispatchSource
    
    fileprivate let  handle: () -> Void
    
    fileprivate var timerRunning = false
    
    init(handle: @escaping () -> Void, fetchSecondInterval: Int = 10 * 60) {
        self.handle = handle
        self.fetchSecondInterval = fetchSecondInterval
        
        queue = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default)
        timer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: UInt(0)), queue: queue) /*Migrator FIXME: Use DispatchSourceTimer to avoid the cast*/ as! DispatchSource
    }
    
    mutating func start() {
        let interval = UInt64(fetchSecondInterval) * NSEC_PER_SEC
        timer.setTimer(start: DispatchTime.now(), interval: interval, leeway: 60)
        timer.setEventHandler { () -> Void in
            dispatch_async_main({ () -> Void in
                self.handle()
            })
        }
        timer.resume()
        self.timerRunning = true
    }
    
    mutating func suspend() {
        if timerRunning == false {
            return
        }
        timer.suspend()
        self.timerRunning = false
    }
    
    mutating func stop() {
        if timerRunning == false {
            return
        }
        timer.cancel()
        timerRunning = false
    }
    
    mutating func resume() {
        if timerRunning == true {
            return
        }
        timer.resume()
        self.timerRunning = true
    }
}
