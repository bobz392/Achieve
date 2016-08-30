//
//  NewTaskViewController.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/24.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit
import GPUImage

class NewTaskViewController: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var renderImageView: UIImageView!
    @IBOutlet weak var titleCardView: UIView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var priorityCardView: UIView!
    @IBOutlet weak var prioritySegmental: UISegmentedControl!
    @IBOutlet weak var priorityLabel: UILabel!
    @IBOutlet weak var clockButton: UIButton!
    @IBOutlet weak var systemButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var toolView: UIView!
    
    @IBOutlet weak var dateToolView: UIView!
    @IBOutlet weak var dateToolLineView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var cancelDateButton: UIButton!
    @IBOutlet weak var setDateButton: UIButton!
    
    private let cardViewHeight: CGFloat = 194
    
    private let task = Task()
    private var subtaskString: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.keyboardAction()
        if (toolView.alpha == 1) {
            titleTextField.becomeFirstResponder()
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidAppear(animated)
        
        KeyboardManager.sharedManager.closeNotification()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        print("deinit")
    }
    
    override func configMainUI() {
        let colors = Colors()
        self.cardView.backgroundColor = colors.cloudColor
        self.titleTextField.tintColor = colors.mainGreenColor
        
        self.prioritySegmental.tintColor = colors.mainGreenColor
        self.priorityLabel.textColor = colors.mainTextColor
        self.toolView.backgroundColor = colors.cloudColor
        self.dateToolLineView.backgroundColor = colors.separatorColor
        self.dateToolView.backgroundColor = colors.cloudColor
        self.datePicker.backgroundColor = colors.cloudColor
        
        self.cancelButton.tintColor = colors.mainGreenColor
        self.saveButton.tintColor = colors.mainGreenColor
        self.setDateButton.tintColor = colors.mainGreenColor
        self.cancelDateButton.tintColor = colors.mainGreenColor
        
        let clockIcon = try! FAKFontAwesome(identifier: "fa-clock-o", size: 22)
        let clockImage = clockIcon.imageWithSize(CGSize(width: 32, height: 32))
        self.clockButton.setImage(clockImage, forState: .Normal)
        self.clockButton.tintColor = colors.secondaryTextColor
        
        let systemIcon = FAKFontAwesome.archiveIconWithSize(20)
        systemIcon.addAttribute(NSForegroundColorAttributeName, value: colors.mainGreenColor)
        let systemImage = systemIcon.imageWithSize(CGSize(width: 32, height: 32))
        self.systemButton.setImage(systemImage, forState: .Normal)
    }
    
    private func initializeControl() {
        self.cardView.addShadow()
        
        self.titleCardView.layer.cornerRadius = 6.0
        self.titleCardView.addSmallShadow()
        
        self.priorityCardView.layer.cornerRadius = 6.0
        self.priorityCardView.addSmallShadow()
        
        self.dateToolView.hidden = true
        self.datePicker.hidden = true
        self.datePicker.datePickerMode = .Date
        self.datePicker.minimumDate = NSDate()
        
        self.titleTextField.placeholder = Localized("goingDo")
        self.cancelButton.setTitle(Localized("cancel"), forState: .Normal)
        
        self.cancelDateButton.setTitle(Localized("removeDate"), forState: .Normal)
        self.setDateButton.setTitle(Localized("setCreateDate"), forState: .Normal)
        self.saveButton.setTitle(Localized("save"), forState: .Normal)
        
        self.priorityLabel.text = Localized("priority")
        
        self.prioritySegmental.selectedSegmentIndex = 1
        self.prioritySegmental.setTitle(Localized("low"), forSegmentAtIndex: 0)
        self.prioritySegmental.setTitle(Localized("normal"), forSegmentAtIndex: 1)
        self.prioritySegmental.setTitle(Localized("high"), forSegmentAtIndex: 2)
        
        self.cancelButton.addTarget(self, action: #selector(self.cancelAction), forControlEvents: .TouchUpInside)
        self.clockButton.addTarget(self, action: #selector(self.scheduleAction), forControlEvents: .TouchUpInside)
        self.systemButton.addTarget(self, action: #selector(self.systemAction), forControlEvents: .TouchUpInside)
        self.saveButton.addTarget(self, action: #selector(self.saveAction), forControlEvents: .TouchUpInside)
        
        self.cancelDateButton.addTarget(self, action: #selector(self.cancelScheduleAction), forControlEvents: .TouchUpInside)
        self.setDateButton.addTarget(self, action: #selector(self.saveScheduleAction), forControlEvents: .TouchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dissmiss(_:)))
        self.view.addGestureRecognizer(tap)
    }
    
    // MARK: - actions
    private func keyboardAction() {
        KeyboardManager.sharedManager.keyboardShowHandler = { [unowned self] in
            self.cardViewTopConstraint.constant =
                (self.view.frame.height - KeyboardManager.keyboardHeight - self.cardViewHeight) * 0.5
            self.datePickerHeightConstraint.constant = KeyboardManager.keyboardHeight
            
            UIView.animateWithDuration(kNormalAnimationDuration, delay: kKeyboardAnimationDelay, usingSpringWithDamping: 0.7, initialSpringVelocity: 10, options: .TransitionNone, animations: { [unowned self] in
                self.view.layoutIfNeeded()
            }) { [unowned self] (finish) in
                self.toolViewBottomConstraint.constant = KeyboardManager.keyboardHeight
                self.toolView.alpha = 1
                UIView.animateWithDuration(0.25, animations: { [unowned self] in
                    self.toolView.layoutIfNeeded()
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
    
    func scheduleAction() {
        KeyboardManager.sharedManager.closeNotification()
        self.titleTextField.resignFirstResponder()
        
        self.dateToolView.hidden = false
        self.datePicker.hidden = false
    }
    
    func cancelScheduleAction() {
        self.datePicker.hidden = true
        self.dateToolView.hidden = true
        self.titleTextField.becomeFirstResponder()
        
        self.keyboardAction()
    }
    
    func saveScheduleAction() {
        let selectedDate = self.datePicker.date
        task.createdDate = selectedDate
        
        self.clockButton.tintColor = Colors().mainGreenColor
        cancelScheduleAction()
    }
    
    func systemAction() {
        let systemVC = SystemTaskViewController()
        let nav = UINavigationController(rootViewController: systemVC)
        nav.view.backgroundColor = Colors().mainGreenColor
        nav.navigationBarHidden = true
        systemVC.newTaskDelegate = self
        self.parentViewController?.presentViewController(nav, animated: true, completion: { })
    }
    
    // MARK: - logic
    func saveNewTask(taskToDo: String) {
        guard taskToDo.characters.count > 0 else {
            return
        }
        let priority = prioritySegmental.selectedSegmentIndex
        task.createDefaultTask(taskToDo, priority:  priority)
        
        saveSubtasks()
        RealmManager.shareManager.writeObject(task)
        
        self.cancelAction()
    }
    
    private func saveSubtasks() {
        guard let subtaskString = self.subtaskString else { return }
        let subTasks = subtaskString.componentsSeparatedByString("\n")
        task.subTaskCount = subTasks.count
        let now = NSDate()
        task.createdDate = now
        let taskUUID = now.createTaskUUID()
        
        let tasks = subTasks.enumerate().flatMap({ (index: Int, sub: String) -> Subtask? in
            guard sub.characters.count > 0 else { return nil }
            let subtask = Subtask()
            subtask.rootUUID = taskUUID
            let createdDate = now.dateByAddingSeconds(index)
            subtask.createdDate = createdDate
            subtask.taskToDo = sub
            subtask.uuid = createdDate.createTaskUUID()
            return subtask
            
        })
        RealmManager.shareManager.writeObjects(tasks)
    }
    
    // MARK: - textfield
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        guard let text = textField.text else {
            return true
        }
        
        saveNewTask(text)
        return true
    }
    
    func dissmiss(tap: UITapGestureRecognizer) {
        if (!CGRectContainsPoint(self.cardView.frame, tap.locationInView(self.view))
            && !CGRectContainsPoint(self.toolView.frame, tap.locationInView(self.view))) {
            self.removeFromParentViewController()
        }
    }
    
    @IBOutlet weak var cardViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var toolViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var datePickerHeightConstraint: NSLayoutConstraint!
}

// MARK: - parent view controller
extension NewTaskViewController {
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        guard let p = parent else {
            return
        }
        let image = p.view.convertViewToImage()
        
        let filter = GPUImageiOSBlurFilter()
        let imagePicture = GPUImagePicture(image: image)
        imagePicture.addTarget(filter)
        filter.blurRadiusInPixels = 0.5
        filter.useNextFrameForImageCapture()
        imagePicture.processImage()
        
        self.view.frame = p.view.frame
        p.view.addSubview(self.view)
        
        self.cardViewTopConstraint.constant = (p.view.frame.height - cardViewHeight) * 0.5
        self.renderImageView.image = filter.imageFromCurrentFramebuffer()
        
        self.configMainUI()
        self.initializeControl()
    }
    
    override func didMoveToParentViewController(parent: UIViewController?) {
        super.didMoveToParentViewController(parent)
        
        guard let _ = parent else {
            return
        }
        
        self.renderImageView.alpha = 0
        self.cardView.alpha = 0
        self.cardView.layer.cornerRadius = kCardViewCornerRadius
        
        UIView.animateWithDuration(kNormalAnimationDuration, animations: { [unowned self] in
            self.renderImageView.alpha = 1
            self.cardView.alpha = 1
        }) { (finish) in
            self.titleTextField.becomeFirstResponder()
        }
    }
    
    override func removeFromParentViewController() {
        self.titleTextField.resignFirstResponder()
        self.toolView.hidden = true
        UIView.animateWithDuration(kNormalAnimationDuration, animations: { [unowned self] in
            self.view.alpha = 0
        }) { [unowned self] (finish) in
            self.view.removeFromSuperview()
        }
    }
}

extension NewTaskViewController: NewTaskDataDelegate {
    // MARK: - NewTaskDateDelegate
    
    func notifyTaskDate(date: NSDate) {
        task.notifyDate = date
    }
    
    func toDoForSystemTask(text: NSAttributedString, task: Task) {
        self.titleTextField.attributedText = text
        self.titleTextField.enabled = false
        self.systemButton.hidden = true
        self.saveButton.hidden = false
        
        self.task.taskToDo = task.taskToDo
        self.task.taskType = task.taskType
        self.task.createdDate = task.createdDate
        self.task.subTaskCount = task.subTaskCount
        
        self.toolViewBottomConstraint.constant = 0
        self.cardViewTopConstraint.constant = (self.view.frame.height - self.cardViewHeight) * 0.5
    }
    
    func toDoForSystemSubtask(text: NSAttributedString, task: Task, subtasks: String) {
        self.toDoForSystemTask(text, task: task)
        self.subtaskString = subtasks
    }
}


protocol NewTaskDataDelegate: NSObjectProtocol {
    func notifyTaskDate(date: NSDate)
    // 设置当前的 text 和 taskToDoTask
    func toDoForSystemTask(text: NSAttributedString, task: Task)
    func toDoForSystemSubtask(text: NSAttributedString, task: Task, subtasks: String)
}
