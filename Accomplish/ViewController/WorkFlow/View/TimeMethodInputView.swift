//
//  TimeMethodInputView.swift
//  Accomplish
//
//  Created by zhoubo on 16/11/26.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class TimeMethodInputView: UIView {
    typealias SaveBlock = (_ first: String, _ second: String) -> Void
    
    @IBOutlet weak var realShadowView: UIView!
    @IBOutlet weak var cardHolderView: UIView!
    @IBOutlet weak var cardHolderViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var firstInputTitleLabel: UILabel!
    @IBOutlet weak var firstTextField: UITextField!
    @IBOutlet weak var secondInputTitleLabel: UILabel!
    @IBOutlet weak var secondTextField: UITextField!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    fileprivate let viewHeight: CGFloat = 167
    fileprivate let shadowAlpha: CGFloat = 0.85

    class func loadNib(_ target: AnyObject) -> TimeMethodInputView? {
        guard let view =
            Bundle.main.loadNibNamed("TimeMethodInputView", owner: target, options: nil)?
                .first as? TimeMethodInputView else {
                    return nil
        }
        
        let colors = Colors()
        
        view.cardHolderView.backgroundColor = colors.cloudColor
        view.cardHolderView.layer.cornerRadius = kCardViewCornerRadius
        
        view.firstInputTitleLabel.textColor = colors.secondaryTextColor
        view.secondInputTitleLabel.textColor = colors.secondaryTextColor
        
        view.leftButton.tintColor = colors.mainGreenColor
        view.leftButton.setTitle(Localized("cancel"), for: .normal)
        view.leftButton.addTarget(view, action: #selector(view.moveOut), for: .touchUpInside)
        
        view.rightButton.tintColor = colors.mainGreenColor
        view.rightButton.setTitle(Localized("save"), for: .normal)
        
        view.firstTextField.delegate = view
        view.firstTextField.tintColor = colors.mainGreenColor
        view.secondTextField.delegate = view
        view.secondTextField.tintColor = colors.mainGreenColor
        
        view.cardHolderViewTopConstraint.constant = -view.viewHeight
        view.isHidden = true
        
        return view
    }
    
    func moveIn(twoTitles: [String], twoHolders: [String]?,
                twoContent: [String], saveBlock: SaveBlock) {
        self.firstInputTitleLabel.text = twoTitles.first
        self.secondInputTitleLabel.text = twoTitles.last
        self.firstTextField.text = twoContent.first
        self.secondTextField.text = twoContent.last
        
        if let horders = twoHolders {
            self.firstTextField.placeholder = horders.first
            self.secondTextField.placeholder = horders.last
        }
        
        self.isHidden = false
        self.firstTextField.becomeFirstResponder()
        
        self.cardHolderViewTopConstraint.constant = 64
        UIView.animate(withDuration: kNormalAnimationDuration, delay: kSmallAnimationDuration, usingSpringWithDamping: self.shadowAlpha, initialSpringVelocity: 0.1, options: UIViewAnimationOptions(), animations: { [unowned self] in
            self.layoutIfNeeded()
            self.realShadowView.alpha = self.shadowAlpha
        })
    }
    
    func moveOut() {
        self.cardHolderViewTopConstraint.constant = -self.viewHeight
        
        UIView.animate(withDuration: kNormalAnimationDuration, delay: kSmallAnimationDuration, usingSpringWithDamping: 0.7, initialSpringVelocity: 10, options: UIViewAnimationOptions(), animations: { [unowned self] in
            self.layoutIfNeeded()
            self.realShadowView.alpha = 0
        }) { [unowned self] (finish) in
            self.isHidden = true
            self.firstTextField.text = nil
            self.secondTextField.text = nil
            self.endEditing(true)
        }
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
}
