//
//  TaskTableViewCell.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/24.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class TaskTableViewCell: MGSwipeTableCell {
    
    static let nib = UINib(nibName: "TaskTableViewCell", bundle: nil)
    static let reuseId = "taskTableViewCell"
    static let rowHeight: CGFloat = 74
    
    // 用户添加了系统动作，则会有这个 button
    @IBOutlet weak var systemTaskButton: UIButton!
    @IBOutlet weak var taskStatusButton: UIButton!
    @IBOutlet weak var priorityView: UIView!
    @IBOutlet weak var taskDateLabel: UILabel!
    @IBOutlet weak var taskTitleLabel: UILabel!
    @IBOutlet weak var cellCardView: UIView!
    
    var systemActionContent: SystemActionContent? = nil
    var task: Task?
    typealias TimeManagementBlock = () -> Void
    var timeManagementBlock: TimeManagementBlock? = nil
    
    fileprivate lazy var soundManager = SoundManager()
    fileprivate lazy var appDefault = AppUserDefault()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.clearView()
        self.contentView.clearView()
        self.cellCardView.backgroundColor = Colors.cellCardColor
        self.cellCardView.layer.cornerRadius = 4
        self.cellCardView.addCardShadow()
        
        self.taskTitleLabel.textColor = Colors.mainTextColor
        self.systemTaskButton.tintColor = Colors.linkButtonTextColor
        self.systemTaskButton.addTarget(self, action: #selector(self.systemAction), for: .touchUpInside)
        self.taskDateLabel.textColor = Colors.secondaryTextColor
        self.taskStatusButton.clearView()
        self.taskStatusButton.addTarget(self, action: #selector(self.markTaskAction(_:)), for: .touchUpInside)
        
        self.rightSwipeSettings.transition = .drag
        self.rightSwipeSettings.topMargin = 4
        self.rightSwipeSettings.bottomMargin = 10
        self.touchOnDismissSwipe = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            self.cellCardView.backgroundColor = Colors.cellCardSelectedColor
        } else {
            UIView.animate(withDuration: kCellAnimationDuration, animations: { [unowned self] in
                self.cellCardView.backgroundColor = Colors.cellCardColor
            })
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if highlighted {
            self.cellCardView.backgroundColor = Colors.cellCardSelectedColor
        } else {
            UIView.animate(withDuration: kCellAnimationDuration, animations: { [unowned self] in
                self.cellCardView.backgroundColor = Colors.cellCardColor
            })
        }
    }
    
    private func configTaskPriority(priority: TaskPriority) {
        switch priority {
        case .low:
            self.priorityView.backgroundColor = Colors.priorityLowColor
            
        case .high:
            self.priorityView.backgroundColor = Colors.priorityHighColor
            
        default:
            self.priorityView.clearView()
        }
    }
    
    private func configTaskStatus(task: Task) {
        
        var taskTitle: String
        switch task.typeOfTask() {
        case .system:
            if let actionContent = TaskManager().parseTaskToDoText(task.taskToDo) {
                self.systemActionContent = actionContent
                taskTitle = actionContent.type.ationNameWithType()
                self.systemTaskButton.isEnabled = true
                self.systemTaskButton.setTitle(actionContent.name, for: .normal)
            } else {
                self.systemTaskButton.isEnabled = false
                self.systemTaskButton.setTitle(nil, for: .normal)
                taskTitle = task.taskToDo
            }
            
        default:
            self.systemTaskButton.isEnabled = false
            self.systemTaskButton.setTitle(nil, for: .normal)
            taskTitle = task.taskToDo
        }
        
        switch task.taskStatus() {
        case .preceed:
            self.taskTitleLabel.attributedText = NSAttributedString(string: taskTitle)
            self.taskStatusButton
                .buttonWithIcon(icon: Icons.uncheck.iconString())
            if let create = task.createdDate {
                let now = Date()
                if create.isEarlierThan(now) {
                    self.taskDateLabel.text = create.timeAgo(since: now)
                } else {
                    self.taskDateLabel.text = create.timeDateString()
                }
            }
            
        case .completed:
            self.taskTitleLabel.attributedText = taskTitle.addStrikethrough()
            self.taskStatusButton
                .buttonWithIcon(icon: Icons.check.iconString(), tintColor: Colors.secondaryTextColor)
            
            self.taskDateLabel.text =
                task.finishedDate?.timeDateString()
        }
    }
    
    fileprivate func configSwipeButtons(task: Task) {
        var rightButtons = [MGSwipeButton]()
        let width: CGFloat = 65
        let deleteImage = Icons.delete.iconImage()
        let deleteButton = MGSwipeButton(title: "",
                                         icon: deleteImage,
                                         backgroundColor: Colors.swipeRedBackgroundColor,
                                         callback: { (cell) -> Bool in
                                            // 删除任务的 block
                                            if #available(iOS 9.0, *) {
                                                SpotlightManager().removeFromIndex(task: task)
                                            }
                                            RealmManager.shared.deleteTask(task)
                                            
                                            return true
        })
        deleteButton.tintColor = Colors.cellCardColor
        deleteButton.buttonWidth = width
        rightButtons.append(deleteButton)
        
        if task.typeOfTask() == .custom {
            let tmImage = Icons.timeManagement.iconImage()
            let tmButton = MGSwipeButton(title: "",
                                         icon: tmImage,
                                         backgroundColor: Colors.swipeBlueBackgroundColor,
                                         callback: { (cell) -> Bool in
                                            // 进入时间管理的 block
                                            self.timeManagementBlock?()
                                            return true
            })
            tmButton.tintColor = Colors.cellCardColor
            tmButton.buttonWidth = width
            rightButtons.append(tmButton)
        }
        
        self.rightButtons = rightButtons
    }
    
    func configCellUse(_ task: Task, enableSwipe: Bool = true) {
        self.task = task
        self.configTaskPriority(priority: task.taskPriority())
        self.configTaskStatus(task: task)
        
        if enableSwipe && task.taskStatus() == .preceed {
            self.configSwipeButtons(task: task)
        } else {
            self.rightButtons.removeAll()
        }
    }
    
    func configCellForSearch(search: String) {
        self.taskStatusButton.isEnabled = false
        guard !search.isRealEmpty else { return }

        if let taskToDo = self.taskTitleLabel.attributedText {
            self.taskTitleLabel.attributedText = taskToDo.searchHintString(search: search)
        } else {
            guard let taskTodo = self.task?.realTaskToDo() else { return }
            self.taskTitleLabel.attributedText =
                NSAttributedString(string: taskTodo).searchHintString(search: search)
        }
    }
    
    // MARK: - actions
    @objc func systemAction() {
        guard let actionContent = self.systemActionContent else { return }
        if actionContent.type == .customScheme {
            guard let url =
                URL(string: actionContent.urlSchemeInfo) else { return }
            UIApplication.shared.openURL(url)
        } else {
            let block = actionContent.type.actionBlockWithType()
            block?(actionContent.urlSchemeInfo)
        }
    }
    
    /**
     标记任务完成或者取消完成
     */
    @objc func markTaskAction(_ btn: UIButton) {
        guard let task = self.task else { return }
        
        if task.taskStatus() == .completed {
            RealmManager.shared.updateTaskStatus(task, newStatus: .preceed)
        } else {
            if !appDefault.readBool(kUserDefaultCloseSoundKey) {
                self.soundManager.systemDing()
            }
            RealmManager.shared.updateTaskStatus(task, newStatus: .completed)
        }
        
        if #available(iOS 9.0, *) {
            let manager = SpotlightManager()
            if task.taskStatus() == .completed {
                manager.removeFromIndex(task: task)
            } else {
                manager.addTaskToIndex(task: task)
            }
            WatchManager.shared.tellWatchQueryNewTask()
        }
    }
}
