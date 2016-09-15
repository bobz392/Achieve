//
//  DateTimer.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/2.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation

final class SecondTimer {
    fileprivate let fetchSecondInterval: Int
    
    fileprivate var queue: DispatchQueue
    fileprivate var timer: DispatchSourceTimer
    
    fileprivate let handle: () -> Void
    
    fileprivate var timerRunning = false
    
    init(handle: @escaping () -> Void, fetchSecondInterval: Int = 10 * 60) {
        self.handle = handle
        self.fetchSecondInterval = fetchSecondInterval
        
        queue = DispatchQueue.global()
        timer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: UInt(0)), queue: queue)
    }
    
    func start() {
        let interval = Double(fetchSecondInterval)
        timer.scheduleRepeating(deadline: DispatchTime.now(), interval: interval, leeway: DispatchTimeInterval.seconds(60))
        
        timer.setEventHandler { () -> Void in
            dispatch_async_main({ () -> Void in
                self.handle()
            })
        }
        timer.resume()
        self.timerRunning = true
    }
    
    func suspend() {
        if timerRunning == false {
            return
        }
        timer.suspend()
        self.timerRunning = false
    }
    
    func stop() {
        if timerRunning == false {
            return
        }
        timer.cancel()
        timerRunning = false
    }
    
    func resume() {
        if timerRunning == true {
            return
        }
        timer.resume()
        self.timerRunning = true
    }
}
