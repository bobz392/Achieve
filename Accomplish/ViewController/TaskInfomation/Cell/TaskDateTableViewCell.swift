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
let kNoteCellIconSize: CGFloat =  19
let kTaskButtonIconSize: CGFloat = 20

class TaskDateTableViewCell: UITableViewCell {
    
    static let nib = UINib(nibName: "TaskDateTableViewCell", bundle: nil)
    static let reuseId = "taskDateTableViewCell"
    static let rowHeight: CGFloat = 38
  
//    @IBOutlet weak var iconButton: UIButton!
    @IBOutlet weak var iconImageView: UIImageView!
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
        
        self.clearButton.addTarget(self, action: #selector(self.clearAction(_:)), forControlEvents: .TouchUpInside)
        self.clearButton.createIconButton(iconSize: kTaskDetailCellIconSize, imageSize: kTaskClearCellIconSize,
                                          icon: "fa-times", color: colors.mainGreenColor, status: .Normal)
        
        self.infoLabel.highlightedTextColor = colors.mainGreenColor
        self.infoLabel.textColor = colors.secondaryTextColor
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
            RealmManager.shareManager.deleteRepeater(task)
            
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
        
        let iconSize = CGSize(width: kTaskDetailCellIconSize, height: kTaskDetailCellIconSize)
        let icon = try! FAKFontAwesome(identifier: iconString, size: kTaskDetailCellIconSize)
        icon.addAttributes([NSForegroundColorAttributeName: colors.secondaryTextColor])
        let image =
            icon.imageWithSize(iconSize)
        self.iconImageView.image = image
        
        icon.addAttributes([NSForegroundColorAttributeName: colors.mainGreenColor])
        let hImage = icon.imageWithSize(iconSize)
        self.iconImageView.highlightedImage = hImage
        
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
            self.clearButton.hidden = true
            self.iconImageView.highlighted = true
            
        case SubtaskIconBell:
            self.infoLabel.highlighted = task.notifyDate != nil
            if let notifyDate = task.notifyDate {
                self.infoLabel.text = Localized("reminderMe")
                    + notifyDate.timeDateString()
            } else {
                self.infoLabel.text = Localized("noReminder")
            }
        
            self.clearButton.hidden = task.notifyDate == nil
            self.detailType = .Notify
            self.iconImageView.highlighted = task.notifyDate != nil
            
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
            self.iconImageView.highlighted = hasRepeater
            
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
