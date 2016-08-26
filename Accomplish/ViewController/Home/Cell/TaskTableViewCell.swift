//
//  TaskTableViewCell.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/24.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {
    
    static let nib = UINib(nibName: "TaskTableViewCell", bundle: nil)
    static let reuseId = "taskTableViewCell"
    static let rowHeight: CGFloat = 65
    
    @IBOutlet weak var ellipsisButton: UIButton!
    @IBOutlet weak var taskStatusButton: UIButton!
    @IBOutlet weak var priorityView: UIView!
    @IBOutlet weak var taskTitleLabel: UILabel!
    @IBOutlet weak var taskDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let colors = Colors()
        self.contentView.backgroundColor = colors.cloudColor
        self.taskTitleLabel.textColor = colors.mainTextColor
        self.taskDateLabel.textColor = colors.secondaryTextColor
        
        self.ellipsisButton.tintColor = colors.mainGreenColor
        self.ellipsisButton.backgroundColor = colors.cloudColor
        let icon = FAKFontAwesome.ellipsisVIconWithSize(18)
        icon.addAttribute(NSForegroundColorAttributeName, value: colors.mainGreenColor)
        let image = icon.imageWithSize(CGSize(width: 20, height: 25))
        self.ellipsisButton.setImage(image, forState: .Normal)
        
        self.taskStatusButton.tintColor = colors.mainGreenColor
        self.taskStatusButton.backgroundColor = colors.cloudColor
        
        self.layoutMargins = UIEdgeInsetsZero
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configCellUse(task: Task) {
        let colors = Colors()
        
        switch task.priority {
            
        case kTaskPriorityLow:
            self.priorityView.backgroundColor = colors.priorityLowColor
            
        case kTaskPriorityNormal:
            self.priorityView.backgroundColor = colors.priorityNormalColor
            
        default:
            self.priorityView.backgroundColor = colors.priorityHighColor
        }
        
        switch task.status {
            
        case kTaskRunning:
            self.taskTitleLabel.attributedText = NSAttributedString(string: task.taskToDo)
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
            self.taskTitleLabel.attributedText = NSAttributedString(string: task.taskToDo, attributes: [
                NSForegroundColorAttributeName: colors.secondaryTextColor,
                NSStrikethroughStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue,
                NSStrikethroughColorAttributeName: colors.secondaryTextColor,
                ])
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
    
}
