//
//  DateTimer.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/2.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation

struct SecondTimer {
    private let fetchSecondInterval: Int
    
    private var queue: dispatch_queue_t
    private var timer: dispatch_source_t
    
    private let  handle: () -> Void
    
    private var timerRunning = false
    
    init(handle: () -> Void, fetchSecondInterval: Int = 10 * 60) {
        self.handle = handle
        self.fetchSecondInterval = fetchSecondInterval
        
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue)
    }
    
    mutating func start() {
        let interval = UInt64(fetchSecondInterval) * NSEC_PER_SEC
        dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, interval, 60)
        dispatch_source_set_event_handler(timer) { () -> Void in
            dispatch_async_main({ () -> Void in
                self.handle()
            })
        }
        dispatch_resume(timer)
        self.timerRunning = true
    }
    
    mutating func suspend() {
        if timerRunning == false {
            return
        }
        dispatch_suspend(timer)
        self.timerRunning = false
    }
    
    mutating func stop() {
        if timerRunning == false {
            return
        }
        dispatch_source_cancel(timer)
        timerRunning = false
    }
    
    mutating func resume() {
        if timerRunning == true {
            return
        }
        dispatch_resume(timer)
        self.timerRunning = true
    }
}