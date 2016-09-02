//
//  TaskDateTableViewCell.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/30.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

let kTaskDetailCellIconSize: CGFloat = 18
let kTaskClearCellIconSize: CGFloat = 16

class TaskDateTableViewCell: UITableViewCell {
    
    static let nib = UINib(nibName: "TaskDateTableViewCell", bundle: nil)
    static let reuseId = "taskDateTableViewCell"
    static let rowHeight: CGFloat = 40
  
    @IBOutlet weak var iconButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var clearButton: UIButton!
    
    var task: Task?
    var detailType: TaskDetailType = .Other
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let colors = Colors()
        self.backgroundColor = colors.cloudColor
        self.contentView.backgroundColor = colors.cloudColor
        
        
        self.clearButton.tintColor = colors.mainGreenColor
        let icon = try! FAKFontAwesome(identifier: "fa-times", size: kTaskDetailCellIconSize)
        icon.addAttribute(NSForegroundColorAttributeName, value: colors.mainGreenColor)
        let iconImage = icon.imageWithSize(CGSize(width: kTaskClearCellIconSize, height: kTaskClearCellIconSize))
        self.clearButton.setImage(iconImage, forState: .Normal)
        self.clearButton.addTarget(self, action: #selector(self.clearAction(_:)), forControlEvents: .TouchUpInside)
        
        self.infoLabel.highlightedTextColor = colors.mainGreenColor
        self.infoLabel.textColor = colors.placeHolderTextColor
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        selectedBackgroundView = UIView(frame: frame)
        selectedBackgroundView?.backgroundColor = Colors().selectedColor
        
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func clearAction(btn: UIButton) {
        guard let task = self.task else { return }
        
        switch self.detailType {
        case TaskDetailType.Repeat:
            RealmManager.shareManager.deleteRepeater(task.uuid)
            
        case TaskDetailType.Notify:
            RealmManager.shareManager.updateObject {
                task.notifyDate = nil
            }
            
            LocalNotificationManager().cancelNotify(task.uuid)
            
        default:
            break
        }
        
    }
    
    func configCell(task: Task, iconString: String) {
        self.task = task
        let colors = Colors()
        
        let icon = try! FAKFontAwesome(identifier: iconString, size: kTaskDetailCellIconSize)
        let image =
            icon.imageWithSize(CGSize(width: kTaskDetailCellIconSize, height: kTaskDetailCellIconSize))
        self.iconButton.setImage(image, forState: .Normal)
        self.clearButton.hidden = false
        self.detailType = .Other
        
        switch iconString {
        case SubtaskIconCalendar:
            self.infoLabel.highlighted = true
            guard let createdDate = task.createdDate else { break }
            let schedule = Localized("scheduled")
            if createdDate.isToday() {
                self.infoLabel.text = schedule + Localized("today")
            } else if createdDate.isTomorrow() {
                self.infoLabel.text = schedule + Localized("tomorrow")
            } else if createdDate.isYesterday() {
                self.infoLabel.text = schedule + Localized("yesterday")
            } else {
                self.infoLabel.text = schedule + " "
                    + createdDate.formattedDateWithStyle(.MediumStyle)
            }
//                Localized(task.canPostpone ? "detailPostponeTomorrow" : "detailIncomplete")
            self.clearButton.hidden = true
            self.iconButton.tintColor = colors.mainGreenColor
            
        case SubtaskIconBell:
            self.infoLabel.highlighted = task.notifyDate != nil
            if let notifyDate = task.notifyDate {
                self.infoLabel.text = Localized("reminderMe")
                    + notifyDate.formattedDateWithFormat(timeDateFormat)
            } else {
                self.infoLabel.text = Localized("noReminder")
            }
        
            self.clearButton.hidden = task.notifyDate == nil
            self.detailType = .Notify
            self.iconButton.tintColor =
                task.notifyDate == nil ? colors.secondaryTextColor : colors.mainGreenColor
            
        case SubtaskIconRepeat:
            let hasRepeater: Bool
            if let repeater = RealmManager.shareManager.queryRepeaterWithTask(task.uuid) {
                hasRepeater = true
                if let type = RepeaterTimeType(rawValue: repeater.repeatType),
                    let createDate = task.createdDate {
                    self.infoLabel.text = Localized("repeat")
                        + type.repeaterTitle(createDate)
                } else {
                    self.infoLabel.text = Localized("repeat")
                }
            } else {
                hasRepeater = false
                self.infoLabel.text = Localized("noRepeat")
            }
            self.infoLabel.highlighted = hasRepeater
            self.clearButton.hidden = !hasRepeater
            self.detailType = .Repeat
            self.iconButton.tintColor =
                hasRepeater ? colors.mainGreenColor : colors.secondaryTextColor
            
        default:
            break
        }
    }
    
    enum TaskDetailType: Int {
        case Notify = 100
        case Repeat = 101
        case Other = 0
    }
}
