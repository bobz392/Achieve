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
    
    init(handle: () -> Void, fetchSecondInterval: Int = 5) {
        self.handle = handle
        self.fetchSecondInterval = fetchSecondInterval
        
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue)
    }
    
    func start() {
        let interval = UInt64(fetchSecondInterval) * NSEC_PER_SEC
        dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, interval, 0)
        dispatch_source_set_event_handler(timer) { () -> Void in
            dispatch_async_main({ () -> Void in
                self.handle()
            })
        }
        dispatch_resume(timer)
    }
    
    func suspend() {
        dispatch_suspend(timer)
    }
    
    func stop() {
        dispatch_source_cancel(timer)
    }
    
    func resume() {
        dispatch_resume(timer)
    }
}