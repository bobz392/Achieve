//
//  CommonCode.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/24.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation

func Localized(key: String) -> String {
    return NSLocalizedString(key, comment: "")
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
