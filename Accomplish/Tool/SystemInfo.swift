//
//  SystemInfo.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/15.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation

struct SystemInfo {
    static let shareSystemInfo = SystemInfo()
    
    fileprivate let aboveOS8: Bool
    fileprivate let aboveOS9: Bool
    fileprivate let aboveOS10: Bool
    
    func isAboveOS9() -> Bool {
        debugPrint("SystemInfo.isAboveOS9   ======> \(self.aboveOS9)")
        return aboveOS9
    }
    
    func isAboveOS10() -> Bool {
        debugPrint("SystemInfo.isAboveOS10   ======> \(self.aboveOS10)")
        return aboveOS10
    }
    
    private init() {
        let systemVersion = UIDevice.current.systemVersion.components(separatedBy: ".")
        let version = NSString(string: systemVersion[0]).intValue
        self.aboveOS8 = version == 8
        self.aboveOS9 = version == 9
        self.aboveOS10 = version >= 10
    }
}
