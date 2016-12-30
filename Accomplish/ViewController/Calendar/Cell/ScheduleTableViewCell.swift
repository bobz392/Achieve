
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
    static let rowHeight: CGFloat = 75
    
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var createdTimeLabel: UILabel!
    @IBOutlet weak var tasksLabel: UILabel!
    @IBOutlet weak var taskCardView: UIView!
    @IBOutlet weak var completedLabel: UILabel!
    
    @IBOutlet weak var lineViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var lineViewBottomConstraint: NSLayoutConstraint!
    
    weak var task: Task? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.statusView.layer.cornerRadius = 10
        self.statusView.backgroundColor = Colors.mainIconColor
        self.statusImageView.tintColor = Colors.cellCardColor
        
        self.tasksLabel.textColor = Colors.mainTextColor
        self.tasksLabel.preferredMaxLayoutWidth = screenBounds.width - 160
        
        self.completedLabel.textColor = Colors.secondaryTextColor
        self.createdTimeLabel.textColor = Colors.mainTextColor
        
        self.taskCardView.backgroundColor = Colors.cellCardColor
        self.taskCardView.layer.cornerRadius = 4
        self.taskCardView.addCardShadow()
        
        self.lineView.backgroundColor = Colors.mainIconColor
    }
    
    func setTop(_ isTop: Bool) {
        self.lineViewTopConstraint.constant = isTop ? -60: 0
    }
    
    func setBottom(_ isBottom: Bool) {
        self.lineViewBottomConstraint.constant = isBottom ? self.contentView.frame.height - 26 : 0
    }
    
    func config(_ task: Task) {
        let icon = task.taskStatus() == .completed ?
            Icons.finish : (task.createdDate!.isLaterThenToday() ? Icons.unfinish : Icons.clear)
        self.statusImageView.image = icon.iconImage()
        
        self.createdTimeLabel.text = task.createdDate?.timeString()
        self.tasksLabel.text = task.realTaskToDo()
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
        super.setSelected(selected, animated: animated)
        
        if selected {
            self.taskCardView.backgroundColor = Colors.cellCardSelectedColor
        } else {
            UIView.animate(withDuration: kCellAnimationDuration, animations: { [unowned self] in
                self.taskCardView.backgroundColor = Colors.cellCardColor
            })
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if highlighted {
            self.taskCardView.backgroundColor = Colors.cellCardSelectedColor
        } else {
            UIView.animate(withDuration: kCellAnimationDuration, animations: { [unowned self] in
                self.taskCardView.backgroundColor = Colors.cellCardColor
            })
        }
    }
}
