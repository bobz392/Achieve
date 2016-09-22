//
//  QuickActionDispatcher.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/8.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation

enum QuickActionType: String {
    case Create = "com.zhoubo.Achieve.new"
    case Calendar = "com.zhoubo.Achieve.calendar"
    case Search = "com.zhoub.Achieve.search"
}

@available(iOS 9.0, *)
struct QuickActionDispatcher {
    
    typealias QuickActionCompletion = (Bool) -> Void
    
    func dispatch(_ shortcutItem: UIApplicationShortcutItem, completion: QuickActionCompletion) {
        switch shortcutItem.type {
        case QuickActionType.Create.rawValue:
            self.handleCreate()
            
        case QuickActionType.Calendar.rawValue:
            self.handleCalender()
    
        case QuickActionType.Search.rawValue:
            self.handleSearch()
            
        default:
            break
        }
    }
    
    fileprivate func rootViewController() -> UINavigationController? {
        return UIApplication.shared.keyWindow?.rootViewController as? UINavigationController
    }
    
    fileprivate func handleCreate() {
        guard let rootNavigationController = rootViewController() else { return }
        rootNavigationController.popToRootViewController(animated: false)
        guard let homeVC = rootNavigationController.viewControllers.first as? HomeViewController else { return }
        homeVC.newTaskAction()
    }
    
    fileprivate func handleCalender() {
        guard let rootNavigationController = rootViewController() else { return }
        rootNavigationController.popToRootViewController(animated: false)
        let calendar = CalendarViewController()
        rootNavigationController.pushViewController(calendar, animated: true)
    }
    
    fileprivate func handleSearch() {
        guard let rootNavigationController = rootViewController() else { return }
        rootNavigationController.popToRootViewController(animated: false)
        let search = SearchViewController()
        rootNavigationController.pushViewController(search, animated: true)
    }
}
