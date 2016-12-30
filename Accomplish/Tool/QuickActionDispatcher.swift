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
    private let controllerUtil = ControllerUtil()
    
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
    
    fileprivate func handleCreate() {
        Logger.log(controllerUtil.menuHomeViewControllers())
        let (menuVC, homeVC) = controllerUtil.menuHomeViewControllers()
        menuVC?.selectedNewMenu(index: 0)
        homeVC?.newTaskAction()
    }
    
    fileprivate func handleCalender() {
        let (menuVC, _) = controllerUtil.menuHomeViewControllers()
        menuVC?.selectedNewMenu(index: 1)
    }
    
    fileprivate func handleSearch() {
        guard let drawer = controllerUtil.drawerController() else { return }
        let search = SearchViewController()
        drawer.navigationController?.pushViewController(search, animated: true)
    }
}
