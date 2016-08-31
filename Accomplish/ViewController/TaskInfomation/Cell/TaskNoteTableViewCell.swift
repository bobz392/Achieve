//
//  TaskNoteTableViewCell.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/30.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class TaskNoteTableViewCell: UITableViewCell {

    static let nib = UINib(nibName: "TaskNoteTableViewCell", bundle: nil)
    static let reuseId = "taskNoteTableViewCell"
    static let rowHeight: CGFloat = 80
    
    @IBOutlet weak var iconButton: UIButton!
    @IBOutlet weak var noteLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let colors = Colors()
        self.backgroundColor = colors.cloudColor
        self.contentView.backgroundColor = colors.cloudColor
        self.layoutMargins = UIEdgeInsetsZero
        
        let icon = try! FAKFontAwesome(identifier: SubtaskIconNote, size: 20)
        let image =
            icon.imageWithSize(CGSize(width: 20, height: 20))
        self.iconButton.setImage(image, forState: .Normal)
        
        self.noteLabel.highlightedTextColor = colors.mainTextColor
        self.noteLabel.textColor = colors.placeHolderTextColor
    }

    override func setSelected(selected: Bool, animated: Bool) {
        selectedBackgroundView = UIView(frame: CGRect(origin: frame.origin, size: CGSize(width: frame.width, height: frame.height - 1)))
        selectedBackgroundView?.backgroundColor = Colors().selectedColor
        
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        self.highlighted = false
    }
    
    func configCell(task: Task) {
        let colors = Colors()
        
        if task.taskNote.characters.count > 0 {
            self.noteLabel.highlighted = true
            self.noteLabel.text = task.taskNote
            self.iconButton.tintColor = colors.mainGreenColor
            
        } else {
            self.noteLabel.highlighted = false
            self.noteLabel.text = Localized("taskNote")
            self.iconButton.tintColor = colors.secondaryTextColor
        }
    }
}
