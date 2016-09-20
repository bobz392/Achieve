
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
    static let rowHeight: CGFloat = 60
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var createdTimeLabel: UILabel!
    @IBOutlet weak var amLabel: UILabel!
    @IBOutlet weak var tasksLabel: UILabel!
    @IBOutlet weak var completedLabel: UILabel!
    
    @IBOutlet weak var lineViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var lineViewBottomConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let colors = Colors()
        self.lineView.backgroundColor = colors.cloudColor
        
        self.statusLabel.layer.cornerRadius = 10
        self.statusLabel.backgroundColor = colors.cloudColor
        self.tasksLabel.textColor = colors.cloudColor
        self.createdTimeLabel.textColor = colors.cloudColor
        self.amLabel.textColor = colors.cloudColor
        self.completedLabel.textColor = colors.cloudColor
        
        self.tasksLabel.preferredMaxLayoutWidth = screenBounds.width - 101
    }
    
    func setTop(_ isTop: Bool) {
        self.lineViewTopConstraint.constant = isTop ? 10: 0
    }
    
    func setBottom(_ isBottom: Bool) {
        self.lineViewBottomConstraint.constant = isBottom ? self.contentView.frame.height - 10 : 0
    }
    
    func config(_ task: Task) {
        let colors = Colors()
        let identifier = task.status == kTaskFinish ?
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
        
    }
}
