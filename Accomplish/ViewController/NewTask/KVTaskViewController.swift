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

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cardView: UIView!
    
    @IBOutlet weak var titleCardView: UIView!
    
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    
    @IBOutlet weak var toolView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var toolViewBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configMainUI()
        initControl()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func configMainUI() {
        let colors = Colors()
        
        self.titleLabel.textColor = colors.cloudColor
        
        self.cardView.backgroundColor = colors.cloudColor
        self.view.backgroundColor = colors.mainGreenColor
        
        lineView.backgroundColor = colors.cloudColor
        titleTextField.tintColor = colors.mainGreenColor
        titleTextField.textColor = colors.mainTextColor
    }
    
    private func initControl() {
        self.cardView.addShadow()
        self.cardView.layer.cornerRadius = kCardViewCornerRadius
        
        self.titleLabel.text = Localized("selectAction")
        
        self.titleCardView.layer.cornerRadius = 6.0
        self.titleCardView.addSmallShadow()
    }

    // MARK: - action
    func cancelAction() {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
