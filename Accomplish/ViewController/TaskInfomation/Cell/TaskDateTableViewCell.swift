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

class TaskDateTableViewCell: UITableViewCell {
    
    static let nib = UINib(nibName: "TaskDateTableViewCell", bundle: nil)
    static let reuseId = "taskDateTableViewCell"
    static let rowHeight: CGFloat = 50
  
    @IBOutlet weak var iconButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var clearButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let colors = Colors()
        self.backgroundColor = colors.cloudColor
        self.contentView.backgroundColor = colors.cloudColor
        self.layoutMargins = UIEdgeInsetsZero
        
        self.clearButton.tintColor = colors.mainGreenColor
        let icon = try! FAKFontAwesome(identifier: "fa-times", size: kTaskDetailCellIconSize)
        icon.addAttribute(NSForegroundColorAttributeName, value: colors.mainGreenColor)
        let iconImage = icon.imageWithSize(CGSize(width: kTaskClearCellIconSize, height: kTaskClearCellIconSize))
        self.clearButton.setImage(iconImage, forState: .Normal)
        
        self.infoLabel.highlightedTextColor = colors.mainTextColor
        self.infoLabel.textColor = colors.secondaryTextColor
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        selectedBackgroundView = UIView(frame: frame)
        selectedBackgroundView?.backgroundColor = Colors().selectedColor
        
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configCell(task: Task, iconString: String) {
        let colors = Colors()
        
        let icon = try! FAKFontAwesome(identifier: iconString, size: kTaskDetailCellIconSize)
        let image =
            icon.imageWithSize(CGSize(width: kTaskDetailCellIconSize, height: kTaskDetailCellIconSize))
        self.iconButton.setImage(image, forState: .Normal)
        self.clearButton.hidden = false
        
        switch iconString {
        case SubtaskIconCalendar:
            self.infoLabel.highlighted = true
            self.infoLabel.text =
                Localized(task.canPostpone ? "detailPostponeTomorrow" : "detailIncomplete")
            self.clearButton.hidden = true
            self.iconButton.tintColor = colors.mainGreenColor
            
        case SubtaskIconBell:
            self.infoLabel.highlighted = task.notifyDate != nil
            self.infoLabel.text =
                task.notifyDate == nil ? Localized("detailNotifyTime") : task.notifyDate!.formattedDateWithFormat(timeDateFormat)
            self.clearButton.hidden = true
            self.iconButton.tintColor = colors.secondaryTextColor
            
        case SubtaskIconRepeat:
            self.infoLabel.highlighted = false
            self.clearButton.hidden = true
            self.infoLabel.text = Localized("repeat")
            self.iconButton.tintColor = colors.secondaryTextColor
            
        default:
            break
        }
    }
}
