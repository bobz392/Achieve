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
    var detailType: TaskDetailType = .other
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let colors = Colors()
        self.backgroundColor = colors.cloudColor
        self.contentView.backgroundColor = colors.cloudColor
        
        self.clearButton.addTarget(self, action: #selector(self.clearAction(_:)), for: .touchUpInside)
        self.clearButton.createIconButton(iconSize: kTaskDetailCellIconSize, imageSize: kTaskClearCellIconSize,
                                          icon: "fa-times", color: colors.mainGreenColor, status: UIControlState())
        
        self.infoLabel.highlightedTextColor = colors.mainGreenColor
        self.infoLabel.textColor = colors.secondaryTextColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        selectedBackgroundView = UIView(frame: frame)
        selectedBackgroundView?.backgroundColor = Colors().selectedColor
        
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func clearAction(_ btn: UIButton) {
        guard let task = self.task else { return }
        
        switch self.detailType {
        case TaskDetailType.repeat:
            RealmManager.shareManager.deleteRepeater(task)
            
        case TaskDetailType.notify:
            RealmManager.shareManager.updateObject {
                task.notifyDate = nil
            }
            
            LocalNotificationManager().cancelNotify(task.uuid)
            
        case TaskDetailType.estimate:
            RealmManager.shareManager.updateObject({ 
                task.estimateDate = nil
            })
            
        default:
            break
        }
    }
    
    func configCell(_ task: Task, iconString: String) {
        self.task = task
        let colors = Colors()
        
        let iconSize = CGSize(width: kTaskDetailCellIconSize, height: kTaskDetailCellIconSize)
        let icon = try! FAKFontAwesome(identifier: iconString, size: kTaskDetailCellIconSize)
        icon.addAttributes([NSForegroundColorAttributeName: colors.secondaryTextColor])
        let image =
            icon.image(with: iconSize)
        self.iconImageView.image = image
        
        icon.addAttributes([NSForegroundColorAttributeName: colors.mainGreenColor])
        let hImage = icon.image(with: iconSize)
        self.iconImageView.highlightedImage = hImage
        
        self.clearButton.isHidden = false
        self.detailType = .other
        
        switch iconString {
            
        case TaskIconCalendar:
            self.infoLabel.isHighlighted = true
            guard let createdDate = task.createdDate else { break }
            let schedule = Localized("scheduled")
            self.infoLabel.text = schedule + " "
                + (createdDate as NSDate).formattedDate(withFormat: timeDateFormat)
            self.clearButton.isHidden = true
            self.iconImageView.isHighlighted = true
            
        case TaskIconBell:
            self.infoLabel.isHighlighted = task.notifyDate != nil
            
            if let notifyDate = task.notifyDate {
                self.infoLabel.text = Localized("reminderMe")
                    + notifyDate.timeDateString()
            } else {
                self.infoLabel.text = Localized("noReminder")
            }
            
            self.clearButton.isHidden = task.notifyDate == nil
            self.detailType = .notify
            self.iconImageView.isHighlighted = task.notifyDate != nil
            
        case TaskDueIconCalendar:
            if task.status == kTaskFinish {
                self.infoLabel.isHighlighted = task.finishedDate != nil
                self.clearButton.isHidden = true
                self.iconImageView.isHighlighted = task.finishedDate != nil
                self.detailType = .other
                
                if let finishDate = task.finishedDate {
                    self.infoLabel.text = Localized("finishAt") + (finishDate as NSDate).formattedDate(withFormat: timeDateFormat)
                }
            } else {
                self.infoLabel.isHighlighted = task.estimateDate != nil
                self.clearButton.isHidden = task.estimateDate == nil
                self.iconImageView.isHighlighted = task.estimateDate != nil
                self.detailType = .estimate
                
                if let estimateDate = task.estimateDate {
                    self.infoLabel.text = Localized("estimeateAt") + (estimateDate as NSDate).formattedDate(withFormat: timeDateFormat)
                } else {
                    self.infoLabel.text = Localized("noEstimate")
                }
            }
            
        case TaskIconRepeat:
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
            
            self.infoLabel.isHighlighted = hasRepeater
            self.clearButton.isHidden = !hasRepeater
            self.detailType = .repeat
            self.iconImageView.isHighlighted = hasRepeater
            
        default:
            break
        }
    }
    
    enum TaskDetailType: Int {
        case notify = 100
        case `repeat` = 101
        case estimate = 102
        case other = 0
    }
}
