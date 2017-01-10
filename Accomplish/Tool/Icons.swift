//
//  FontAwsomes.swift
//  Accomplish
//
//  Created by zhoubo on 16/12/19.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

enum Icons {
    case plus
    case check
    case uncheck
    case coffee
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
    case closeDown
    case save
    case rename
    case briefcase
    case about
    case delay
    case sound
    case mail
    case star
    case play
    case stop
    case bigClear
    
    func iconString() -> String {
        switch self {
        case .plus: return "plus"
        case .check: return "check"
        case .uncheck: return "uncheck"
        case .coffee: return "coffee"
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
        case .settings: return "settings"
        case .home: return "home"
        case .finish: return "finish"
        case .unfinish: return "unfinish"
        case .export: return "export"
        case .closeDown: return "close_down"
        case .save: return "save"
        case .rename: return "rename"
        case .briefcase: return "briefcase"
        case .about: return "about"
        case .delay: return "delay"
        case .mail: return "mail"
        case .sound: return "sound"
        case .star: return "star"
        case .weekStart: return "week_start"
        case .readLater: return "read_later"
        case .play: return "play"
        case .stop: return "stop"
        case .bigClear: return "big_clear"
        }
    }
    
    func iconImage() -> UIImage? {
        return UIImage(named: self.iconString())?.withRenderingMode(.alwaysTemplate)
    }
}
