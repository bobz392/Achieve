//
//  TaskNoteTableViewCell.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/30.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class TaskNoteTableViewCell: BaseTableViewCell {

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
        self.layoutMargins = UIEdgeInsets.zero
        
        self.iconButton.createIconButton(iconSize: kNoteCellIconSize, imageSize: kNoteCellIconSize,
                                           icon: TaskIconNote, color: colors.mainGreenColor, status: .normal)
        
        self.noteLabel.highlightedTextColor = colors.mainTextColor
        self.noteLabel.textColor = colors.secondaryTextColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        self.isHighlighted = false
    }
    
    func configCell(_ task: Task) {
        let colors = Colors()
        
        if task.taskNote.characters.count > 0 {
            self.noteLabel.isHighlighted = true
            self.noteLabel.text = task.taskNote
            self.iconButton.tintColor = colors.mainGreenColor
            
        } else {
            self.noteLabel.isHighlighted = false
            self.noteLabel.text = Localized("taskNote")
            self.iconButton.tintColor = colors.secondaryTextColor
        }
    }
}
