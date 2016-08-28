//
//  TaskTableViewCell.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/24.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit
import YYText
import SnapKit

class TaskTableViewCell: UITableViewCell {
    
    static let nib = UINib(nibName: "TaskTableViewCell", bundle: nil)
    static let reuseId = "taskTableViewCell"
    static let rowHeight: CGFloat = 65
    
    @IBOutlet weak var taskInfoButton: UIButton!
    @IBOutlet weak var taskSettingButton: UIButton!
    @IBOutlet weak var taskStatusButton: UIButton!
    @IBOutlet weak var priorityView: UIView!
    @IBOutlet weak var taskDateLabel: UILabel!
    @IBOutlet weak var taskTitleLabel: UILabel!
    
    var systemAction: SystemActionContent? = nil
    var task: Task?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let colors = Colors()
        self.backgroundColor = colors.cloudColor
        self.contentView.backgroundColor = colors.cloudColor
        self.layoutMargins = UIEdgeInsetsZero
        
        self.taskTitleLabel.textColor = colors.mainTextColor
        self.taskInfoButton.tintColor = colors.linkTextColor
        self.taskInfoButton.addTarget(self, action: #selector(self.infoAction), forControlEvents: .TouchUpInside)
        self.taskDateLabel.textColor = colors.secondaryTextColor
        
        self.taskSettingButton.tintColor = colors.mainGreenColor
        self.taskSettingButton.backgroundColor = colors.cloudColor
        let icon = FAKFontAwesome.ellipsisVIconWithSize(18)
        icon.addAttribute(NSForegroundColorAttributeName, value: colors.mainGreenColor)
        self.taskSettingButton.setAttributedTitle(icon.attributedString(), forState: .Normal)
        
        self.taskStatusButton.tintColor = colors.mainGreenColor
        self.taskStatusButton.backgroundColor = colors.cloudColor
        
        self.taskStatusButton.addTarget(self, action: #selector(self.markTast(_:)), forControlEvents: .TouchUpInside)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configCellUse(task: Task) {
        self.task = task
        let colors = Colors()
        
        switch task.priority {
        case kTaskPriorityLow:
            self.priorityView.backgroundColor = colors.priorityLowColor
            
        case kTaskPriorityNormal:
            self.priorityView.backgroundColor = colors.priorityNormalColor
            
        default:
            self.priorityView.backgroundColor = colors.priorityHighColor
        }
        
        var taskTitle: NSMutableAttributedString
        switch task.taskType {
        case kSystemTaskType:
            systemAction = TaskStringManager().parseTaskText(task.taskToDo)
            taskTitle = NSMutableAttributedString(string: systemAction?.type.ationNameWithType() ?? "")
            self.taskInfoButton.enabled = true
            self.taskInfoButton.setTitle(systemAction?.name, forState: .Normal)
            
        default:
            self.taskInfoButton.enabled = false
            self.taskInfoButton.setTitle(nil, forState: .Normal)
            taskTitle = NSMutableAttributedString(string: task.taskToDo)
        }
        
        switch task.status {
        case kTaskRunning:
            self.taskTitleLabel.attributedText = taskTitle
            
            let squareIcon = FAKFontAwesome.squareOIconWithSize(20)
            squareIcon.addAttribute(NSForegroundColorAttributeName, value: colors.mainGreenColor)
            let squareImage = squareIcon.imageWithSize(CGSize(width: 20, height: 20))
            self.taskStatusButton.setImage(squareImage, forState: .Normal)
            
            if let create = task.createdDate {
                let now = NSDate()
                if create.isEarlierThan(now) {
                    self.taskDateLabel.text = create.timeAgoSinceDate(now)
                } else {
                    self.taskDateLabel.text = create.formattedDateWithFormat(timeDateFormat)
                }
            }
            
        case kTaskFinish:
            taskTitle.addAttributes(
                [
                    NSForegroundColorAttributeName: colors.secondaryTextColor,
                    NSStrikethroughStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue,
                    NSStrikethroughColorAttributeName: colors.secondaryTextColor,
                ], range: NSMakeRange(0, taskTitle.length))
            
            self.taskTitleLabel.attributedText = taskTitle
            
            let squareCheckIcon = FAKFontAwesome.checkSquareOIconWithSize(20)
            squareCheckIcon.addAttribute(NSForegroundColorAttributeName, value: colors.mainGreenColor)
            let squareCheckImage = squareCheckIcon.imageWithSize(CGSize(width: 20, height: 20))
            self.taskStatusButton.setImage(squareCheckImage, forState: .Normal)
            self.taskDateLabel.text =
                task.finishedDate?.formattedDateWithFormat(timeDateFormat)
            
        default:
            self.taskTitleLabel.attributedText = NSAttributedString(string: task.taskToDo, attributes: [
                NSForegroundColorAttributeName: colors.secondaryTextColor,
                NSStrikethroughStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue,
                NSStrikethroughColorAttributeName: colors.secondaryTextColor,
                ])
            let icon = FAKFontAwesome.timesIconWithSize(20)
            icon.addAttribute(NSForegroundColorAttributeName, value: colors.mainGreenColor)
            let image = icon.imageWithSize(CGSize(width: 20, height: 20))
            self.taskStatusButton.setImage(image, forState: .Normal)
        }
    }
    
    func infoAction() {
        guard let action = systemAction else { return }
        let block = action.type.actionBlockWithType()
        block?(actionString: action.info)
    }
    
    func markTast(btn: UIButton) {
        guard let task = self.task else { return }
        if task.status == kTaskFinish {
            RealmManager.shareManager.updateTaskStatus(task, status: kTaskRunning)
        } else {
            RealmManager.shareManager.updateTaskStatus(task, status: kTaskFinish)
        }
    }
}
