//
//  TaskTableViewCell.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/24.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit
import SnapKit
import AudioToolbox

class TaskTableViewCell: BaseTableViewCell {
    
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
    @IBOutlet weak var reminderLabel: UILabel!
    @IBOutlet weak var settingWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var reminderLeftConstraint: NSLayoutConstraint!
    
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
        
        self.taskSettingButton.addTarget(self, action: #selector(self.settingsAction), for: .touchUpInside)
        
        self.reminderLabel.text = Localized("repeatHint")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configCellUse(_ task: Task) {
        self.task = task
        let colors = Colors()
        
        self.taskSettingButton.createIconButton(iconSize: 18, imageSize: 18, icon: "fa-ellipsis-v", color: colors.mainGreenColor, status: .normal)
        
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
                self.taskInfoButton.setTitle(actionContent.name, for: .normal)
            } else {
                self.taskInfoButton.isEnabled = false
                self.taskInfoButton.setTitle(nil, for: .normal)
                taskTitle = task.taskToDo
            }
            
        default:
            self.taskInfoButton.isEnabled = false
            self.taskInfoButton.setTitle(nil, for: .normal)
            taskTitle = task.taskToDo
        }
        
        switch task.status {
        case kTaskRunning:
            self.taskTitleLabel.attributedText = NSAttributedString(string: taskTitle)
            self.taskStatusButton.createIconButton(iconSize: 20, imageSize: 20, icon: "fa-square-o",
                                                   color: colors.mainGreenColor, status: .normal)
            self.settingWidthConstraint.constant = 35
            self.taskSettingButton.isHidden = false
            
            if let create = task.createdDate {
                let now = Date()
                if create.isEarlierThan(now) {
                    self.taskDateLabel.text = create.timeAgo(since: now)
                } else {
                    self.taskDateLabel.text = create.timeDateString()
                }
            }
            
        case kTaskFinish:
            self.taskTitleLabel.attributedText = taskTitle.addStrikethrough()
            self.taskStatusButton.createIconButton(iconSize: 20, imageSize: 20, icon: "fa-check-square-o",
                                                   color: colors.secondaryTextColor, status: .normal)
            
            self.taskDateLabel.text =
                task.finishedDate?.timeDateString()
            self.settingWidthConstraint.constant = 10
            self.taskSettingButton.isHidden = true
            
        default:
            self.taskTitleLabel.attributedText = task.taskToDo.addStrikethrough()
            self.taskStatusButton.createIconButton(iconSize: 20, imageSize: 20, icon: "fa-close",
                                                   color: colors.mainGreenColor, status: .normal)
            self.taskStatusButton.tintColor = colors.mainGreenColor
            
            self.settingWidthConstraint.constant = 10
            self.taskSettingButton.isHidden = true
        }
        
        self.overTimeLabel.isHidden = true
        self.overTimeLabel.text = nil
        self.reminderLeftConstraint.constant = 0
        if let estimateDate = task.estimateDate {
            if estimateDate.isEarlierThan(Date()) {
                self.overTimeLabel.text = Localized("overTime")
                let color = task.status == kTaskRunning ? colors.mainGreenColor : colors.secondaryTextColor
                self.overTimeLabel.textColor = color
                self.overTimeLabel.layer.cornerRadius = self.overTimeLabel.frame.height * 0.5
                self.overTimeLabel.layer.borderColor = color.cgColor
                self.overTimeLabel.layer.borderWidth = 1
                self.overTimeLabel.isHidden = false
                self.reminderLeftConstraint.constant = 4
                self.overTimeLabel.setNeedsLayout()
            }
        }
        
        self.reminderLabel.isHidden = true
        if let _ = task.repeaterUUID {
            let color = task.status == kTaskRunning ? colors.mainGreenColor : colors.secondaryTextColor
            self.reminderLabel.textColor = color
            self.reminderLabel.layer.cornerRadius = self.overTimeLabel.frame.height * 0.5
            self.reminderLabel.layer.borderColor = color.cgColor
            self.reminderLabel.layer.borderWidth = 1
            self.reminderLabel.isHidden = false
            self.reminderLabel.setNeedsLayout()
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
            self.dingSound()
            RealmManager.shareManager.updateTaskStatus(task, status: kTaskFinish)
        }
        
        if #available(iOS 9.0, *) {
            let manager = SpotlightManager()
            if task.status == kTaskFinish {
                manager.removeFromIndex(task: task)
            } else {
                manager.addTaskToIndex(task: task)
            }
            WatchManager.shareManager.tellWatchQueryNewTask()
        }
    }
    
    fileprivate func dingSound() {
        guard let url = Bundle.main.url(forResource: "ding", withExtension: "wav") as CFURL? else { return }
        let d = UnsafeMutablePointer<SystemSoundID>.allocate(capacity: 32)
        AudioServicesCreateSystemSoundID(url, d)
        AudioServicesPlaySystemSound(d.move())
    }
}
