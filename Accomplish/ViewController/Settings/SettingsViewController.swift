//
//  SettingsViewController.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/9.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class SettingsViewController: BaseViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var settingTableView: UITableView!
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
    
    override func configMainUI() {
        let colors = Colors()
        
        self.titleLabel.textColor = colors.cloudColor
        
        self.settingTableView.clearView()
        self.cardView.backgroundColor = colors.cloudColor
        self.view.backgroundColor = colors.mainGreenColor
        
        self.backButton.buttonColor(colors)
        let cancelIcon = FAKFontAwesome.arrowLeftIconWithSize(kBackButtonCorner)
        cancelIcon.addAttribute(NSForegroundColorAttributeName, value: colors.mainGreenColor)
        self.backButton.setAttributedTitle(cancelIcon.attributedString(), forState: .Normal)
    }
    
    private func initializeControl() {
        self.backButton.addShadow()
        self.backButton.layer.cornerRadius = kBackButtonCorner
        self.backButton.addTarget(self, action: #selector(self.cancelAction), forControlEvents: .TouchUpInside)
        
        self.cardView.addShadow()
        self.cardView.layer.cornerRadius = kCardViewCornerRadius
        
        self.titleLabel.text = Localized("setting")
    }
    
    // MARK: - actions
    func cancelAction() {
        self.navigationController?.popViewControllerAnimated(true)
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
