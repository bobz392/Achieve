//
//  NoteViewController.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/31.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class NoteViewController: BaseViewController {
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var titleCardView: UIView!
    
    @IBOutlet weak var toolView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var toolViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var placeholderLabel: UILabel!
    
    var task: Task
    var noteDelegate: TaskNoteDataDelegate?
    
    init(task: Task, noteDelegate: TaskNoteDataDelegate?) {
        self.task = task
        self.noteDelegate = noteDelegate
        super.init(nibName: "NoteViewController", bundle: nil)
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
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        KeyboardManager.sharedManager.keyboardShowHandler = { [unowned self] in
            KeyboardManager.sharedManager.closeNotification()
            self.toolViewBottomConstraint.constant = KeyboardManager.keyboardHeight
            
            UIView.animateWithDuration(kNormalAnimationDuration, delay: kKeyboardAnimationDelay, options: .CurveEaseInOut, animations: { [unowned self] in
                self.view.layoutIfNeeded()
                }, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func configMainUI() {
        let colors = Colors()
        
        self.toolView.addTopShadow()
        self.toolView.backgroundColor = colors.cloudColor
        self.cardView.backgroundColor = colors.cloudColor
        self.view.backgroundColor = colors.mainGreenColor
        self.titleLabel.textColor = colors.mainTextColor
        
        self.contentTextView.tintColor = colors.mainGreenColor
        self.contentTextView.textColor = colors.mainTextColor
        self.placeholderLabel.textColor = colors.placeHolderTextColor
        
        self.cancelButton.tintColor = colors.mainGreenColor
        self.saveButton.tintColor = colors.mainGreenColor
    }
    
    private func initializeControl() {
        self.cardView.addShadow()
        self.cardView.layer.cornerRadius = kCardViewCornerRadius
        
        self.titleCardView.layer.cornerRadius = 6.0
        self.titleCardView.addSmallShadow()
        
        self.cancelButton.setTitle(Localized("cancel"), forState: .Normal)
        self.cancelButton.addTarget(self, action: #selector(self.cancelAction), forControlEvents: .TouchUpInside)
        
        self.saveButton.setTitle(Localized("save"), forState: .Normal)
        self.saveButton.addTarget(self, action: #selector(self.saveAction), forControlEvents: .TouchUpInside)
        
        if !self.task.taskNote.isEmpty {
            self.contentTextView.text = self.task.taskNote
        }
        self.placeholderLabel.hidden = !self.task.taskNote.isEmpty
        self.titleLabel.text = self.task.getNormalDisplayTitle()
        self.placeholderLabel.text = Localized("writeNote")
    }
    
    // MARK: - action
    func cancelAction() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func saveAction() {
        guard let content = self.contentTextView.text else { return }
        if content.characters.count > 0 {
            self.noteDelegate?.taskNoteAdd(content)
            self.navigationController?.popViewControllerAnimated(true)
        } else {
            HUD.sharedHUD.error(Localized("errorInfos"))
        }
    }
}

extension NoteViewController: UITextViewDelegate {
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        self.placeholderLabel.hidden = range.location + text.characters.count > 0
        return true
    }
}
