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
func Localized(_ key: String) -> String {
    return NSLocalizedString(key, comment: "")
}

func nowDate() -> Date {
    return Date()
}

/**
 延迟若干秒。
 */
func dispatch_delay(_ seconds: TimeInterval, closure: @escaping () -> Void) {
    let delta = Int64(seconds * TimeInterval(NSEC_PER_SEC))
    let delayTime = DispatchTime.now() + Double(delta) / Double(NSEC_PER_SEC)
    let queue = DispatchQueue.main
    queue.asyncAfter(deadline: delayTime, execute: closure)
}

func dispatch_async_main(_ closure: @escaping () -> Void) {
    DispatchQueue.main.async(execute: closure)
}

func dispatch_global_async(_ closure: @escaping () -> Void) {
    let queue = DispatchQueue.global()
    queue.async {
        closure()
    }
}

// uuid generator
func uuidGenerator() -> String {
    let newUniqueId = CFUUIDCreate(kCFAllocatorDefault)
    let uuidCFString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueId)
    return String(describing: uuidCFString)
}
