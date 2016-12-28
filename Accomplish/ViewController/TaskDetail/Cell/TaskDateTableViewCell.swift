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
let kSystemTaskButtonIconSize: CGFloat = 20

class TaskDateTableViewCell: BaseTableViewCell {
    
    static let nib = UINib(nibName: "TaskDateTableViewCell", bundle: nil)
    static let reuseId = "taskDateTableViewCell"
    static let rowHeight: CGFloat = 50
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var clearButton: UIButton!
    
    var task: Task?
    var detailType: TaskDetailType = .other
    fileprivate var cuurentImageTintColor = Colors.mainIconColor
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.backgroundColor = Colors.mainBackgroundColor
        self.contentView.clearView()
        
        self.clearButton.addTarget(self, action: #selector(self.clearAction(_:)), for: .touchUpInside)
        self.clearButton.setImage(Icons.clear.iconImage(), for: .normal)
        self.clearButton.tintColor = Colors.mainIconColor
        
        self.infoLabel.highlightedTextColor = Colors.cellLabelSelectedTextColor
        self.infoLabel.textColor = Colors.mainIconColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            self.iconImageView.tintColor = Colors.cellLabelSelectedTextColor
        } else {
            self.iconImageView.tintColor = self.cuurentImageTintColor
        }
        
        self.clearButton.tintColor =
            !selected ? Colors.mainIconColor : Colors.deleteButtonBackgroundColor
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if highlighted {
            self.iconImageView.tintColor = Colors.cellLabelSelectedTextColor
        } else {
            self.iconImageView.tintColor = self.cuurentImageTintColor
        }
        
        self.clearButton.tintColor =
            !highlighted ? Colors.mainIconColor : Colors.deleteButtonBackgroundColor
    }
    
    func clearAction(_ btn: UIButton) {
        guard let task = self.task else { return }
        
        switch self.detailType {
        case TaskDetailType.repeat:
            LocalNotificationManager.shared.removeRepeater(task)
            RealmManager.shared.updateObject {
                task.repeaterUUID = nil
            }
            
        case TaskDetailType.notify:
            RealmManager.shared.updateObject {
                task.notifyDate = nil
            }
            LocalNotificationManager.shared.cancel(task)
            
        case TaskDetailType.estimate:
            RealmManager.shared.updateObject({
                task.estimateDate = nil
            })
            
        case TaskDetailType.tag:
            RealmManager.shared.updateObject({
                task.tagUUID = nil
            })
            
        default:
            break
        }
    }
    
    fileprivate func setCellContentHighlight(highlighted: Bool) {
        self.iconImageView.tintColor =
            highlighted ? Colors.cellLabelSelectedTextColor : Colors.mainIconColor
        self.infoLabel.isHighlighted = highlighted
    }

    func configCell(_ task: Task, icon: Icons) {
        self.task = task
        self.iconImageView.image = icon.iconImage()
        self.clearButton.isHidden = false
        self.detailType = .other
        
        switch icon {
            
        case .schedule:
            guard let createdDate = task.createdDate else { break }
            let scheduled = createdDate.isEarlierThan(Date()) ?
                Localized("scheduled") : Localized("willScheduled")
            self.infoLabel.text = scheduled + " "
                + createdDate.formattedDate(withFormat: TimeDateFormat)
            self.clearButton.isHidden = true
            self.setCellContentHighlight(highlighted: true)
            
        case .notify:
            if let notifyDate = task.notifyDate {
                self.infoLabel.text = Localized("reminderMe")
                    + notifyDate.timeDateString()
            } else {
                self.infoLabel.text = Localized("noReminder")
            }
            
            self.clearButton.isHidden = task.notifyDate == nil
            self.detailType = .notify
            self.setCellContentHighlight(highlighted: task.notifyDate != nil)
            
        case .due:
            if task.taskStatus() == .completed {
                self.clearButton.isHidden = true
                self.detailType = .other
                self.setCellContentHighlight(highlighted: true)
                
                if let finishDate = task.finishedDate {
                    self.infoLabel.text = Localized("finishAt") + finishDate.formattedDate(withFormat: TimeDateFormat)
                }
            } else {
                self.clearButton.isHidden = task.estimateDate == nil
                self.detailType = .estimate
                self.setCellContentHighlight(highlighted: task.estimateDate != nil)
                
                if let estimateDate = task.estimateDate {
                    self.infoLabel.text = Localized("estimeateAt") + estimateDate.formattedDate(withFormat: TimeDateFormat)
                } else {
                    self.infoLabel.text = Localized("noEstimate")
                }
            }
            
        case .loop:
            let hasRepeater: Bool
            if let repeater = RealmManager.shared.queryRepeaterWithTask(task.uuid) {
                hasRepeater = true
                if let type = RepeaterTimeType(rawValue: repeater.repeatType),
                    let createDate = task.createdDate {
                    self.infoLabel.text = Localized("repeat")
                        + type.repeaterTitle(createDate: createDate)
                } else {
                    self.infoLabel.text = Localized("repeat")
                }
            } else {
                hasRepeater = false
                self.infoLabel.text = Localized("noRepeat")
            }
            
            self.clearButton.isHidden = !hasRepeater
            self.detailType = .repeat
            self.setCellContentHighlight(highlighted: hasRepeater)
            
        case .tag:
            let hasTag: Bool
            // MARK: -- to do
            if let tagUUID = task.tagUUID {
                // 检查 tag 是否还在，如果不在则删除 task 的 tag
                if let tag = RealmManager.shared.queryTag(usingName: false, query: tagUUID) {
                    hasTag = true
                    self.infoLabel.text = tag.name
                } else {
                    hasTag = false
                    self.infoLabel.text = Localized("noTag")
                    RealmManager.shared.updateObject({
                        self.task?.tagUUID = nil
                    })
                }
            } else {
                hasTag = false
                self.infoLabel.text = Localized("noTag")
            }
            
            self.clearButton.isHidden = !hasTag
            self.detailType = .tag
            self.setCellContentHighlight(highlighted: hasTag)
            
        default:
            break
        }
        
        self.cuurentImageTintColor = self.iconImageView.tintColor
    }
    
    enum TaskDetailType: Int {
        case notify = 100
        case `repeat` = 101
        case estimate = 102
        case tag = 103
        case other = 0
    }
}
