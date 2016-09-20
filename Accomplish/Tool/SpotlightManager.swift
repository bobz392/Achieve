//
//  SpotlightManager.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/20.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation
import CoreSpotlight
import MobileCoreServices

@available(iOS 9.0, *)
struct SpotlightManager {
    
    func addDateTaskToIndex(date: NSDate = NSDate()) {
        self.removeAllFromIndex()
        
        let tasks = RealmManager.shareManager.queryTaskList(date)
        let items: [CSSearchableItem] = tasks.map { (task) -> CSSearchableItem in
            return self.createSearchableItem(task: task)
        }
        CSSearchableIndex.default().indexSearchableItems(items, completionHandler: nil)
    }
    
    func addTaskToIndex(task: Task) {
        let items = [self.createSearchableItem(task: task)]
        CSSearchableIndex.default().indexSearchableItems(items, completionHandler: nil)
    }
    
    fileprivate func createSearchableItem(task: Task) -> CSSearchableItem {
        let attributes = CSSearchableItemAttributeSet(itemContentType: kUTTypeContent as String)
        attributes.title = task.getNormalDisplayTitle()
        attributes.identifier = task.uuid
        if let image = UIImage(named: "AppIcon"),
            let data = UIImagePNGRepresentation(image){
            attributes.thumbnailData = data
        }
        attributes.contentCreationDate = task.createdDate as Date?
        return CSSearchableItem(uniqueIdentifier: task.uuid, domainIdentifier: "achieve.today.task", attributeSet: attributes)
    }
    
    func removeFromIndex(task: Task) {
        CSSearchableIndex.default()
            .deleteSearchableItems(withIdentifiers: [task.uuid], completionHandler: nil)
    }
    
    func removeAllFromIndex() {
        CSSearchableIndex.default()
            .deleteAllSearchableItems(completionHandler: nil)
    }
}
