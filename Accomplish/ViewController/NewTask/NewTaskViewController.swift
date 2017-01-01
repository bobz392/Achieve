//
//  NewTaskViewController.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/24.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class NewTaskViewController: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var renderImageView: UIImageView!
    @IBOutlet weak var titleCardView: UIView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var priorityCardView: UIView!
    @IBOutlet weak var prioritySlideSegmental: TwicketSegmentedControl!
    @IBOutlet weak var priorityLabel: UILabel!
    @IBOutlet weak var clockButton: UIButton!
    @IBOutlet weak var systemButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var toolView: UIView!
    
    @IBOutlet weak var dateToolView: UIView!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var dateToolLineView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var cancelDateButton: UIButton!
    @IBOutlet weak var setDateButton: UIButton!
    
    fileprivate let cardViewHeight: CGFloat = 194
    fileprivate let datePickerHeight: CGFloat = 200
    
    fileprivate let task = Task()
    fileprivate var subtaskString: String? = nil
    
    // MARK: - life circle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.keyboardAction()
        if (toolView.alpha == 1) {
            titleTextField.becomeFirstResponder()
        }
        
        appDelegate?.setOpenDrawMode(openMode: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        KeyboardManager.sharedManager.closeNotification()
        appDelegate?.setOpenDrawMode(openMode: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func configMainUI() {
        self.cardView.backgroundColor = Colors.cloudColor
        self.prioritySlideSegmental.sliderBackgroundColor = Colors.cellLabelSelectedTextColor
        self.priorityLabel.textColor = Colors.mainTextColor
        self.toolView.backgroundColor = Colors.cloudColor
        self.lineView.backgroundColor = Colors.separatorColor
        self.dateToolLineView.backgroundColor = Colors.separatorColor
        self.dateToolView.backgroundColor = Colors.cloudColor
        self.datePicker.backgroundColor = Colors.cloudColor
        
        self.cancelButton.tintColor = Colors.cellLabelSelectedTextColor
        self.saveButton.tintColor = Colors.cellLabelSelectedTextColor
        self.setDateButton.tintColor = Colors.cellLabelSelectedTextColor
        self.cancelDateButton.tintColor = Colors.cellLabelSelectedTextColor
        
        self.clockButton.setImage(Icons.schedule.iconImage(), for: .normal)
        self.clockButton.tintColor = Colors.cellLabelSelectedTextColor
        
        self.systemButton.setImage(Icons.briefcase.iconImage(), for: .normal)
        self.systemButton.tintColor = Colors.cellLabelSelectedTextColor
    }
    
    fileprivate func initializeControl() {
        self.cardView.addShadow()
        
        self.titleCardView.layer.cornerRadius = kCardViewSmallCornerRadius
        self.titleCardView.addSmallShadow()
        
        self.priorityCardView.layer.cornerRadius = kCardViewSmallCornerRadius
        self.priorityCardView.addSmallShadow()
        
        self.dateToolView.isHidden = true
        self.datePicker.isHidden = true
        self.datePicker.datePickerMode = .dateAndTime
        self.datePicker.minimumDate = Date()
        
        self.titleTextField.placeholder = Localized("goingDo")
        self.cancelButton.setTitle(Localized("cancel"), for: .normal)
        
        self.cancelDateButton.setTitle(Localized("remove"), for: .normal)
        self.setDateButton.setTitle(Localized("setCreateDate"), for: .normal)
        self.saveButton.setTitle(Localized("add"), for: .normal)
        
        self.priorityLabel.text = Localized("priority")
        
        let segTitles = [Localized("priority0"), Localized("priority1"), Localized("priority2")]
        self.prioritySlideSegmental.setSegmentItems(segTitles)
        self.prioritySlideSegmental.move(to: 1, animation: false)
        
        self.cancelButton.addTarget(self, action: #selector(self.cancelAction), for: .touchUpInside)
        self.clockButton.addTarget(self, action: #selector(self.scheduleAction), for: .touchUpInside)
        self.systemButton.addTarget(self, action: #selector(self.systemAction), for: .touchUpInside)
        self.saveButton.addTarget(self, action: #selector(self.saveAction), for: .touchUpInside)
        
        self.cancelDateButton.addTarget(self, action: #selector(self.cancelScheduleAction), for: .touchUpInside)
        self.setDateButton.addTarget(self, action: #selector(self.saveScheduleAction), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dissmiss(_:)))
        self.view.addGestureRecognizer(tap)
    }
    
    // MARK: - actions
    fileprivate func keyboardAction() {
        KeyboardManager.sharedManager.setShowHander { [unowned self] in
            self.cardViewTopConstraint.constant =
                (self.view.frame.height - KeyboardManager.keyboardHeight - self.cardViewHeight) * 0.5
            
            UIView.animate(withDuration: kNormalLongAnimationDuration, delay: kKeyboardAnimationDelay, usingSpringWithDamping: 0.7, initialSpringVelocity: 10, options: UIViewAnimationOptions(), animations: { [unowned self] in
                self.view.layoutIfNeeded()
            }) { [unowned self] (finish) in
                self.toolViewBottomConstraint.constant = KeyboardManager.keyboardHeight
                self.toolView.alpha = 1
                UIView.animate(withDuration: kSmallAnimationDuration, animations: { [unowned self] in
                    self.view.layoutIfNeeded()
                    })
            }
        }
        
    }
    
    func cancelAction() {
        self.removeFromParentViewController()
    }
    
    func saveAction() {
        if task.taskToDo.characters.count > 0 {
            self.saveNewTask(task.taskToDo)
            return
        } else {
            guard let title = titleTextField.text else {
                return
            }
            self.saveNewTask(title)
        }
    }
    
    func dueDateAction() {
        KeyboardManager.sharedManager.closeNotification()
        self.titleTextField.resignFirstResponder()
    }
    
    func scheduleAction() {
        KeyboardManager.sharedManager.closeNotification()
        self.titleTextField.resignFirstResponder()
        
        self.dateToolView.isHidden = false
        self.datePicker.isHidden = false
        
        self.cardViewTopConstraint.constant =
            (self.view.frame.height - self.datePickerHeight - self.cardViewHeight) * 0.5
        self.toolViewBottomConstraint.constant = self.datePickerHeight
        
        UIView.animate(withDuration: kNormalAnimationDuration, delay: 0, options: UIViewAnimationOptions(), animations: {
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    func cancelScheduleAction() {
        self.clockButton.tintColor = Colors.secondaryTextColor
        self.task.createdDate = nil
        
        self.closeDatePicker()
    }
    
    fileprivate func closeDatePicker() {
        if self.titleTextField.isEnabled == true {
            self.datePicker.isHidden = true
            self.dateToolView.isHidden = true
            
            self.keyboardAction()
            self.titleTextField.becomeFirstResponder()
        } else {
            self.cardViewTopConstraint.constant =
                (self.view.frame.height - self.cardViewHeight) * 0.5
            self.toolViewBottomConstraint.constant = 0
            
            UIView.animate(withDuration: kNormalAnimationDuration, delay: 0, options: UIViewAnimationOptions(), animations: {
                self.dateToolView.isHidden = true
                self.view.layoutIfNeeded()
                }, completion: { (finish) -> Void in
                    self.datePicker.isHidden = true
            })
        }
    }
    
    func saveScheduleAction() {
        let selectedDate = self.datePicker.date as NSDate
        self.task.createdDate = selectedDate
        
        self.clockButton.tintColor = Colors().mainGreenColor
        self.closeDatePicker()
    }
    
    func systemAction() {
        let systemVC = SystemTaskViewController()
        let nav = UINavigationController(rootViewController: systemVC)
        nav.view.backgroundColor = Colors().mainGreenColor
        nav.isNavigationBarHidden = true
        systemVC.newTaskDelegate = self
        self.parent?.present(nav, animated: true, completion: { })
    }
    
    // MARK: - logic
    func saveNewTask(_ taskToDo: String) {
        guard taskToDo.characters.count > 0 else {
            return
        }
        let priority = self.prioritySlideSegmental.selectedSegmentIndex
        self.task.createDefaultTask(taskToDo, priority:  priority)
        
        let tagUUID = AppUserDefault().readString(kUserDefaultCurrentTagUUIDKey)
        self.task.tagUUID = tagUUID
        
        self.saveSubtasks()
        RealmManager.shared.writeObject(self.task)
        
        if #available(iOS 9.0, *) {
            SpotlightManager().addTaskToIndex(task: self.task)
        }
        
        self.cancelAction()
    }
    
    fileprivate func saveSubtasks() {
        guard let subtaskString = self.subtaskString else { return }
        let subTasks = subtaskString.components(separatedBy: "\n")
        self.task.subTaskCount = subTasks.count
        let now = NSDate()
        self.task.createdDate = now
        
        let tasks = subTasks.enumerated().flatMap({ (index: Int, sub: String) -> Subtask? in
            guard sub.characters.count > 0 else { return nil }
            let subtask = Subtask()
            subtask.rootUUID = task.uuid
            let createdDate = (now as NSDate).addingSeconds(index) as NSDate
            subtask.createdDate = createdDate
            subtask.taskToDo = sub
            subtask.uuid = createdDate.createTaskUUID()
            return subtask
            
        })
        
        RealmManager.shared.writeObjects(tasks)
    }
    
    // MARK: - textfield
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text,
            !text.isRealEmpty else { return true }
        
        self.saveNewTask(text)
        return true
    }
    
    func dissmiss(_ tap: UITapGestureRecognizer) {
        if (!self.cardView.frame.contains(tap.location(in: self.view))
            && !self.toolView.frame.contains(tap.location(in: self.view))) {
            self.removeFromParentViewController()
        }
    }
    
    @IBOutlet weak var cardViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var toolViewBottomConstraint: NSLayoutConstraint!
}

// MARK: - parent view controller
extension NewTaskViewController {
    
    override func willMove(toParentViewController parent: UIViewController?) {
        guard let p = parent else {
            return
        }
        
        let image = p.view.convertViewToImage()
        
        self.view.frame = p.view.frame
        p.view.addSubview(self.view)
        
        self.renderImageView.image =
            image.blurredImage(5, iterations: 3, ratio: 2.0, blendColor: nil, blendMode: .clear)
        
        self.cardViewTopConstraint.constant =
            (p.view.frame.height - cardViewHeight - KeyboardManager.keyboardHeight) * 0.5
        
        self.configMainUI()
        self.initializeControl()
        
        super.willMove(toParentViewController: parent)
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        guard let _ = parent else {
            return
        }
        
        self.renderImageView.alpha = 0
        self.cardView.alpha = 0
        self.cardView.layer.cornerRadius = kCardViewCornerRadius
        
        UIView.animate(withDuration: kNormalAnimationDuration, animations: { [unowned self] in
            self.renderImageView.alpha = 1
            self.cardView.alpha = 1
            }, completion: { (finish) in
                self.titleTextField.becomeFirstResponder()
        })
        
        super.didMove(toParentViewController: parent)
    }
    
    override func removeFromParentViewController() {
        self.titleTextField.resignFirstResponder()
        self.toolView.isHidden = true
        UIView.animate(withDuration: kNormalAnimationDuration, animations: { [unowned self] in
            self.view.alpha = 0
            }, completion: { [unowned self] (finish) in
                self.view.removeFromSuperview()
            })
    }
}

extension NewTaskViewController: NewTaskDataDelegate {
    // MARK: - NewTaskDateDelegate
    
    func notifyTaskDate(date: NSDate) {
        task.notifyDate = date
    }
    
    func toDoForSystemTask(text: NSAttributedString, task: Task) {
        self.titleTextField.attributedText = text
        self.titleTextField.isEnabled = false
        self.systemButton.isHidden = true
        self.saveButton.isHidden = false
        
        self.task.taskToDo = task.taskToDo
        self.task.taskType = task.taskType
        self.task.createdDate = task.createdDate
        self.task.subTaskCount = task.subTaskCount
        
        self.toolViewBottomConstraint.constant = 0
        self.cardViewTopConstraint.constant = (self.view.frame.height - self.cardViewHeight) * 0.5
    }
    
    func toDoForSystemSubtask(text: NSAttributedString, task: Task, subtasks: String) {
        self.toDoForSystemTask(text: text, task: task)
        self.subtaskString = subtasks
    }
}


protocol NewTaskDataDelegate: NSObjectProtocol {
    func notifyTaskDate(date: NSDate)
    // 设置当前的 text 和 taskToDoTask
    func toDoForSystemTask(text: NSAttributedString, task: Task)
    func toDoForSystemSubtask(text: NSAttributedString, task: Task, subtasks: String)
}
