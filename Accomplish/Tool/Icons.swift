//
//  FontAwsomes.swift
//  Accomplish
//
//  Created by zhoubo on 16/12/19.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation

enum Icons {
    case plus
    case check
    case uncheck
    case listEmpty
    case search
    case timeManagement
    case delete
    case back
    case loop
    case notify
    case schedule
    case smallPlus
    case tag
    case due
    case note
    case clear
    case smallDelete
    case arrangement
    case calendar
    case readLater
    case settings
    case weekStart
    case home
    case finish
    case unfinish
    case export
    
    func iconString() -> String {
        switch self {
        case .plus: return "plus"
        case .check: return "check"
        case .uncheck: return "uncheck"
        case .listEmpty: return "empty_list"
        case .search:  return "search"
        case .timeManagement: return "time_management"
        case .delete: return "delete"
        case .back: return "back"
        case .loop: return "loop"
        case .notify: return "notify"
        case .schedule: return "schedule"
        case .smallPlus: return "small_plus"
        case .tag: return "tag"
        case .due: return "due"
        case .note: return "note"
        case .clear:  return "clear"
        case .smallDelete: return "small_delete"
        case .arrangement: return "arrangement"
        case .calendar: return "calendar"
        case .readLater: return "read_later"
        case .settings: return "settings"
        case .weekStart: return "week_start"
        case .home: return "home"
        case .finish: return "finish"
        case .unfinish: return "unfinish"
        case .export: return "export"
        }
    }
    
    func iconImage() -> UIImage? {
        return UIImage(named: self.iconString())?.withRenderingMode(.alwaysTemplate)
    }
}
