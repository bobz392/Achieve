//
//  TimeMethodInputView.swift
//  Accomplish
//
//  Created by zhoubo on 16/11/26.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class TimeMethodInputView: UIView {
    typealias SaveBlock = (_ first: String, _ second: String?) -> Void
    typealias FinishBlock = () -> Void
    
    @IBOutlet weak var blurImageView: UIImageView!
    @IBOutlet weak var cardHolderView: UIView!
    @IBOutlet weak var cardHolderViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var firstInputTitleLabel: UILabel!
    @IBOutlet weak var firstTextField: UITextField!
    @IBOutlet weak var secondInputTitleLabel: UILabel!
    @IBOutlet weak var secondTextField: UITextField!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    fileprivate let viewHeight: CGFloat = 167
    fileprivate let shadowAlpha: CGFloat = 0.8
    fileprivate var saveBlock: SaveBlock? = nil
    fileprivate var finishBlock: FinishBlock? = nil
    
    weak var moveInView: UIView? = nil
    
    class func loadNib(_ target: Any) -> TimeMethodInputView? {
        guard let view =
            Bundle.main.loadNibNamed("TimeMethodInputView", owner: target, options: nil)?
                .first as? TimeMethodInputView else {
                    return nil
        }
        view.cardHolderView.backgroundColor = Colors.cellCardColor
        view.cardHolderView.layer.cornerRadius = kCardViewCornerRadius
        view.cardHolderView.addShadow()
        
        view.firstInputTitleLabel.textColor = Colors.secondaryTextColor
        view.secondInputTitleLabel.textColor = Colors.secondaryTextColor
        
        view.leftButton.tintColor = Colors.cellLabelSelectedTextColor
        view.leftButton.setTitle(Localized("cancel"), for: .normal)
        view.leftButton.addTarget(view, action: #selector(view.moveOut), for: .touchUpInside)
        
        view.rightButton.tintColor = Colors.cellLabelSelectedTextColor
        view.rightButton.setTitle(Localized("save"), for: .normal)
        view.rightButton.addTarget(view, action: #selector(view.saveAction), for: .touchUpInside)
        
        view.firstTextField.delegate = view
        view.secondTextField.delegate = view
        
        view.cardHolderViewTopConstraint.constant = -view.viewHeight
        
        let swipe = UISwipeGestureRecognizer(target: view, action: #selector(blockGecognizer))
        view.addGestureRecognizer(swipe)
        let pan = UIPanGestureRecognizer(target: view, action: #selector(blockGecognizer))
        view.addGestureRecognizer(pan)
        let edgepan = UIScreenEdgePanGestureRecognizer(target: view, action: #selector(blockGecognizer))
        view.addGestureRecognizer(edgepan)
        
        return view
    }
    
    func blockGecognizer() {
        //do nothing
    }
    
    @discardableResult
    func setMoveInView(moveInView: UIView) -> TimeMethodInputView {
        self.moveInView = moveInView
        return self
    }
    
    @discardableResult
    func setTitles(first: String, second: String) -> TimeMethodInputView {
        self.firstInputTitleLabel.text = first
        self.secondInputTitleLabel.text = second
        return self
    }
    
    @discardableResult
    func setPlaceHolders(first: String, second: String) -> TimeMethodInputView {
        self.firstTextField.placeholder = first
        self.secondTextField.placeholder = second
        return self
    }
    
    @discardableResult
    func setContent(first: String, second: String) -> TimeMethodInputView {
        self.firstTextField.text = first
        self.secondTextField.text = second
        return self
    }
    
    @discardableResult
    func setSaveBlock(saveBlock: @escaping SaveBlock) -> TimeMethodInputView {
        self.saveBlock = saveBlock
        return self
    }
    
    @discardableResult
    func setFinishBlock(finishBlock: @escaping FinishBlock) -> TimeMethodInputView {
        self.finishBlock = finishBlock
        return self
    }
    
    @discardableResult
    func setSecondKeyboardType(keyboardType: UIKeyboardType = .default) -> TimeMethodInputView {
        self.secondTextField.keyboardType = keyboardType
        return self
    }

    
    func moveIn() {
        guard let view = self.moveInView else { fatalError("not set move in view yet")}
        // 进来的时候先隐藏
        let image = view.convertViewToImage()
        self.blurImageView.image =
            image.blurredImage(5, iterations: 3, ratio: 2.0, blendColor: nil, blendMode: .clear)
        self.blurImageView.alpha = 0
        self.cardHolderView.alpha = 0.5
        self.frame = view.bounds
        view.addSubview(self)
        self.layoutIfNeeded()
        
        // 有可能第一个输入框的状态是被禁止的 那么则响应第二个输入框的键盘
        if self.firstTextField.isUserInteractionEnabled == false {
            self.secondTextField.becomeFirstResponder()
        } else {
            self.firstTextField.becomeFirstResponder()
        }
        
        self.cardHolderViewTopConstraint.constant = 64
        UIView.animate(withDuration: kNormalAnimationDuration, delay: 0, options: .curveEaseInOut, animations: { [unowned self] in
            self.blurImageView.alpha = 1
            self.cardHolderView.alpha = 1
            self.layoutIfNeeded()
        }, completion: nil)
    }
    
    func moveOut() {
        self.cardHolderViewTopConstraint.constant = -self.viewHeight
        self.leftButton.isEnabled = true
        self.finishBlock?()
        self.endEditing(true)
        
        UIView.animate(withDuration: kNormalAnimationDuration, delay: 0, options: .curveEaseInOut, animations: { [unowned self] in
            self.cardHolderView.alpha = 0.5
            self.blurImageView.alpha = 0
            self.layoutIfNeeded()
        }) { [unowned self] (finish) in
            self.firstTextField.text = nil
            self.saveBlock = nil
            self.secondTextField.text = nil
            self.removeFromSuperview()
        }
    }
    
    func saveAction() {
        guard let first = self.firstTextField.text else {
            HUD.shared.error(Localized("please") + (self.firstTextField.placeholder ?? ""))
            return
        }
        
        let tr = first.trim()
        if tr.length() <= 0 {
            HUD.shared.error(Localized("please") + (self.firstTextField.placeholder ?? ""))
            return
        }
        
        if self.secondTextField.keyboardType == .numberPad {
            guard let _ = Int(self.secondTextField.text ?? "") else {
                HUD.shared.error(Localized("please") + (self.secondTextField.placeholder ?? ""))
                return
            }
        }
        
        self.saveBlock?(tr, self.secondTextField.text)
        self.moveOut()
    }
   
}

extension TimeMethodInputView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.firstTextField {
            return self.secondTextField.becomeFirstResponder()
        } else {
            return true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.attributedText =  textField.text?.fixTextFieldBugString(fontSize: 14, color: Colors.mainTextColor)
    }
}
