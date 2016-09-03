//
//  CommonCode.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/24.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation

/**
 ** 本地化
 **/
func Localized(key: String) -> String {
    return NSLocalizedString(key, comment: "")
}

func nowDate() -> NSDate {
    return NSDate()
}

func beginDebugPrint(someTag: String = "") {
    debugPrint("")
    debugPrint("")
    debugPrint("========================\(someTag) begin============================")
}

func endDebugPrint(someTag: String = "") {
    debugPrint("========================\(someTag) end==============================")
    debugPrint("")
    debugPrint("")
}

/**
 延迟若干秒。
 */
func dispatch_delay(seconds: NSTimeInterval, closure: () -> Void) {
    let delta = Int64(seconds * NSTimeInterval(NSEC_PER_SEC))
    let delayTime = dispatch_time(DISPATCH_TIME_NOW, delta)
    let queue = dispatch_get_main_queue()
    dispatch_after(delayTime, queue, closure)
}

func dispatch_async_main(closure: () -> Void) {
    let queue = dispatch_get_main_queue()
    dispatch_async(queue, closure)
}

func dispatch_global_async(closure: () -> Void) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
        closure()
    }
}

// uuid generator
func uuidGenerator() -> String {
    let newUniqueId = CFUUIDCreate(kCFAllocatorDefault)
    let uuidCFString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueId)
    return String(uuidCFString)
}

/**
 ** screen
 **/
let screenBounds = UIScreen.mainScreen().bounds