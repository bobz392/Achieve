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
let TaskIconReminder = "fa-bell-o"
let TaskIconRepeat = "fa-repeat"
let SubtaskIconAdd = "fa-plus"
let TaskTagIcon = "fa-tag"
let SystemIcon = "fa-archive"
let TaskIconNote = "fa-pencil-square-o"
let SubtaskIconSquare = "fa-square-o"
let SubtaskIconChecked = "fa-check-square-o"

class TaskDetailViewController: BaseViewController {

    fileprivate var taskPickerView: TaskPickerView? = nil
    fileprivate let taskToDoTextView = GrowingTextView()
    fileprivate let detailTableView = UITableView()
    fileprivate let dateLabel = UILabel()
    
    fileprivate var iconList = [
        [Icons.schedule, Icons.due, Icons.notify, Icons.loop, Icons.tag],
        [Icons.smallPlus],
        [Icons.note]
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
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.task = Task()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configMainUI()
        self.initializeControl()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        KeyboardManager.sharedManager.closeNotification()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        guard let count = subtasks?.count
            , self.task.subTaskCount != count
            else { return }
        
        RealmManager.shared.updateObject {
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
        subtasksToken?.invalidate()
    }
    
    override func configMainUI() {
        self.view.backgroundColor = Colors.mainBackgroundColor
        
        let bar = self.createCustomBar(withBottomLine: true)
        let backButton = self.createLeftBarButton(icon: Icons.back)
        backButton.addTarget(self, action: #selector(self.backAction), for: .touchUpInside)
        
        bar.addSubview(taskToDoTextView)
        taskToDoTextView.maxHeight = 160
        taskToDoTextView.font = appFont(size: 18)
        taskToDoTextView.text = self.task.realTaskToDo()
        taskToDoTextView.textColor = Colors.mainTextColor
        taskToDoTextView.clearView()
        taskToDoTextView.textAlignment = .left
        taskToDoTextView.tintColor = Colors.mainTextColor
        taskToDoTextView.isEditable = self.canChange
        taskToDoTextView.delegate = self
        taskToDoTextView.returnKeyType = .done
        taskToDoTextView.snp.makeConstraints { (make) in
            make.left.equalTo(backButton.snp.right).offset(8)
            make.right.equalToSuperview().offset(-12)
            make.top.equalToSuperview().offset(23)
        }
        
        dateLabel.font = appFont(size: 12)
        dateLabel.textColor = Colors.secondaryTextColor
        dateLabel.text = self.task.createdDate?.getDateString()
        dateLabel.textAlignment = .right
        bar.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { (make) in
            make.top.equalTo(taskToDoTextView.snp.bottom).offset(4)
            make.bottom.equalToSuperview().offset(-6)
        }
        
        let dateImageView = UIImageView()
        dateImageView.image = Icons.arrangement.iconImage()
        dateImageView.tintColor = Colors.secondaryTextColor
        bar.addSubview(dateImageView)
        dateImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(dateLabel).offset(-0.5)
            make.width.equalTo(12)
            make.height.equalTo(12)
            make.right.equalTo(dateLabel.snp.left).offset(-4)
            make.left.equalTo(taskToDoTextView).offset(6)
        }
        
        self.detailTableView.clearView()
        self.detailTableView.delegate = self
        self.detailTableView.dataSource = self
        self.detailTableView.separatorStyle = .none
        self.view.addSubview(self.detailTableView)
        self.detailTableView.snp.makeConstraints { (make) in
            make.top.equalTo(bar.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        } 
        self.detailTableView.reloadData()
    }
    
    fileprivate func initializeControl() {
        self.initializeTableView()
        guard let taskPickerView = Bundle.main
            .loadNibNamed("TaskPickerView", owner: self, options: nil)?.last as? TaskPickerView else { return }
        self.view.addSubview(taskPickerView)
        
        taskPickerView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.snp.bottom)
            make.height.equalTo(TaskPickerView.height)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        self.taskPickerView = taskPickerView
        taskPickerView.task = self.task
        
        taskPickerView.leftButton.addTarget(self, action: #selector(self.cancelDatePickerAction), for: .touchUpInside)
        taskPickerView.rightButton.addTarget(self, action: #selector(self.setDatePickerAction), for: .touchUpInside)
    }
    
    // MARK: - actions
    @objc func clearAction(_ btn: UIButton) {
        let index = IndexPath(row: btn.tag, section: 0)
        detailTableView.reloadRows(at: [index], with: .automatic)
    }
    
    fileprivate func keyboardAction() {
        KeyboardManager.sharedManager.setShowHander { [unowned self] in
            self.detailTableView.snp.updateConstraints({ (make) in
                make.bottom.equalToSuperview().offset(-KeyboardManager.keyboardHeight)
            })
            
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
            self.detailTableView.snp.updateConstraints({ (make) in
                make.bottom.equalToSuperview()
            })
            UIView.animate(withDuration: KeyboardManager.duration, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    fileprivate func realmNoticationToken() {
        self.subtasksToken = subtasks?.observe({ [unowned self] (changes: RealmCollectionChange) in
            switch changes {
            case .initial(_):
                self.detailTableView.reloadData()
                
            case .update(_, let deletions, let insertions, let modifications):
                self.detailTableView.beginUpdates()
                if insertions.count > 0 {
                    for index in insertions {
                        self.iconList[self.subtaskSection].insert(Icons.uncheck, at: index)
                    }
                    
                    self.detailTableView.insertRows(at: insertions.map { IndexPath(row: $0, section: self.subtaskSection) }, with: .automatic)
                }
                
                if modifications.count > 0 {
                    for index in modifications {
                        guard let subtask = self.subtasks?[index] else { continue }
                        self.iconList[self.subtaskSection].remove(at: index)
                        let element = subtask.finishedDate == nil ? Icons.uncheck : Icons.check
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
                
            case .error(let error):
                Logger.log("error in realm token = \(error)")
                break
            }
            })
    }
    
}

// MARK: - textview delegate
extension TaskDetailViewController: GrowingTextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        KeyboardManager.sharedManager.closeNotification()
        if self.taskPickerView?.viewIsShow() == true {
            self.cancelDatePickerAction()
        }
        
        return true

    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.endEditing(true)
            return false
        }
        
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if let title = textView.text,
            !title.isRealEmpty == true {
            RealmManager.shared.updateObject({
                self.task.taskToDo = title
            })
        } else {
            textView.text = self.task.realTaskToDo()
        }
        
        self.keyboardAction()
        textView.resignFirstResponder()
    }
    
    func textViewDidChangeHeight(_ height: CGFloat) {
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
}

// MARK: - table view
extension TaskDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    fileprivate func initializeTableView() {
        let sts = RealmManager.shared.querySubtask(task.uuid)
        self.subtasks = sts
        for index in 0..<sts.count {
            if sts[index].finishedDate == nil {
                iconList[self.subtaskSection].insert(Icons.uncheck, at:index)
            } else {
                iconList[self.subtaskSection].insert(Icons.check, at: index)
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
            cell.configCell(task, icon: iconList[indexPath.section][indexPath.row])
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
            if self.iconList[indexPath.section][row] == .smallPlus {
                cell.configCell(task, subtask: nil, icon: .smallPlus, isAdd: true)
            } else {
                cell.configCell(task, subtask: self.subtasks?[row], icon: iconList[indexPath.section][indexPath.row], isAdd: false)
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
                let icon = self.iconList[indexPath.section][indexPath.row]
                self.taskPickerView?.setCurrentIcon(icon: icon)
                self.showDatePickerView(show: true)
                })
            
            if indexPath.row == 2 {
                LocalNotificationManager.shared.requestAuthorization()
            }
            
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
        if section == 0 {
            return 17
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view =  UIView()
        view.clearView()
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
}

// MARK: - task data picker
extension TaskDetailViewController {
    fileprivate func getIndexPathFrom(icon: Icons) -> IndexPath? {
        guard let index = self.iconList[0].index(of: icon) else { return nil }
        return IndexPath(row: index, section: 0)
    }
    
    @objc func cancelDatePickerAction() {
        guard let datePicker = self.taskPickerView else { return }
        showDatePickerView(show: false)
        guard let indexPath =
            self.getIndexPathFrom(icon: datePicker.getCurrentIcon()) else { return }
        self.detailTableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    @objc func setDatePickerAction() {
        guard let taskPickerView = self.taskPickerView else { return }
        let weakSelf = self
        switch taskPickerView.getCurrentIcon() {
        case .schedule:
            guard let date = taskPickerView.datePicker.date as NSDate? else { break }
            RealmManager.shared.updateObject {
                TaskListManager.updateCurrentStatus(newStatues: .resort)
                weakSelf.task.createdDate = date
                let formatDate = date.createdFormatedDateString()
                if formatDate != weakSelf.task.createdFormattedDate {
                    weakSelf.task.createdFormattedDate = formatDate
                }
                weakSelf.dateLabel.text = date.getDateString()
            }
            
        case .due:
            RealmManager.shared.updateObject {
                weakSelf.task.estimateDate = taskPickerView.datePicker.date as NSDate
            }
            
        case .notify:
            RealmManager.shared.updateObject {
                let date = taskPickerView.datePicker.date as NSDate
                let fireDate = NSDate(year: date.year(), month: date.month(), day: date.day(), hour: date.hour(), minute: date.minute(), second: 0)
                weakSelf.task.notifyDate = fireDate
            }
            if let _ = self.task.notifyDate {
                LocalNotificationManager.shared.cancel(self.task)
            }
            LocalNotificationManager.shared.create(self.task)
            
        case .loop:
            let repeatTimeType = taskPickerView.repeatTimeType()
            RealmManager.shared
                .repeaterUpdate(self.task, repeaterTimeType: repeatTimeType)
            LocalNotificationManager.shared.update(self.task)
            
        case .tag:
            let tagUUID = taskPickerView.selectedTagUUID()
            RealmManager.shared.updateObject({
                weakSelf.task.tagUUID = tagUUID
            })
            
        default:
            break
        }
        
        self.showDatePickerView(show: false)
        guard let indexPath =
            self.getIndexPathFrom(icon: taskPickerView.getCurrentIcon()) else { return }
        self.detailTableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    // to-do
    fileprivate func showDatePickerView(show: Bool) {
        if (show) {
            if KeyboardManager.keyboardShow {
                self.view.endEditing(true)
                guard let datePickerView = self.taskPickerView else { return }
                guard let selectedIndex =
                    self.getIndexPathFrom(icon: datePickerView.getCurrentIcon()) else { return }
                self.detailTableView.selectRow(at: selectedIndex, animated: false, scrollPosition: .none)
            }
            if (self.taskPickerView?.viewIsShow() == true) {
                self.taskPickerView?.snp.updateConstraints({ (make) in
                    make.top.equalTo(self.view.snp.bottom)
                })
                UIView.animate(withDuration: kSmallAnimationDuration, delay: 0, options: UIView.AnimationOptions.allowAnimatedContent, animations: { [unowned self] in
                    self.view.layoutIfNeeded()
                }) { [unowned self] (finish) in
                    self.taskPickerView?.snp.updateConstraints({ (make) in
                        make.top.equalTo(self.view.snp.bottom).offset(-TaskPickerView.height)
                    })
                    UIView.animate(withDuration: kSmallAnimationDuration, delay: 0, options: UIView.AnimationOptions(), animations: {
                        self.view.layoutIfNeeded()
                    }) { (finish) in }
                }
                return
            }
        }
        
        self.taskPickerView?.snp.updateConstraints({ (make) in
            make.top.equalTo(self.view.snp.bottom).offset(show ? -TaskPickerView.height : 0)
        })
        UIView.animate(withDuration: kSmallAnimationDuration, delay: 0, options: UIView.AnimationOptions(), animations: {  [unowned self] in
            self.view.layoutIfNeeded()
        }) { (finish) in }
    }
    
}

// MARK: - TaskNoteDataDelegate
extension TaskDetailViewController: TaskNoteDataDelegate {
    func taskNoteAdd(_ newNote: String) {
        RealmManager.shared.updateObject {
            self.task.taskNote = newNote
            let index = IndexPath(row: 0, section: self.iconList.count - 1)
            self.detailTableView.reloadRows(at: [index], with: .automatic)
        }
    }
}

protocol TaskNoteDataDelegate {
    func taskNoteAdd(_ newNote: String)
}
