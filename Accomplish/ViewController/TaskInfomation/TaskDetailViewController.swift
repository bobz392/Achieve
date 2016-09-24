//
//  TaskDetailViewController.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/29.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit
import RealmSwift

let TaskIconCalendar = "fa-calendar-plus-o"
let TaskDueIconCalendar = "fa-calendar-minus-o"
let TaskIconBell = "fa-bell-o"
let TaskIconRepeat = "fa-repeat"
let SubtaskIconAdd = "fa-plus"
let TaskTagIcon = "fa-tag"
let SystemIcon = "fa-archive"
let TaskIconNote = "fa-pencil-square-o"
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
    
    fileprivate var taskPickerView: TaskPickerView?
    
    fileprivate var iconList = [
        [TaskIconCalendar, TaskDueIconCalendar, TaskIconBell, TaskIconRepeat, TaskTagIcon],
        [SubtaskIconAdd],
        [TaskIconNote]
    ]
    fileprivate let subtaskSection = 1
    
    var task: Task
    // only today running task can change
    var canChange: Bool = true
    fileprivate var subtasks: Results<Subtask>?
    fileprivate var subtasksToken: RealmSwift.NotificationToken?
    
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
        
        LocalNotificationManager().requestAuthorization()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        KeyboardManager.sharedManager.closeNotification()
        
        guard let count = subtasks?.count
            , self.task.subTaskCount != count
            else { return }
        
        RealmManager.shareManager.updateObject {
            self.task.subTaskCount = count
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
                                           icon: backButtonIconString, color: colors.mainGreenColor, status: .normal)
        
        self.detailTableView.reloadData()
    }
    
    fileprivate func initializeControl() {
        self.initializeTableView()
        
        self.cancelButton.addShadow()
        self.cancelButton.layer.cornerRadius = kBackButtonCorner
        self.cancelButton.addTarget(self, action: #selector(self.cancelAction), for: .touchUpInside)
        
        self.cardView.addShadow()
        self.cardView.layer.cornerRadius = kCardViewCornerRadius
        
        self.titleTextField.text = task.getNormalDisplayTitle()
        
        guard let taskPickerView = Bundle.main.loadNibNamed("TaskPickerView", owner: self, options: nil)?.last as? TaskPickerView else { return }
        self.datePickerHolderView.addSubview(taskPickerView)
        
        taskPickerView.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.bottom.equalTo(0)
            make.left.equalTo(0)
            make.right.equalTo(0)
        }
        
        self.taskPickerView = taskPickerView
        taskPickerView.task = self.task
        
        taskPickerView.leftButton.addTarget(self, action: #selector(self.cancelDatePickerAction), for: .touchUpInside)
        taskPickerView.rightButton.addTarget(self, action: #selector(self.setDatePickerAction), for: .touchUpInside)
        
        self.configDetailWithTask()
    }
    
    fileprivate func configDetailWithTask() {
        if self.task.taskType == kSystemTaskType {
            self.titleTextField.isEnabled = self.task.taskToDoCanChange() && self.canChange
        } else {
            self.titleTextField.isEnabled = self.canChange
        }
    }
    
    // MARK: - actions
    func clearAction(_ btn: UIButton) {
        let index = IndexPath(row: btn.tag, section: 0)
        detailTableView.reloadRows(at: [index], with: .automatic)
    }
    
    func cancelAction() {
        guard  let nav = self.navigationController else {
            return
        }
        nav.popViewController(animated: true)
    }
    
    fileprivate func keyboardAction() {
        KeyboardManager.sharedManager.setShowHander { [unowned self] in
            self.detailTableViewBottomConstraint.constant =
                KeyboardManager.keyboardHeight - 62
            
            UIView.animate(withDuration: KeyboardManager.duration, animations: {
                self.view.layoutIfNeeded()
                }, completion: { [unowned self] (finsh) in
                    let index = IndexPath(row: self.iconList[self.subtaskSection].count - 1, section: self.subtaskSection)
                    self.detailTableView.scrollToRow(at: index, at: .bottom, animated: true)
                })
            
            if self.taskPickerView?.viewIsShow() == true {
                self.cancelDatePickerAction()
            }
        }
        
        KeyboardManager.sharedManager.setHideHander { [unowned self] in
            self.detailTableViewBottomConstraint.constant = 10
            UIView.animate(withDuration: KeyboardManager.duration, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    fileprivate func realmNoticationToken() {
        self.subtasksToken = subtasks?.addNotificationBlock(block: { [unowned self] (changes: RealmCollectionChange) in
            switch changes {
            case .Initial:
                self.detailTableView.reloadData()
                
            case .Update(_, let deletions, let insertions, let modifications):
                self.detailTableView.beginUpdates()
                if insertions.count > 0 {
                    for index in insertions {
                        self.iconList[self.subtaskSection].insert(SubtaskIconSquare, at: index)
                    }
                    
                    self.detailTableView.insertRows(at: insertions.map { IndexPath(row: $0, section: self.subtaskSection) }, with: .automatic)
                }
                
                if modifications.count > 0 {
                    for index in modifications {
                        guard let subtask = self.subtasks?[index] else { continue }
                        self.iconList[self.subtaskSection].remove(at: index)
                        let element = subtask.finishedDate == nil ? SubtaskIconSquare : SubtaskIconChecked
                        self.iconList[self.subtaskSection].insert(element, at: index)
                    }
                    
                    self.detailTableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: self.subtaskSection) }, with: .automatic)
                }
                
                if deletions.count > 0 {
                    for index in deletions {
                        self.iconList[self.subtaskSection].remove(at: index)
                    }
                    self.detailTableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: self.subtaskSection) }, with: .automatic)
                }
                
                self.detailTableView.endUpdates()
                
            case .Error(let error):
                Logger.log("error in realm token = \(error)")
                break
            }
            })
    }
}

// MARK: - UITextFieldDelegate
extension TaskDetailViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        KeyboardManager.sharedManager.closeNotification()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.keyboardAction()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
    fileprivate func initializeTableView() {
        let sts = RealmManager.shareManager.querySubtask(task.uuid)
        self.subtasks = sts
        for index in 0..<sts.count {
            if sts[index].finishedDate == nil {
                iconList[self.subtaskSection].insert(SubtaskIconSquare, at:index)
            } else {
                iconList[self.subtaskSection].insert(SubtaskIconChecked, at: index)
            }
        }
        realmNoticationToken()
        
        self.detailTableView.tableFooterView = UIView()
        self.detailTableView.register(TaskDateTableViewCell.nib, forCellReuseIdentifier: TaskDateTableViewCell.reuseId)
        self.detailTableView.register(SubtaskTableViewCell.nib, forCellReuseIdentifier: SubtaskTableViewCell.reuseId)
        self.detailTableView.register(TaskNoteTableViewCell.nib, forCellReuseIdentifier: TaskNoteTableViewCell.reuseId)
        self.detailTableView.register(SectionTableViewCell.nib, forCellReuseIdentifier: SectionTableViewCell.reuseId)
        
    }
    // 1 set time
    // 2 notify time
    // 3 notify repeat
    // 4 subtask
    // 5 note
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return iconList[section].count + 1
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == self.subtaskSection {
            return nil
        } else {
            return indexPath
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableCell: UITableViewCell
        if indexPath.row > self.iconList[indexPath.section].count - 1 {
            tableCell = tableView.dequeueReusableCell(withIdentifier: SectionTableViewCell.reuseId, for: indexPath)
            tableCell.isUserInteractionEnabled = false
            return tableCell
        }
        
        if  indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: TaskDateTableViewCell.reuseId, for: indexPath) as! TaskDateTableViewCell
            cell.configCell(task, iconString: iconList[indexPath.section][indexPath.row])
            cell.clearButton.tag = indexPath.row
            cell.clearButton.addTarget(self, action: #selector(self.clearAction(_:)), for: .touchUpInside)
            tableCell = cell
            tableCell.isUserInteractionEnabled = canChange
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: TaskNoteTableViewCell.reuseId, for: indexPath) as! TaskNoteTableViewCell
            cell.configCell(task)
            tableCell = cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: SubtaskTableViewCell.reuseId, for: indexPath) as! SubtaskTableViewCell
            let row = indexPath.row
            if iconList[indexPath.section][row] == SubtaskIconAdd {
                cell.configCell(task, subtask: nil, iconString: SubtaskIconAdd)
            } else {
                cell.configCell(task, subtask: self.subtasks?[row], iconString: iconList[indexPath.section][indexPath.row])
            }
            tableCell = cell
            tableCell.isUserInteractionEnabled = canChange
        }
        
        
        return tableCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            dispatch_delay(kSmallAnimationDuration, closure: { [unowned self] in
                let indexString = self.iconList[indexPath.section][indexPath.row]
                self.taskPickerView?.setIndex(index: indexString)
                self.showDatePickerView(show: true)
                })
            
        } else if indexPath.section == 2 {
            let noteVC = NoteViewController(task: self.task, noteDelegate: self)
            self.navigationController?.pushViewController(noteVC, animated: true)
            self.view.endEditing(true)
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.iconList.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
}

// MARK: - task data picker
extension TaskDetailViewController {
    //    [TaskIconCalendar, TaskDueIconCalendar, TaskIconBell, TaskIconRepeat, TaskTagIcon],
    //    [SubtaskIconAdd],
    //    [TaskIconNote]
    fileprivate func getIndexPathFrom(indexString: String) -> IndexPath? {
        guard let index = self.iconList[0].index(of: indexString) else { return nil }
        return IndexPath(row: index, section: 0)
    }
    
    func cancelDatePickerAction() {
        guard let datePicker = self.taskPickerView else { return }
        showDatePickerView(show: false)
        guard let indexPath =
            self.getIndexPathFrom(indexString: datePicker.getIndex()) else { return }
        self.detailTableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func setDatePickerAction() {
        guard let taskPickerView = self.taskPickerView else { return }
        
        switch taskPickerView.getIndex() {
        case TaskIconCalendar:
            guard let date = taskPickerView.datePicker.date as NSDate? else { break }
            RealmManager.shareManager.updateObject {
                self.task.createdDate = date
                self.task.createdFormattedDate = date.createdFormatedDateString()
            }
            
        case TaskDueIconCalendar:
            RealmManager.shareManager.updateObject {
                self.task.estimateDate = taskPickerView.datePicker.date as NSDate
            }
            
        case TaskIconBell:
            RealmManager.shareManager.updateObject {
                let date = taskPickerView.datePicker.date
                let fireDate = NSDate(year: (date as NSDate).year(), month: (date as NSDate).month(), day: (date as NSDate).day(), hour: (date as NSDate).hour(), minute: (date as NSDate).minute(), second: 5)
                
                self.task.notifyDate = fireDate
            }
            LocalNotificationManager().createNotify(self.task)
            
        case TaskIconRepeat:
            let repeatTimeType = taskPickerView.repeatTimeType()
            RealmManager.shareManager
                .repeaterUpdate(self.task, repeaterTimeType: repeatTimeType)
            
        case TaskTagIcon:
            let tagUUID = taskPickerView.selectedTagUUID()
            RealmManager.shareManager.updateObject({
                self.task.tagUUID = tagUUID
            })
            
        default:
            break
        }
        
        self.showDatePickerView(show: false)
        guard let indexPath =
            self.getIndexPathFrom(indexString: taskPickerView.getIndex()) else { return }
        self.detailTableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    // to-do
    fileprivate func showDatePickerView(show: Bool) {
        if (show) {
            if KeyboardManager.keyboardShow {
                self.view.endEditing(true)
                guard let datePickerView = self.taskPickerView else { return }
                guard let selectedIndex =
                    self.getIndexPathFrom(indexString: datePickerView.getIndex()) else { return }
                self.detailTableView.selectRow(at: selectedIndex, animated: false, scrollPosition: .none)
            }
            if (self.taskPickerView?.viewIsShow() == true) {
                self.datePickerViewBottomConstraint.constant = -TaskPickerView.height
                UIView.animate(withDuration: kSmallAnimationDuration, delay: 0, options: UIViewAnimationOptions.allowAnimatedContent, animations: { [unowned self] in
                    self.view.layoutIfNeeded()
                }) { [unowned self] (finish) in
                    self.datePickerViewBottomConstraint.constant = 0
                    UIView.animate(withDuration: kSmallAnimationDuration, delay: 0, options: UIViewAnimationOptions(), animations: {
                        self.view.layoutIfNeeded()
                    }) { (finish) in }
                }
                return
            }
        }
        
        self.datePickerViewBottomConstraint.constant = show ? 0 : -TaskPickerView.height
        UIView.animate(withDuration: kSmallAnimationDuration, delay: 0, options: UIViewAnimationOptions(), animations: {  [unowned self] in
            self.view.layoutIfNeeded()
        }) { (finish) in }
    }
    
}

// MARK: - TaskNoteDataDelegate
extension TaskDetailViewController: TaskNoteDataDelegate {
    func taskNoteAdd(_ newNote: String) {
        RealmManager.shareManager.updateObject {
            self.task.taskNote = newNote
            let index = IndexPath(row: 0, section: iconList.count - 1)
            self.detailTableView.reloadRows(at: [index], with: .automatic)
        }
    }
}

protocol TaskNoteDataDelegate {
    func taskNoteAdd(_ newNote: String)
}
