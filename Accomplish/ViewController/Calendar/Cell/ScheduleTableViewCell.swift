
//
//  ScheduleTableViewCell.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/8.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class ScheduleTableViewCell: UITableViewCell {
    
    static let nib = UINib(nibName: "ScheduleTableViewCell", bundle: nil)
    static let reuseId = "scheduleTableViewCell"
    static let rowHeight: CGFloat = 57
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var createdTimeLabel: UILabel!
    @IBOutlet weak var amLabel: UILabel!
    @IBOutlet weak var tasksLabel: UILabel!
    @IBOutlet weak var taskCardView: UIView!
    @IBOutlet weak var completedLabel: UILabel!
    
    @IBOutlet weak var lineViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var lineViewBottomConstraint: NSLayoutConstraint!
    
    weak var task: Task? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.lineView.backgroundColor = Colors.cloudColor
        
        self.statusLabel.layer.cornerRadius = 10
        self.statusLabel.backgroundColor = Colors.cloudColor
        self.createdTimeLabel.textColor = Colors.cloudColor
        self.amLabel.textColor = Colors.cloudColor
        
        self.tasksLabel.textColor = Colors.mainTextColor
        self.tasksLabel.highlightedTextColor = Colors.cloudColor
        self.completedLabel.textColor = Colors.secondaryTextColor
        self.completedLabel.highlightedTextColor = Colors.cloudColor
        
        self.tasksLabel.preferredMaxLayoutWidth = screenBounds.width - 101
        
        self.taskCardView.backgroundColor = Colors.cloudColor
        self.taskCardView.layer.cornerRadius = 4
        self.taskCardView.addShadow()
    }
    
    func setTop(_ isTop: Bool) {
        self.lineViewTopConstraint.constant = isTop ? 10: 0
    }
    
    func setBottom(_ isBottom: Bool) {
        self.lineViewBottomConstraint.constant = isBottom ? self.contentView.frame.height - 10 : 0
    }
    
    func config(_ task: Task) {
        let colors = Colors()
        
        let identifier = task.taskStatus() == .completed ?
            "fa-check" : (task.createdDate!.isLaterThenToday() ? "fa-exclamation" : "fa-times")
        let checkIcon = try! FAKFontAwesome(identifier: identifier, size: 12)
        checkIcon.addAttribute(NSForegroundColorAttributeName, value: colors.mainGreenColor)
        self.statusLabel.attributedText = checkIcon.attributedString()
        
        self.createdTimeLabel.text = task.createdDate?.timeString()
        self.amLabel.text = task.createdDate?.am()
        self.tasksLabel.text = task.getNormalDisplayTitle()
        if let finishDate = task.finishedDate {
            self.completedLabel.text = Localized("completedAt") + finishDate.timeDateString()
        } else {
    
            if task.createdDate!.isLaterThenToday() {
                self.completedLabel.text = Localized("notComoletedYet")
            } else {
                self.completedLabel.text = Localized("notCompleted")
            }
        }
        
        self.task = task
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        selectedBackgroundView = UIView(frame: frame)
//        selectedBackgroundView?.backgroundColor = Colors.selectedColor
        
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
