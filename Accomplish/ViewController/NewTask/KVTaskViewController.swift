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
    
    fileprivate let addButton = UIButton(type: .custom)
    fileprivate let nameTextField = UITextField()
    fileprivate let contentTextView = UITextView()
    fileprivate let contentTextPlaceHolderLabel = UILabel()
    
    weak var delegate: TaskActionDataDelegate? = nil
    
    init(actionType: SystemActionType, delegate: TaskActionDataDelegate) {
        self.actionType = actionType
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.actionType = SystemActionType.none
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configMainUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.nameTextField.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func configMainUI() {
        self.view.backgroundColor = Colors.mainBackgroundColor
        
        
        let bar = self.createCustomBar(height: kBarHeight, withBottomLine: false)
        let backButton = self.createLeftBarButton(icon: Icons.back)
        backButton.addTarget(self, action: #selector(self.backAction), for: .touchUpInside)
        let title = self.actionType.actionPresent().presentTitle()
        let titleLabel = self.createTitleLabel(titleText: title, style: .left)
        titleLabel.textColor = Colors.mainIconColor
        
        self.addButton.setImage(Icons.save.iconImage(), for: .normal)
        self.addButton.tintColor = Colors.mainIconColor
        self.addButton.addTarget(self, action: #selector(self.saveAction), for: .touchUpInside)
        bar.addSubview(self.addButton)
        self.addButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(backButton)
            make.right.equalToSuperview().offset(-12)
            make.height.equalTo(kBarIconSize)
            make.width.equalTo(kBarIconSize)
        }
        
        let paparView = UIView()
        paparView.backgroundColor = Colors.cellCardColor
        self.view.addSubview(paparView)
        paparView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(bar.snp.bottom).offset(4)
            make.bottom.equalToSuperview().offset(-25)
        }
        
        paparView.addSubview(self.nameTextField)
        self.nameTextField.backgroundColor = Colors.cellCardColor
        self.nameTextField.font = appFont(size: 16)
        self.nameTextField.textColor = Colors.mainTextColor
        self.nameTextField.delegate = self
        self.nameTextField.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.top.equalToSuperview()
            make.height.equalTo(44)
        }
        
        let lineView = UIView()
        lineView.backgroundColor = Colors.separatorColor
        paparView.addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.height.equalTo(0.5)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.top.equalTo(self.nameTextField.snp.bottom)
        }
        
        paparView.addSubview(self.contentTextView)
        self.contentTextView.backgroundColor = Colors.cellCardColor
        self.contentTextView.font = appFont(size: 14)
        self.contentTextView.delegate = self
        self.contentTextView.tintColor = Colors.mainTextColor
        self.contentTextView.textColor = Colors.mainTextColor
        self.contentTextView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-5)
            make.top.equalTo(lineView.snp.bottom).offset(4)
            make.bottom.equalToSuperview()
        }
        
        self.view.addSubview(self.contentTextPlaceHolderLabel)
        self.contentTextPlaceHolderLabel.font = appFont(size: 14)
        self.contentTextPlaceHolderLabel.textColor = Colors.placeHolderTextColor
        self.contentTextPlaceHolderLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.nameTextField)
            make.right.equalTo(self.nameTextField)
            make.top.equalTo(contentTextView.snp.top).offset(8)
        }
        
        if let hint = self.actionType.hintNameWithType() {
            self.nameTextField.placeholder = Localized(hint.0)
            self.contentTextPlaceHolderLabel.text = Localized(hint.1)
        }
        
        self.view.layoutIfNeeded()
        paparView.addRoundShadow()
    }
    
    // MARK: - action
    @objc func saveAction() {
        guard let name = self.nameTextField.text,
            let content = self.contentTextView.text,
            !name.isRealEmpty,
            !content.isRealEmpty else {
                HUD.shared.error(Localized("errorInfos"))
                return
        }
        
        self.view.endEditing(true)
        dispatch_delay(0.25, closure: { [unowned self] in
            self.delegate?.actionData(name, info: content)
            guard let nav = self.navigationController else { return }
            nav.popViewController(animated: true)
            })
    }
}

extension KVTaskViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        self.contentTextPlaceHolderLabel.isHidden = range.location + text.count > 0
        return true
    }
}

extension KVTaskViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.attributedText =  textField.text?.fixTextFieldBugString(fontSize: 16, color: Colors.mainTextColor)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.contentTextView.becomeFirstResponder()
        return false
    }
    
}
