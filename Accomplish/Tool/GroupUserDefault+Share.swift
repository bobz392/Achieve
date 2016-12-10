//
//  GroupUserDefault+Share.swift
//  Accomplish
//
//  Created by zhoubo on 16/12/8.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation

let ExtensionReadLaterKey = "read.later.share"

// MARK: - share
extension GroupUserDefault {
    func writeReadLaterOrTask(name: String, content: String, type: String) {
        let shareArray = buildShareArray(name: name, content: content, type: type)
        guard var shareOldDatas =
            self.groupDefault.array(forKey: ExtensionReadLaterKey) as? [[String]] else {
                self.groupDefault.set([shareArray], forKey: ExtensionReadLaterKey)
                return
        }
        shareOldDatas.append(shareArray)
        self.groupDefault.set(shareOldDatas, forKey: ExtensionReadLaterKey)
    }

    func getReadLatersOrTask() -> [GroupShareModle] {
        var shareModles = [GroupShareModle]()
        guard let readLaters =
            self.groupDefault.array(forKey: ExtensionReadLaterKey) as? [[String]] else {
                return shareModles
        }
        
        for later in readLaters {
            let uuid = later[GroupReadLaterDateIndex]
            let name = later[GroupReadLaterNameIndex]
            let link = later[GroupReadLaterLinkIndex]
            let date = later[GroupReadLaterDateIndex].dateFromString(UUIDFormat)
            let type =
                ShareContentType(rawValue: later[GroupReadLaterTypeIndex])
            
            let modle = GroupShareModle(uuid: uuid, name: name, linkOrContent: link,
                                        date: date, type: type ?? .Unknown)
            shareModles.append(modle)
        }
        
        return shareModles
    }
    
    // 构建user default 中的string 数组，按照指定的 index 创建
    private func buildShareArray(name: String, content: String, type: String) -> [String] {
        var array = [String]()
        let date = NSDate().createTaskUUID()
        array.append(name)
        array.append(content)
        array.append(date)
        array.append(type)
        
        return array
    }
    
    func clearShareData() {
        self.groupDefault.removeObject(forKey: ExtensionReadLaterKey)
    }
}

let GroupReadLaterNameIndex = 0
let GroupReadLaterLinkIndex = 1
// date index also use for uuid
let GroupReadLaterDateIndex = 2
let GroupReadLaterTypeIndex = 3

struct GroupShareModle {
    let uuid: String
    let name: String
    let linkOrContent: String
    let date: NSDate
    let type: ShareContentType
}

enum ShareContentType: String {
    case Unknown = "unknown"
    case URL = "url"
    case PlainText = "text"
}
