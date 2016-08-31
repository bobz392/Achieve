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
        self.actionType = SystemActionType.None
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        configMainUI()
        initializeControl()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        KeyboardManager.sharedManager.keyboardShowHandler = { [unowned self] in
            KeyboardManager.sharedManager.closeNotification()
            self.toolViewBottomConstraint.constant = KeyboardManager.keyboardHeight
            
            UIView.animateWithDuration(KeyboardManager.duration, delay: kKeyboardAnimationDelay, options: .CurveEaseInOut, animations: { [unowned self] in
                self.view.layoutIfNeeded()
                }, completion: nil)
        }
        
        self.titleTextField.becomeFirstResponder()
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
    
    private func initializeControl() {
        self.cardView.addShadow()
        self.cardView.layer.cornerRadius = kCardViewCornerRadius
        
        self.titleLabel.text = Localized(actionType.ationNameWithType())
        if let hint = actionType.hintNameWithType() {
            self.titleTextField.placeholder = Localized(hint.0)
            self.placeholderLabel.text = Localized(hint.1)
        }
        
        self.titleCardView.layer.cornerRadius = 6.0
        self.titleCardView.addSmallShadow()
        
        self.cancelButton.setTitle(Localized("cancel"), forState: .Normal)
        self.cancelButton.addTarget(self, action: #selector(self.cancelAction), forControlEvents: .TouchUpInside)
        
        self.saveButton.setTitle(Localized("save"), forState: .Normal)
        self.saveButton.addTarget(self, action: #selector(self.saveAction), forControlEvents: .TouchUpInside)
    }
    
    // MARK: - action
    func cancelAction() {
        self.toolView.hidden = true
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func saveAction() {
        guard let title = self.titleTextField.text,
            let content = self.contentTextView.text else { return }
        if title.characters.count > 0 && content.characters.count > 0 {
            self.view.endEditing(true)
            dispatch_delay(0.25, closure: { [unowned self] in
                self.delegate?.actionData(title, info: content)
                self.navigationController?.popViewControllerAnimated(true)
                })
        } else {
            //            SVProgressHUD.showErrorWithStatus(Localized("errorInfos"))
            HUD.sharedHUD.showHUD(self.view)
        }
    }
}

extension KVTaskViewController: UITextViewDelegate {
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        self.placeholderLabel.hidden = range.location + text.characters.count > 0
        return true
    }
}

extension KVTaskViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.contentTextView.becomeFirstResponder()
        return false
    }
}
