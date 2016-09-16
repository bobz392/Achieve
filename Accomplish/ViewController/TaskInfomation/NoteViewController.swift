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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        KeyboardManager.sharedManager.setHideHander { [unowned self] in
            self.toolViewBottomConstraint.constant = 0
            UIView.animate(withDuration: kNormalAnimationDuration, delay: kKeyboardAnimationDelay, options: UIViewAnimationOptions(), animations: { [unowned self] in
                self.view.layoutIfNeeded()
                }, completion: nil)
        }
        KeyboardManager.sharedManager.setShowHander { [unowned self] in
            self.toolViewBottomConstraint.constant = KeyboardManager.keyboardHeight
            
            UIView.animate(withDuration: kNormalAnimationDuration, delay: kKeyboardAnimationDelay, options: UIViewAnimationOptions(), animations: { [unowned self] in
                self.view.layoutIfNeeded()
                }, completion: nil)

        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        KeyboardManager.sharedManager.closeNotification()
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
    
    fileprivate func initializeControl() {
        self.cardView.addShadow()
        self.cardView.layer.cornerRadius = kCardViewCornerRadius
        
        self.titleCardView.layer.cornerRadius = 6.0
        self.titleCardView.addSmallShadow()
        
        self.cancelButton.setTitle(Localized("cancel"), for: .normal)
        self.cancelButton.addTarget(self, action: #selector(self.cancelAction), for: .touchUpInside)
        
        self.saveButton.setTitle(Localized("save"), for: .normal)
        self.saveButton.addTarget(self, action: #selector(self.saveAction), for: .touchUpInside)
        
        if !self.task.taskNote.isEmpty {
            self.contentTextView.text = self.task.taskNote
        }
        self.placeholderLabel.isHidden = !self.task.taskNote.isEmpty
        self.titleLabel.text = self.task.getNormalDisplayTitle()
        self.placeholderLabel.text = Localized("writeNote")
    }
    
    // MARK: - action
    func cancelAction() {
        guard let nav = self.navigationController else {
            return
        }
        nav.popViewController(animated: true)
    }
    
    func saveAction() {
        guard let content = self.contentTextView.text else { return }
        if content.characters.count > 0 {
            self.noteDelegate?.taskNoteAdd(content)
            guard let nav = self.navigationController else {
                return
            }
            nav.popViewController(animated: true)
        } else {
            HUD.sharedHUD.error(Localized("errorInfos"))
        }
    }
}

extension NoteViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        self.placeholderLabel.isHidden = range.location + text.characters.count > 0
        return true
    }
}
