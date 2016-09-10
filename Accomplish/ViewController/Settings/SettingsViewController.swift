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
    
    
    var titles = [[String]]()
    
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
        
        self.settingTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.settingDatas()
    }
    
    private func settingDatas() {
        let extras = [
            Localized("emailUs"),
            Localized("about"),
//            Localized("version"),
            Localized("writeReview")
        ]
        
        let general = [
            Localized("Theme"),
            Localized("enabDueNextDay"),
            Localized("hintClose")
        ]
        
        titles.append(general)
        titles.append(extras)
        
        self.settingTableView.reloadData()
    }
    
    // MARK: - actions
    func cancelAction() {
        self.navigationController?.popViewControllerAnimated(true)
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles[section].count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return titles.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        cell.textLabel?.text = titles[indexPath.section][indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "general"
        } else {
            return "extras"
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
}
