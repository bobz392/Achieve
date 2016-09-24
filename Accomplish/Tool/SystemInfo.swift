//
//  SystemInfo.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/15.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation

struct Logger {
    static func log(_ log: Any, function: String = #function,
                    file: String = #file, line: Int = #line) {
        #if debug
            print("------------------------------------------")
            print( function, file, line)
            print()
            print(log)
            print()
        #endif
    }
}
