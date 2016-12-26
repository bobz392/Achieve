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
    
    @IBOutlet weak var iconButton: UIButton!
    @IBOutlet weak var noteLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = Colors.mainBackgroundColor
        self.contentView.clearView()
        self.iconButton.setImage(Icons.note.iconImage(), for: .normal)
        self.noteLabel.highlightedTextColor = Colors.mainTextColor
        self.noteLabel.textColor = Colors.secondaryTextColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        self.isHighlighted = false
    }
    
    func configCell(_ task: Task) {
        if task.taskNote.characters.count > 0 {
            self.noteLabel.isHighlighted = true
            self.noteLabel.text = task.taskNote
            self.iconButton.tintColor = Colors.mainTextColor
        } else {
            self.noteLabel.isHighlighted = false
            self.noteLabel.text = Localized("taskNote")
            self.iconButton.tintColor = Colors.secondaryTextColor
        }
    }
}
