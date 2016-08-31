//
//  SubtaskTableViewCell.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/30.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class SubtaskTableViewCell: UITableViewCell {

    static let nib = UINib(nibName: "SubtaskTableViewCell", bundle: nil)
    static let reuseId = "subtaskTableViewCell"
    static let rowHeight: CGFloat = 40
    
    @IBOutlet weak var subtaskTextField: UITextField!
    @IBOutlet weak var trashButton: UIButton!
    @IBOutlet weak var iconButton: UIButton!
    
    var task: Task?
    var subtask: Subtask?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let colors = Colors()
        self.backgroundColor = colors.cloudColor
        self.contentView.backgroundColor = colors.cloudColor
        self.layoutMargins = UIEdgeInsetsZero
        
        self.trashButton.tintColor = colors.mainGreenColor
        let icon = try! FAKFontAwesome(identifier: "fa-trash-o", size: kTaskDetailCellIconSize)
        icon.addAttribute(NSForegroundColorAttributeName, value: colors.mainGreenColor)
        let iconImage = icon.imageWithSize(CGSize(width: kTaskClearCellIconSize, height: kTaskClearCellIconSize))
        self.trashButton.setImage(iconImage, forState: .Normal)
        
        self.subtaskTextField.tintColor = colors.mainGreenColor
        self.subtaskTextField.textColor = colors.mainGreenColor
        
        self.separatorInset = UIEdgeInsets(top: 0, left: screenBounds.width, bottom: 0, right: 0)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        selectedBackgroundView = UIView(frame: CGRect(origin: frame.origin, size: CGSize(width: frame.width, height: frame.height - 1)))
        selectedBackgroundView?.backgroundColor = Colors().selectedColor
        
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configCell(task: Task, subtask: Subtask?, iconString: String) {
        self.task = task
        self.subtask = subtask
        let colors = Colors()
        let icon = try! FAKFontAwesome(identifier: iconString, size: kTaskDetailCellIconSize)
        let image =
            icon.imageWithSize(CGSize(width: kTaskDetailCellIconSize, height: kTaskDetailCellIconSize))
        self.iconButton.setImage(image, forState: .Normal)
        self.subtaskTextField.attributedText = nil
        
        if let subtask = subtask {
            if let _ = subtask.finishedDate {
                self.subtaskTextField.attributedText = subtask.taskToDo.addStrikethrough()
                self.iconButton.tintColor = colors.secondaryTextColor
            } else {
                self.subtaskTextField.attributedText = NSAttributedString(string: subtask.taskToDo)
                self.iconButton.tintColor = colors.mainGreenColor
            }
            
            self.trashButton.hidden = false
            self.separatorInset = UIEdgeInsets(top: 0, left: 1000, bottom: 0, right: 0)
        } else {
            let attrPlacehold = NSAttributedString(string: Localized("detailAddSubtask"), attributes: [NSForegroundColorAttributeName: colors.placeHolderTextColor])
            self.subtaskTextField.attributedPlaceholder = attrPlacehold
            self.trashButton.hidden = true
            self.iconButton.tintColor = colors.secondaryTextColor
            self.separatorInset = UIEdgeInsets(top: 0, left: 55, bottom: 0, right: 0)
        }
        
        self.trashButton.addTarget(self, action: #selector(self.deleteSubtask), forControlEvents: .TouchUpInside)
        self.iconButton.addTarget(self, action: #selector(self.subtaskChecked), forControlEvents: .TouchUpInside)
    }
    
    func deleteSubtask() {
        guard let subtask = self.subtask else { return }
        RealmManager.shareManager.deleteObject(subtask)
    }
    
    func subtaskChecked() {
        guard let subtask = self.subtask else { return }
        
        RealmManager.shareManager.updateObject { 
            if subtask.finishedDate == nil {
                subtask.finishedDate = NSDate()
            } else {
                subtask.finishedDate = nil
            }
        }
    }
}

extension SubtaskTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if let task = self.task,
            let text = textField.text {
            if text.characters.count > 0 {
                if let subtask = self.subtask {
                    RealmManager.shareManager.updateObject({ 
                        subtask.taskToDo = text
                    })
                } else {
                    createSubtask(text, task: task)
                    textField.text = ""
                }
            }
        }
        return textField.resignFirstResponder()
    }
    
    private func createSubtask(title: String, task: Task) {
        let subtask = Subtask()
        let now = NSDate()
        subtask.createdDate = now
        subtask.taskToDo = title
        subtask.rootUUID = task.uuid
        subtask.uuid = now.createTaskUUID()
        RealmManager.shareManager.writeObject(subtask)
    }
}
