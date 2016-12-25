//
//  SubtaskTableViewCell.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/30.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class SubtaskTableViewCell: BaseTableViewCell {
    
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

        self.backgroundColor = Colors.mainBackgroundColor
        self.contentView.clearView()
        
        self.trashButton.setImage(Icons.smallDelete.iconImage(), for: .normal)
        self.trashButton.tintColor = Colors.mainIconColor
        
        self.subtaskTextField.tintColor = Colors.mainTextColor
        self.subtaskTextField.textColor = Colors.mainTextColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configCell(_ task: Task, subtask: Subtask?, icon: Icons) {
        self.task = task
        self.subtask = subtask
        self.iconButton.setImage(icon.iconImage(), for: .normal)
        self.iconButton.tintColor = Colors.mainIconColor
        
        self.subtaskTextField.attributedText = nil
        
        if let subtask = subtask {
            if let _ = subtask.finishedDate {
                self.subtaskTextField.attributedText =
                    subtask.taskToDo.addStrikethrough(fontSize: 15)
                self.iconButton.tintColor = Colors.secondaryTextColor
            } else {
                self.subtaskTextField.text = subtask.taskToDo
                self.iconButton.tintColor = Colors.mainTextColor
            }
            
            self.trashButton.isHidden = false
        } else {
            let attrPlacehold =
                NSAttributedString(string: Localized("detailAddSubtask"), attributes: [
                    NSForegroundColorAttributeName: Colors.secondaryTextColor,
                    NSFontAttributeName: UIFont.systemFont(ofSize: 15)
                    ]
            )
            
            self.subtaskTextField.attributedPlaceholder = attrPlacehold
            self.trashButton.isHidden = true
            self.iconButton.tintColor = Colors.secondaryTextColor
        }
        
        self.trashButton.addTarget(self, action: #selector(self.deleteSubtask), for: .touchUpInside)
        self.iconButton.addTarget(self, action: #selector(self.subtaskChecked), for: .touchUpInside)
    }
    
    func deleteSubtask() {
        guard let subtask = self.subtask else { return }
        RealmManager.shared.deleteObject(subtask)
    }
    
    func subtaskChecked() {
        guard let subtask = self.subtask else { return }
        
        RealmManager.shared.updateObject {
            if subtask.finishedDate == nil {
                subtask.finishedDate = NSDate()
            } else {
                subtask.finishedDate = nil
            }
        }
    }
}

extension SubtaskTableViewCell: UITextFieldDelegate {
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.text = nil
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let task = self.task,
            let text = textField.text {
            if text.characters.count > 0 {
                if let subtask = self.subtask {
                    RealmManager.shared.updateObject({
                        subtask.taskToDo = text
                    })
                } else {
                    createSubtask(text, task: task)
                }
            }
        }
        return textField.resignFirstResponder()
    }
    
    fileprivate func createSubtask(_ title: String, task: Task) {
        let subtask = Subtask()
        let now = NSDate()
        subtask.createdDate = now
        subtask.taskToDo = title
        subtask.rootUUID = task.uuid
        subtask.uuid = now.createTaskUUID()
        RealmManager.shared.writeObject(subtask)
    }
}
