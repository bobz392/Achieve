//
//  TaskDetailViewController.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/29.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit
import RealmSwift

let SubtaskIconCalendar = "fa-calendar-plus-o"
let SubtaskIconBell = "fa-bell-o"
let SubtaskIconRepeat = "fa-repeat"
let SubtaskIconAdd = "fa-plus"
let SubtaskIconNote = "fa-pencil-square-o"
let SubtaskIconSquare = "fa-square-o"
let SubtaskIconChecked = "fa-check-square-o"

class TaskDetailViewController: BaseViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var datePickerHolderView: UIView!
    @IBOutlet weak var detailTableView: UITableView!
    @IBOutlet weak var detailTableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var datePickerViewBottomConstraint: NSLayoutConstraint!
    
    private var taskPickerView: TaskPickerView?
    private var iconList = [SubtaskIconCalendar, SubtaskIconBell, SubtaskIconRepeat, SubtaskIconAdd, SubtaskIconNote]
    private let subtaskStartIndex = 3
    
    var task: Task
    // only running task can change
    var change: Bool = true
    private var subtasks: Results<Subtask>?
    private var subtasksToken: RealmSwift.NotificationToken?
    private var taskToken: RealmSwift.NotificationToken?
    
    init(task: Task, change: Bool) {
        self.task = task
        self.change = change
        super.init(nibName: "TaskDetailViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.task = Task()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        

        configMainUI()
        initializeControl()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        subtasksToken?.stop()
        KeyboardManager.sharedManager.closeNotification()
    }
    
    override func configMainUI() {
        let colors = Colors()
        
        self.titleTextField.textColor = colors.cloudColor
        self.titleTextField.tintColor = colors.cloudColor
        
        self.detailTableView.backgroundColor = colors.cloudColor
        self.detailTableView.separatorColor = colors.separatorColor
        
        self.cardView.backgroundColor = colors.cloudColor
        self.view.backgroundColor = colors.mainGreenColor
        
        self.cancelButton.buttonColor(colors)
        let cancelIcon = FAKFontAwesome.arrowLeftIconWithSize(kBackButtonCorner)
        cancelIcon.addAttribute(NSForegroundColorAttributeName, value: colors.mainGreenColor)
        self.cancelButton.setAttributedTitle(cancelIcon.attributedString(), forState: .Normal)
    }
    
    private func initializeControl() {
        self.initializeTableView()
        self.keyboardAction()
        
        self.cancelButton.addShadow()
        self.cancelButton.layer.cornerRadius = kBackButtonCorner
        self.cancelButton.addTarget(self, action: #selector(self.cancelAction), forControlEvents: .TouchUpInside)
        
        self.cardView.addShadow()
        self.cardView.layer.cornerRadius = kCardViewCornerRadius
        
        self.titleTextField.text = task.getNormalDisplayTitle()
        
        guard let taskPickerView = NSBundle.mainBundle().loadNibNamed("TaskPickerView", owner: self, options: nil).last as? TaskPickerView else { return }
        self.datePickerHolderView.addSubview(taskPickerView)
        taskPickerView.snp_makeConstraints { (make) in
            make.top.equalTo(0)
            make.bottom.equalTo(0)
            make.left.equalTo(0)
            make.right.equalTo(0)
        }
        
        self.taskPickerView = taskPickerView
        taskPickerView.task = self.task
        
        taskPickerView.leftButton.addTarget(self, action: #selector(self.cancelDatePickerAction), forControlEvents: .TouchUpInside)
        taskPickerView.rightButton.addTarget(self, action: #selector(self.setDatePickerAction), forControlEvents: .TouchUpInside)
        
        self.configDetailWithTask()
    }
    
    private func configDetailWithTask() {
        if self.task.taskType == kSystemTaskType {
            self.titleTextField.enabled = self.task.taskToDoCanChange() && change
        }
    }
    
    // MARK: - actions
    func clearAction(btn: UIButton) {
        let index = NSIndexPath(forRow: btn.tag, inSection: 0)
        detailTableView.reloadRowsAtIndexPaths([index], withRowAnimation: .Automatic)
    }
    
    func cancelAction() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    private func keyboardAction() {
        KeyboardManager.sharedManager.keyboardShowHandler = { [unowned self] in
            self.detailTableViewBottomConstraint.constant =
                KeyboardManager.keyboardHeight - 62
            
            UIView.animateWithDuration(KeyboardManager.duration, animations: { 
                self.detailTableView.layoutIfNeeded()
                }, completion: { [unowned self] (finsh) in
                    let index = NSIndexPath(forRow: self.iconList.count - 2, inSection: 0)
                    self.detailTableView.scrollToRowAtIndexPath(index, atScrollPosition: .Bottom, animated: true)
            })
            
            if self.taskPickerView?.viewIsShow() == true {
                self.cancelDatePickerAction()
            }
        }
        
        KeyboardManager.sharedManager.keyboardHideHandler = { [unowned self] in
            self.detailTableViewBottomConstraint.constant = 10
            UIView.animateWithDuration(KeyboardManager.duration, animations: {
                self.detailTableView.layoutIfNeeded()
            })
        }
    }
    
    private func realmNoticationToken() {
        self.subtasksToken = subtasks?.addNotificationBlock({ [unowned self] (changes: RealmCollectionChange) in
            switch changes {
            case .Initial:
                self.detailTableView.reloadRowsAtIndexPaths(Array(self.subtaskStartIndex..<self.iconList.count - 1).map { NSIndexPath(forRow: $0, inSection: 0) }, withRowAnimation: .Automatic)
                
            case .Update(_, let deletions, let insertions, let modifications):
                self.detailTableView.beginUpdates()
                if insertions.count > 0 {
                    for index in insertions {
                        self.iconList.insert(SubtaskIconSquare, atIndex: index + self.subtaskStartIndex)
                    }
                    
                    self.detailTableView.insertRowsAtIndexPaths(insertions.map { NSIndexPath(forRow: $0 + self.subtaskStartIndex, inSection: 0) }, withRowAnimation: .Automatic)
                }
                
                if modifications.count > 0 {
                    for index in modifications {
                        guard let subtask = self.subtasks?[index] else { continue }
                        self.iconList.removeAtIndex(index + self.subtaskStartIndex)
                        let element = subtask.finishedDate == nil ? SubtaskIconSquare : SubtaskIconChecked
                        self.iconList.insert(element, atIndex: index + self.subtaskStartIndex)
                    }
                    
                    self.detailTableView.reloadRowsAtIndexPaths(modifications.map { NSIndexPath(forRow: $0 + self.subtaskStartIndex, inSection: 0) }, withRowAnimation: .Automatic)
                }
                
                if deletions.count > 0 {
                    for index in deletions {
                        self.iconList.removeAtIndex(index + self.subtaskStartIndex)
                    }
                    self.detailTableView.deleteRowsAtIndexPaths(deletions.map { NSIndexPath(forRow: $0 + self.subtaskStartIndex, inSection: 0) },
                        withRowAnimation: .Automatic)
                }
                
                self.detailTableView.endUpdates()
                
            case .Error(let error):
                print(error)
                break
            }
            })
    }
}

// MARK: - UITextFieldDelegate
extension TaskDetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if let title = textField.text {
            if !title.isEmpty {
                RealmManager.shareManager.updateObject({
                    self.task.taskToDo = title
                })
            }
        }
        
        return textField.resignFirstResponder()
    }
}

// MARK: - table view
extension TaskDetailViewController: UITableViewDelegate, UITableViewDataSource {
    private func initializeTableView() {
        let sts = RealmManager.shareManager.querySubtask(task.uuid)
        self.subtasks = sts
        for index in 0..<sts.count {
            if sts[index].finishedDate == nil {
                iconList.insert(SubtaskIconSquare, atIndex: self.subtaskStartIndex + index)
            } else {
                iconList.insert(SubtaskIconChecked, atIndex: self.subtaskStartIndex + index)
            }
        }
        realmNoticationToken()
        if #available(iOS 9, *) {
            self.detailTableView.cellLayoutMarginsFollowReadableWidth = false
        }
        
        self.detailTableView.tableFooterView = UIView()
        self.detailTableView.registerNib(TaskDateTableViewCell.nib, forCellReuseIdentifier: TaskDateTableViewCell.reuseId)
        self.detailTableView.registerNib(SubtaskTableViewCell.nib, forCellReuseIdentifier: SubtaskTableViewCell.reuseId)
        self.detailTableView.registerNib(TaskNoteTableViewCell.nib, forCellReuseIdentifier: TaskNoteTableViewCell.reuseId)
        
    }
    // 1 set time
    // 2 notify time
    // 3 notify repeat
    // 4 subtask
    // 5 note
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return iconList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let tableCell: UITableViewCell
        if indexPath.row < subtaskStartIndex {
            let cell = tableView.dequeueReusableCellWithIdentifier(TaskDateTableViewCell.reuseId, forIndexPath: indexPath) as! TaskDateTableViewCell
            cell.configCell(task, iconString: iconList[indexPath.row])
            cell.clearButton.tag = indexPath.row
            cell.clearButton.addTarget(self, action: #selector(self.clearAction(_:)), forControlEvents: .TouchUpInside)
            tableCell = cell
        } else if indexPath.row == iconList.count - 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier(TaskNoteTableViewCell.reuseId, forIndexPath: indexPath) as! TaskNoteTableViewCell
            cell.configCell(task)
            tableCell = cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(SubtaskTableViewCell.reuseId, forIndexPath: indexPath) as! SubtaskTableViewCell
            let row = indexPath.row
            if iconList[row] == SubtaskIconAdd {
                cell.configCell(task, subtask: nil, iconString: SubtaskIconAdd)
            } else {
                cell.configCell(task, subtask: self.subtasks?[row - subtaskStartIndex], iconString: iconList[indexPath.row])
            }
            tableCell = cell
        }
        
        tableCell.userInteractionEnabled = change
        return tableCell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row < subtaskStartIndex {
            return TaskDateTableViewCell.rowHeight
        } else if indexPath.row == iconList.count - 1 {
            return TaskNoteTableViewCell.rowHeight
        } else {
            return SubtaskTableViewCell.rowHeight
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row < 2 {
            self.taskPickerView?.setIndex(indexPath.row)
            self.showDatePickerView(show: true)
        } else if indexPath.row == 2 {
            self.taskPickerView?.setIndex(indexPath.row)
            self.showDatePickerView(show: true)
        } else {
            if indexPath.row == self.iconList.count - 1 {
                let noteVC = NoteViewController(task: self.task, noteDelegate: self)
                self.navigationController?.pushViewController(noteVC, animated: true)
//                self.presentViewController(noteVC, animated: true, completion: { })
            }
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
}

// MARK: - task data picker
extension TaskDetailViewController {
    
    func cancelDatePickerAction() {
        guard let datePicker = self.taskPickerView else { return }
        showDatePickerView(show: false)
        let index = NSIndexPath(forRow: datePicker.getIndex(), inSection: 0)
        self.detailTableView.reloadRowsAtIndexPaths([index], withRowAnimation: .Automatic)
    }
    
    func setDatePickerAction() {
        guard let taskPickerView = self.taskPickerView else { return }
        RealmManager.shareManager.updateObject {
            switch taskPickerView.getIndex() {
            case 0:
                self.task.createdDate = taskPickerView.datePicker.date
                self.task.createdFormattedDate = taskPickerView.datePicker.date.createdFormatedDateString()
            case 1:
                self.task.notifyDate = taskPickerView.datePicker.date
                LocalNotificationManager().createNotify(self.task)
            default:
                break
            }
        }
        
        showDatePickerView(show: false)
        let index = NSIndexPath(forRow: taskPickerView.getIndex(), inSection: 0)
        self.detailTableView.reloadRowsAtIndexPaths([index], withRowAnimation: .Automatic)
    }
    
    private func showDatePickerView(show show: Bool) {
        if (show) {
            if KeyboardManager.keyboardShow {
                self.view.endEditing(true)
                guard let datePickerView = self.taskPickerView else { return }
                let selectedIndex = NSIndexPath(forRow: datePickerView.getIndex(), inSection: 0)
                self.detailTableView.selectRowAtIndexPath(selectedIndex, animated: false, scrollPosition: .None)
            }
            if (self.taskPickerView?.viewIsShow() == true) {
                self.datePickerViewBottomConstraint.constant = -TaskPickerView.height
                UIView.animateWithDuration(kSmallAnimationDuration, delay: 0, options: .CurveEaseInOut, animations: { [unowned self] in
                    self.datePickerHolderView.layoutIfNeeded()
                }) { [unowned self] (finish) in
                    self.datePickerViewBottomConstraint.constant = 0
                    UIView.animateWithDuration(kSmallAnimationDuration, delay: 0, options: .CurveEaseInOut, animations: {
                        self.datePickerHolderView.layoutIfNeeded()
                    }) { (finish) in }
                }
                return
            }
        }
        
        self.datePickerViewBottomConstraint.constant = show ? 0 : -TaskPickerView.height
        UIView.animateWithDuration(kSmallAnimationDuration, delay: 0, options: .CurveEaseInOut, animations: {  [unowned self] in
            self.datePickerHolderView.layoutIfNeeded()
        }) { (finish) in }
    }

}

// MARK: - TaskNoteDataDelegate
extension TaskDetailViewController: TaskNoteDataDelegate {
    func taskNoteAdd(newNote: String) {
        RealmManager.shareManager.updateObject { 
            self.task.taskNote = newNote
            let index = NSIndexPath(forRow: iconList.count - 1, inSection: 0)
            self.detailTableView.reloadRowsAtIndexPaths([index], withRowAnimation: .Automatic)
        }
    }
}

protocol TaskNoteDataDelegate {
    func taskNoteAdd(newNote: String)
}
