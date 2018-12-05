//
//  SystemInfo.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/15.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation

struct Logger {
    
    static let queue = DispatchQueue(label: "achieve.logger", qos: DispatchQoS.background)
    
    static func log(_ log: Any, function: String = #function,
                    file: String = #file, line: Int = #line) {
        #if debug
        
        queue.async(group: nil, qos: DispatchQoS.utility, flags: DispatchWorkItemFlags.barrier) {
            print("\n")
            print("╔═══════════════════════════════════════════════════════════")
            print("║", function, line)
            print("║", file)
            print("╟───────────────────────────────────────────────────────────")
            print("║ \(log)")
            print("╚═══════════════════════════════════════════════════════════")
            print("\n")
        }
        
        #endif
    }
}
