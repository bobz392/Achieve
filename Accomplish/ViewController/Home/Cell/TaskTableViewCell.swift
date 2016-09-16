//
//  TaskTableViewCell.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/24.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit
import SnapKit

class TaskTableViewCell: UITableViewCell {
    
    static let nib = UINib(nibName: "TaskTableViewCell", bundle: nil)
    static let reuseId = "taskTableViewCell"
    static let rowHeight: CGFloat = 65
    
    // 用户添加了系统动作
    @IBOutlet weak var taskInfoButton: UIButton!
    @IBOutlet weak var taskSettingButton: UIButton!
    @IBOutlet weak var taskStatusButton: UIButton!
    @IBOutlet weak var priorityView: UIView!
    @IBOutlet weak var taskDateLabel: UILabel!
    @IBOutlet weak var taskTitleLabel: UILabel!
    @IBOutlet weak var overTimeLabel: UILabel!
    
    var systemActionContent: SystemActionContent? = nil
    var task: Task?
    var settingBlock: TaskSettingBlock? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let colors = Colors()
        self.clearView()
        self.contentView.clearView()
        self.layoutMargins = UIEdgeInsets.zero
        
        self.taskTitleLabel.textColor = colors.mainTextColor
        self.taskInfoButton.tintColor = colors.linkTextColor
        self.taskInfoButton.addTarget(self, action: #selector(self.systemAction), for: .touchUpInside)
        self.taskDateLabel.textColor = colors.secondaryTextColor
        
        self.taskSettingButton.clearView()
        
        self.taskStatusButton.clearView()
        self.taskStatusButton.addTarget(self, action: #selector(self.markTask(_:)), for: .touchUpInside)
        
        self.overTimeLabel.text = Localized("overTime")
        self.taskSettingButton.addTarget(self, action: #selector(self.settingsAction), for: .touchUpInside)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        selectedBackgroundView = UIView(frame: frame)
        selectedBackgroundView?.backgroundColor = Colors().selectedColor
        
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configCellUse(_ task: Task) {
        self.task = task
        let colors = Colors()
        
        self.taskSettingButton.createIconButton(iconSize: 18, imageSize: 18, icon: "fa-ellipsis-v", color: colors.mainGreenColor, status: UIControlState())
        
        switch task.priority {
        case kTaskPriorityLow:
            self.priorityView.backgroundColor = colors.priorityLowColor
            
        case kTaskPriorityNormal:
            self.priorityView.backgroundColor = colors.priorityNormalColor
            
        default:
            self.priorityView.backgroundColor = colors.priorityHighColor
        }
        
        var taskTitle: String
        switch task.taskType {
        case kSystemTaskType:
            if let actionContent = TaskManager().parseTaskToDoText(task.taskToDo) {
                systemActionContent = actionContent
                taskTitle = actionContent.type.ationNameWithType()
                self.taskInfoButton.isEnabled = true
                self.taskInfoButton.setTitle(actionContent.name, for: UIControlState())
            } else {
                self.taskInfoButton.isEnabled = false
                self.taskInfoButton.setTitle(nil, for: UIControlState())
                taskTitle = task.taskToDo
            }
            
        default:
            self.taskInfoButton.isEnabled = false
            self.taskInfoButton.setTitle(nil, for: UIControlState())
            taskTitle = task.taskToDo
        }
        
        switch task.status {
        case kTaskRunning:
            self.taskTitleLabel.attributedText = NSAttributedString(string: taskTitle)
            self.taskStatusButton.createIconButton(iconSize: 20, imageSize: 20, icon: "fa-square-o",
                                                   color: colors.mainGreenColor, status: UIControlState())
            self.taskSettingButton.isHidden = false
            
            if let create = task.createdDate {
                let now = Date()
                if (create as NSDate).isEarlierThan(now) {
                    self.taskDateLabel.text = (create as NSDate).timeAgo(since: now)
                } else {
                    self.taskDateLabel.text = create.timeDateString()
                }
            }
            
        case kTaskFinish:
            self.taskTitleLabel.attributedText = taskTitle.addStrikethrough()
            self.taskStatusButton.createIconButton(iconSize: 20, imageSize: 20, icon: "fa-check-square-o",
                                                   color: colors.secondaryTextColor, status: UIControlState())
            
            self.taskDateLabel.text =
                task.finishedDate?.timeDateString()
            self.taskSettingButton.isHidden = true
            
        default:
            self.taskTitleLabel.attributedText = task.taskToDo.addStrikethrough()
            self.taskStatusButton.createIconButton(iconSize: 20, imageSize: 20, icon: "fa-close",
                                                   color: colors.mainGreenColor, status: UIControlState())
            self.taskStatusButton.tintColor = colors.mainGreenColor
            
            self.taskSettingButton.isHidden = true
        }
        
        self.overTimeLabel.isHidden = true
        if let estimateDate = task.estimateDate {
            if (estimateDate as NSDate).isEarlierThan(Date()) {
                self.overTimeLabel.isHidden = false
                
                self.overTimeLabel.textColor = colors.mainGreenColor
                self.overTimeLabel.layer.cornerRadius = self.overTimeLabel.frame.height * 0.5
                self.overTimeLabel.layer.borderColor = colors.mainGreenColor.cgColor
                self.overTimeLabel.layer.borderWidth = 1
            }
        }
    }
    
    func settingsAction() {
        guard let task = self.task,
            let block = self.settingBlock else { return }
        
        block(task.uuid)
    }
    
    func systemAction() {
        guard let actionContent = systemActionContent else { return }
        let block = actionContent.type.actionBlockWithType()
        block?(actionContent.urlSchemeInfo)
    }
    
    func markTask(_ btn: UIButton) {
        guard let task = self.task else { return }
        if task.status == kTaskFinish {
            RealmManager.shareManager.updateTaskStatus(task, status: kTaskRunning)
        } else {
            RealmManager.shareManager.updateTaskStatus(task, status: kTaskFinish)
        }
    }
}
