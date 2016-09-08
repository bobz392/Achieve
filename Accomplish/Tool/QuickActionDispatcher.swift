//
//  QuickActionDispatcher.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/8.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation

enum QuickActionType: String {
    case Create = "com.zhoubo.Accomplish.new"
    case Calendar = "com.zhoubo.Accomplish.calendar"
}

@available(iOS 9.0, *)
struct QuickActionDispatcher {
    
    typealias QuickActionCompletion = (Bool) -> Void
    
    func dispatch(shortcutItem: UIApplicationShortcutItem, completion: QuickActionCompletion) {
        switch shortcutItem.type {
        case QuickActionType.Create.rawValue:
            self.handleCreate()
            
        case QuickActionType.Calendar.rawValue:
            self.handleCalender()
            
        default:
            break
        }
    }
    
    private func rootViewController() -> UINavigationController? {
        return UIApplication.sharedApplication().keyWindow?.rootViewController as? UINavigationController
    }
    
    private func handleCreate() {
        guard let rootNavigationController = rootViewController() else { return }
        rootNavigationController.popToRootViewControllerAnimated(false)
        guard let homeVC = rootNavigationController.viewControllers.first as? HomeViewController else { return }
        homeVC.newTaskAction()
    }
    
    private func handleCalender() {
        guard let rootNavigationController = rootViewController() else { return }
        rootNavigationController.popToRootViewControllerAnimated(false)
        let calendar = CalendarViewController()
        rootNavigationController.pushViewController(calendar, animated: true)
    }
}