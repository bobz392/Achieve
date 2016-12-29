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
    static let rowHeight: CGFloat = 70
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var noteLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = Colors.mainBackgroundColor
        self.contentView.clearView()
        self.iconImageView.image = Icons.note.iconImage()
        self.noteLabel.highlightedTextColor = Colors.mainTextColor
        self.noteLabel.textColor = Colors.secondaryTextColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            self.iconImageView.tintColor = Colors.cellLabelSelectedTextColor
        } else {
            self.iconImageView.tintColor = Colors.mainIconColor
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setSelected(highlighted, animated: animated)
        
        if highlighted {
            self.iconImageView.tintColor = Colors.cellLabelSelectedTextColor
        } else {
            self.iconImageView.tintColor = Colors.mainIconColor
        }
    }
    
    func configCell(_ task: Task) {
        if task.taskNote.characters.count > 0 {
            self.noteLabel.isHighlighted = true
            self.noteLabel.text = task.taskNote
        } else {
            self.noteLabel.isHighlighted = false
            self.noteLabel.text = Localized("taskNote")
        }
    }
}
