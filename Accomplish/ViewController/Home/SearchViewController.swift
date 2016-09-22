//
//  SearchViewController.swift
//  Accomplish
//
//  Created by zhoubo on 2016/9/22.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class SearchViewController: BaseViewController {
    
    @IBOutlet weak var topHolderView: UIView!
    @IBOutlet weak var searchHolderView: UIView!
    @IBOutlet weak var searchIconLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.configMainUI()
        self.initializeControl()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.default
    }
    
    override func configMainUI() {
        let colors = Colors()
        
        self.view.backgroundColor = colors.mainGreenColor
        self.topHolderView.backgroundColor = colors.cloudColor
        self.topHolderView.layer.cornerRadius = kCardViewCornerRadius
        
        self.searchIconLabel
            .createIconText(iconSize: 20, icon: "fa-search", color: colors.cloudColor)
        
        self.searchHolderView.backgroundColor = UIColor(red:0.74, green:0.76, blue:0.78, alpha:1.00)
        
        self.backButton.buttonColor(colors)
        self.backButton.createIconButton(iconSize: kBackButtonCorner, imageSize: kBackButtonCorner,
                                         icon: backButtonIconString, color: colors.mainGreenColor,
                                         status: .normal)
    }
    
    fileprivate func initializeControl() {
        self.searchHolderView.layer.cornerRadius = 16
        self.backButton.addShadow()
        self.backButton.layer.cornerRadius = kBackButtonCorner
        self.backButton.addTarget(self, action: #selector(self.cancelAction), for: .touchUpInside)
        
        self.searchTextField.placeholder = Localized("searchHolder")
    }
    
    // MARK: - actions
    func cancelAction() {
        guard let nav = self.navigationController else {
            return
        }
        nav.popViewController(animated: true)
    }
    
}
