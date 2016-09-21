//
//  BaseCardViewController.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/27.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

// key value type system action
class KVTaskViewController: BaseViewController {
    
    var actionType: SystemActionType
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var titleCardView: UIView!
    
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var placeholderLabel: UILabel!
    
    @IBOutlet weak var toolView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var toolViewBottomConstraint: NSLayoutConstraint!
    
    weak var delegate: TaskActionDataDelegate? = nil
    
    init(actionType: SystemActionType, delegate: TaskActionDataDelegate) {
        self.actionType = actionType
        self.delegate = delegate
        super.init(nibName: "KVTaskViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.actionType = SystemActionType.none
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
        
        KeyboardManager.sharedManager.setShowHander { [unowned self] in
            self.toolViewBottomConstraint.constant = KeyboardManager.keyboardHeight
            
            UIView.animate(withDuration: KeyboardManager.duration, delay: kKeyboardAnimationDelay, options: UIViewAnimationOptions(), animations: { [unowned self] in
                self.view.layoutIfNeeded()
                }, completion: nil)
        }
        
        self.titleTextField.becomeFirstResponder()
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
        
        self.titleLabel.textColor = colors.cloudColor
        
        self.toolView.addTopShadow()
        self.toolView.backgroundColor = colors.cloudColor
        self.cardView.backgroundColor = colors.cloudColor
        self.view.backgroundColor = colors.mainGreenColor
        
        self.lineView.backgroundColor = colors.cloudColor
        self.titleTextField.tintColor = colors.mainGreenColor
        self.titleTextField.textColor = colors.mainTextColor
        self.contentTextView.tintColor = colors.mainGreenColor
        self.contentTextView.textColor = colors.mainTextColor
        self.placeholderLabel.textColor = colors.placeHolderTextColor
        
        self.cancelButton.tintColor = colors.mainGreenColor
        self.saveButton.tintColor = colors.mainGreenColor
    }
    
    fileprivate func initializeControl() {
        self.cardView.addShadow()
        self.cardView.layer.cornerRadius = kCardViewCornerRadius
        
        self.titleLabel.text = Localized(actionType.ationNameWithType())
        if let hint = actionType.hintNameWithType() {
            self.titleTextField.placeholder = Localized(hint.0)
            self.placeholderLabel.text = Localized(hint.1)
        }
        
        self.titleCardView.layer.cornerRadius = 6.0
        self.titleCardView.addSmallShadow()
        
        self.cancelButton.setTitle(Localized("cancel"), for: .normal)
        self.cancelButton.addTarget(self, action: #selector(self.cancelAction), for: .touchUpInside)
        
        self.saveButton.setTitle(Localized("add"), for: .normal)
        self.saveButton.addTarget(self, action: #selector(self.saveAction), for: .touchUpInside)
    }
    
    // MARK: - action
    func cancelAction() {
        self.toolView.isHidden = true
        
        guard let nav = self.navigationController else {
            return
        }
        nav.popViewController(animated: true)
    }
    
    func saveAction() {
        guard let title = self.titleTextField.text,
            let content = self.contentTextView.text else { return }
        if title.characters.count > 0 && content.characters.count > 0 {
            self.view.endEditing(true)
            dispatch_delay(0.25, closure: { [unowned self] in
                self.delegate?.actionData(title, info: content)
                guard let nav = self.navigationController else {
                    return
                }
                nav.popViewController(animated: true)
                })
        } else {
            HUD.sharedHUD.error(Localized("errorInfos"))
        }
    }
}

extension KVTaskViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        self.placeholderLabel.isHidden = range.location + text.characters.count > 0
        return true
    }
}

extension KVTaskViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.contentTextView.becomeFirstResponder()
        return false
    }
}
