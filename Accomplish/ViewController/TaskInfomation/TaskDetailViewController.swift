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
    private var iconList = [
        [SubtaskIconCalendar, SubtaskIconBell, SubtaskIconRepeat],
        [SubtaskIconAdd],
        [SubtaskIconNote]
    ]
    private let subtaskSection = 1
    
    var task: Task
    // only running task can change
    var canChange: Bool = true
    private var subtasks: Results<Subtask>?
    private var subtasksToken: RealmSwift.NotificationToken?
    
    init(task: Task, canChange: Bool) {
        self.task = task
        self.canChange = canChange
        super.init(nibName: "TaskDetailViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.task = Task()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        self.configMainUI()
        self.initializeControl()
        //fa-share-square-o
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard let count = subtasks?.count
            where self.task.subTaskCount != count
            else { return }
        
        RealmManager.shareManager.updateObject {
            self.task.subTaskCount = count
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.keyboardAction()
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
        self.cancelButton.createIconButton(iconSize: kBackButtonCorner, imageSize: kBackButtonCorner,
                                           icon: backButtonIconString, color: colors.mainGreenColor, status: .Normal)
        
        self.detailTableView.reloadData()
    }
    
    private func initializeControl() {
        self.initializeTableView()
        
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
            self.titleTextField.enabled = self.task.taskToDoCanChange() && self.canChange
        } else {
           self.titleTextField.enabled = self.canChange
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
                    let index = NSIndexPath(forRow: self.iconList[self.subtaskSection].count - 1, inSection: self.subtaskSection)
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
                self.detailTableView.reloadData()
                
            case .Update(_, let deletions, let insertions, let modifications):
                self.detailTableView.beginUpdates()
                if insertions.count > 0 {
                    for index in insertions {
                        self.iconList[self.subtaskSection].insert(SubtaskIconSquare, atIndex: index)
                    }
                    
                    self.detailTableView.insertRowsAtIndexPaths(insertions.map { NSIndexPath(forRow: $0, inSection: self.subtaskSection) }, withRowAnimation: .Automatic)
                }
                
                if modifications.count > 0 {
                    for index in modifications {
                        guard let subtask = self.subtasks?[index] else { continue }
                        self.iconList[self.subtaskSection].removeAtIndex(index)
                        let element = subtask.finishedDate == nil ? SubtaskIconSquare : SubtaskIconChecked
                        self.iconList[self.subtaskSection].insert(element, atIndex: index)
                    }
                    
                    self.detailTableView.reloadRowsAtIndexPaths(modifications.map { NSIndexPath(forRow: $0, inSection: self.subtaskSection) }, withRowAnimation: .Automatic)
                }
                
                if deletions.count > 0 {
                    for index in deletions {
                        self.iconList[self.subtaskSection].removeAtIndex(index)
                    }
                    self.detailTableView.deleteRowsAtIndexPaths(deletions.map { NSIndexPath(forRow: $0, inSection: self.subtaskSection) },
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
                iconList[self.subtaskSection].insert(SubtaskIconSquare, atIndex:index)
            } else {
                iconList[self.subtaskSection].insert(SubtaskIconChecked, atIndex: index)
            }
        }
        realmNoticationToken()
        
        self.detailTableView.tableFooterView = UIView()
        self.detailTableView.registerNib(TaskDateTableViewCell.nib, forCellReuseIdentifier: TaskDateTableViewCell.reuseId)
        self.detailTableView.registerNib(SubtaskTableViewCell.nib, forCellReuseIdentifier: SubtaskTableViewCell.reuseId)
        self.detailTableView.registerNib(TaskNoteTableViewCell.nib, forCellReuseIdentifier: TaskNoteTableViewCell.reuseId)
        self.detailTableView.registerNib(SectionTableViewCell.nib, forCellReuseIdentifier: SectionTableViewCell.reuseId)
        
    }
    // 1 set time
    // 2 notify time
    // 3 notify repeat
    // 4 subtask
    // 5 note
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return iconList[section].count + 1
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.section == self.subtaskSection {
            return nil
        } else {
            return indexPath
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let tableCell: UITableViewCell
        if indexPath.row > self.iconList[indexPath.section].count - 1 {
            tableCell = tableView.dequeueReusableCellWithIdentifier(SectionTableViewCell.reuseId, forIndexPath: indexPath)
            tableCell.userInteractionEnabled = false
            return tableCell
        }
        
        if  indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(TaskDateTableViewCell.reuseId, forIndexPath: indexPath) as! TaskDateTableViewCell
            cell.configCell(task, iconString: iconList[indexPath.section][indexPath.row])
            cell.clearButton.tag = indexPath.row
            cell.clearButton.addTarget(self, action: #selector(self.clearAction(_:)), forControlEvents: .TouchUpInside)
            tableCell = cell
            tableCell.userInteractionEnabled = canChange
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCellWithIdentifier(TaskNoteTableViewCell.reuseId, forIndexPath: indexPath) as! TaskNoteTableViewCell
            cell.configCell(task)
            tableCell = cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(SubtaskTableViewCell.reuseId, forIndexPath: indexPath) as! SubtaskTableViewCell
            let row = indexPath.row
            if iconList[indexPath.section][row] == SubtaskIconAdd {
                cell.configCell(task, subtask: nil, iconString: SubtaskIconAdd)
            } else {
                cell.configCell(task, subtask: self.subtasks?[row], iconString: iconList[indexPath.section][indexPath.row])
            }
            tableCell = cell
            tableCell.userInteractionEnabled = canChange
        }
        
        
        return tableCell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row > self.iconList[indexPath.section].count - 1 {
            return SectionTableViewCell.rowHeight
        }
        
        if indexPath.section == 0 {
            return TaskDateTableViewCell.rowHeight
        } else if indexPath.section == 2 {
            return TaskNoteTableViewCell.rowHeight
        } else {
            return SubtaskTableViewCell.rowHeight
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
//            if indexPath.row < 2 {
                self.taskPickerView?.setIndex(indexPath.row)
                self.showDatePickerView(show: true)
//            } else if indexPath.row == 2 {
//                self.taskPickerView?.setIndex(indexPath.row)
//                self.showDatePickerView(show: true)
//            }
        } else if indexPath.section == 2 {
            let noteVC = NoteViewController(task: self.task, noteDelegate: self)
            self.navigationController?.pushViewController(noteVC, animated: true)
            self.view.endEditing(true)
            
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.iconList.count
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
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
        
        switch taskPickerView.getIndex() {
        case 0:
            RealmManager.shareManager.updateObject {
                self.task.createdDate = taskPickerView.datePicker.date
                self.task.createdFormattedDate = taskPickerView.datePicker.date.createdFormatedDateString()
            }
            
        case 1:
            RealmManager.shareManager.updateObject {
                let date = taskPickerView.datePicker.date
                let fireDate = NSDate(year: date.year(), month: date.month(), day: date.day(), hour: date.hour(), minute: date.minute(), second: 5)
            
                self.task.notifyDate = fireDate
            }
            LocalNotificationManager().createNotify(self.task)
            
        case 2:
            let repeatTimeType = taskPickerView.repeatTimeType()
            RealmManager.shareManager
                .repeaterUpdate(self.task, repeaterTimeType: repeatTimeType)
//            let repeater =
//                RealmManager.shareManager.repeaterWithTask(taskUUID: self.task.uuid)
//
//
//
//            repeater.repeatType = Int(repeatType.rawValue)
//            RealmManager.shareManager.writeObject(repeater)
//            if self.task.notifyDate != nil {
//                LocalNotificationManager().updateNotify(self.task)
//            }
            
        default:
            break
        }
        
        showDatePickerView(show: false)
        let index = NSIndexPath(forRow: taskPickerView.getIndex(), inSection: 0)
        self.detailTableView.reloadRowsAtIndexPaths([index], withRowAnimation: .Automatic)
    }
    
    // to-do
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
            let index = NSIndexPath(forRow: 0, inSection: iconList.count - 1)
            self.detailTableView.reloadRowsAtIndexPaths([index], withRowAnimation: .Automatic)
        }
    }
}

protocol TaskNoteDataDelegate {
    func taskNoteAdd(newNote: String)
}
