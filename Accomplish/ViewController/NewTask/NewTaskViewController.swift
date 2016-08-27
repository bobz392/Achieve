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
    
    private let cardViewHeight: CGFloat = 194
    
    private let task = Task()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if (toolView.alpha == 1) {
            titleTextField.becomeFirstResponder()
        }
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
        self.cancelButton.tintColor = colors.mainGreenColor
        self.saveButton.tintColor = colors.mainGreenColor
        
        let clockIcon = FAKFontAwesome.clockOIconWithSize(22)
        clockIcon.addAttribute(NSForegroundColorAttributeName, value: colors.mainGreenColor)
        let clockImage = clockIcon.imageWithSize(CGSize(width: 32, height: 32))
        self.clockButton.setImage(clockImage, forState: .Normal)
        
        let systemIcon = FAKFontAwesome.archiveIconWithSize(20)
        systemIcon.addAttribute(NSForegroundColorAttributeName, value: colors.mainGreenColor)
        let systemImage = systemIcon.imageWithSize(CGSize(width: 32, height: 32))
        self.systemButton.setImage(systemImage, forState: .Normal)
    }
    
    private func initializeControl() {
        self.cardView.addShadow()
        
        self.priorityCardView.layer.cornerRadius = 6.0
        self.priorityCardView.layer.borderColor = UIColor(red:0.78, green:0.78, blue:0.78, alpha:1.00).CGColor
        self.priorityCardView.layer.borderWidth = 0.5
        
        self.titleTextField.placeholder = Localized("goingDo")
        self.cancelButton.setTitle(Localized("cancel"), forState: .Normal)
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
        
        self.keyboardAction()
    }
    
    // MARK: - actions
    private func keyboardAction() {
        KeyboardManager.sharedManager.keyboardShowHandler = { [unowned self] in
            KeyboardManager.sharedManager.keyboardShowHandler = nil
            self.cardViewTopConstraint.constant =
                (self.view.frame.height - KeyboardManager.keyboardHeight - self.cardViewHeight) * 0.5
            
            UIView.animateWithDuration(kNormalAnimationDuration, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 10, options: .TransitionNone, animations: { [unowned self] in
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
        let scheduleVC = ScheduleViewController()
        scheduleVC.taskDateDelegate = self
        self.parentViewController?.presentViewController(scheduleVC, animated: true, completion: {
            
        })
    }
    
    func systemAction() {
        let systemVC = SystemTaskViewController()
        let nav = UINavigationController(rootViewController: systemVC)
        nav.view.backgroundColor = Colors().mainGreenColor
        nav.navigationBarHidden = true
        systemVC.newTaskDelegate = self
        self.parentViewController?.presentViewController(nav, animated: true, completion: {
            
        })
    }
    
    // MARK: - logic
    func saveNewTask(taskToDo: String) {
        let priority = prioritySegmental.selectedSegmentIndex
        task.createDefaultTask(taskToDo, priority:  priority)
        
        RealmManager.shareManager.createTask(task)
        self.cancelAction()
    }
    
    // MARK: - textfield
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        guard let title = textField.text else {
            return true
        }
        
        saveNewTask(title)
        return true
    }
    
    @IBOutlet weak var cardViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var toolViewBottomConstraint: NSLayoutConstraint!
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
        UIView.animateWithDuration(kNormalAnimationDuration, animations: { [unowned self] in
            self.renderImageView.alpha = 0
            self.cardView.alpha = 0
        }) { [unowned self] (finish) in
            self.titleTextField.resignFirstResponder()
            self.view.removeFromSuperview()
        }
    }
}

extension NewTaskViewController: NewTaskDataDelegate {
    // MARK: - NewTaskDateDelegate
    
    func notifyTaskDate(date: NSDate) {
        task.notifyDate = date
    }
    
    func toDoForSystemTask(text: NSAttributedString, taskToDoText: String) {
        self.titleTextField.attributedText = text
        self.titleTextField.enabled = false
        self.systemButton.hidden = true
        
        self.task.taskToDo = taskToDoText
        self.task.taskType = kSystemTaskType
        
        self.toolViewBottomConstraint.constant = 0
        self.cardViewTopConstraint.constant = (self.view.frame.height - self.cardViewHeight) * 0.5
        
        self.saveButton.hidden = false
    }
}


protocol NewTaskDataDelegate: NSObjectProtocol {
    func notifyTaskDate(date: NSDate)
    func toDoForSystemTask(text: NSAttributedString, taskToDoText: String)
}
