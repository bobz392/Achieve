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
    
    private var titles = [[String]]()
    private var icons = [[String]]()
    private var sizes = [[CGFloat]]()
    
    private var selectedIndex: NSIndexPath? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.configMainUI()
        self.initializeControl()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let s = selectedIndex else { return }
        self.settingTableView.deselectRowAtIndexPath(s, animated: true)
        self.selectedIndex = nil
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
        self.backButton.createIconButton(iconSize: kBackButtonCorner, imageSize: kBackButtonCorner,
                                         icon: backButtonIconString, color: colors.mainGreenColor,
                                         status: .Normal)
        
        self.settingTableView.separatorColor = colors.separatorColor
    }
    
    private func initializeControl() {
        self.backButton.addShadow()
        self.backButton.layer.cornerRadius = kBackButtonCorner
        self.backButton.addTarget(self, action: #selector(self.cancelAction), forControlEvents: .TouchUpInside)
        
        self.cardView.addShadow()
        self.cardView.layer.cornerRadius = kCardViewCornerRadius
        
        self.titleLabel.text = Localized("setting")
        
        self.settingTableView
            .registerNib(SettingTableViewCell.nib, forCellReuseIdentifier: SettingTableViewCell.reuseId)
        self.settingTableView
            .registerNib(SettingDetialTableViewCell.nib, forCellReuseIdentifier: SettingDetialTableViewCell.reuseId)
        
        self.settingDatas()
    }
    
    // title and icon 生成
    private func settingDatas() {
        let extras = [
            Localized("emailUs"),
            Localized("about"),
            Localized("writeReview")
        ]
        
        let general = [
            Localized("theme"),
            Localized("startDay"),
            Localized("enabDueNextDay"),
            Localized("hintClose")
        ]
        
        titles.append(general)
        titles.append(extras)
        
        
        let eIcons = [
            "fa-envelope",
            "fa-info-circle",
            "fa-pencil",
            ]
        
        let gIcons = [
            "fa-paint-brush",
            "fa-calendar",
            "fa-retweet",
            "fa-question-circle",
            ]
        self.icons.append(gIcons)
        self.icons.append(eIcons)
        
        let eSize: [CGFloat] = [
            16,
            20,
            18
        ]
        
        let gSize: [CGFloat] = [
            16,
            17,
            25,
            20
        ]
        
        self.sizes.append(gSize)
        self.sizes.append(eSize)
        
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
        let size = self.sizes[indexPath.section][indexPath.row]
        let icon = try! FAKFontAwesome(identifier: self.icons[indexPath.section][indexPath.row], size: size)
        icon.addAttribute(NSForegroundColorAttributeName, value: Colors().mainGreenColor)
        
        if indexPath.section == 0 && indexPath.row != 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(SettingDetialTableViewCell.reuseId, forIndexPath: indexPath) as! SettingDetialTableViewCell
            cell.settingTitleLabel.text = self.titles[indexPath.section][indexPath.row]
            cell.iconLabel.attributedText = icon.attributedString()
            cell.accessoryType = .None
            // todo
            let ud = UserDefault()
            if indexPath.row == 1 {
                let weekStart = ud.readInt(kWeekStartKey)
                let weeks: DaysOfWeek
                if let ws = DaysOfWeek(rawValue: weekStart) {
                    weeks = ws
                } else {
                    weeks = .Sunday
                }
                
                switch weeks {
                case .Sunday:
                    cell.detailLabel.text = Localized("day7")
                case .Monday:
                    cell.detailLabel.text = Localized("day1")
                case .Saturday:
                    cell.detailLabel.text = Localized("day6")
                    
                default:
                    break
                }
            } else if indexPath.row == 2 {
                let closeDue = ud.readBool(kCloseDueTodayKey)
                cell.detailLabel.text = closeDue ? Localized("close") : Localized("open")
                
            } else {
                let closeHint = ud.readBool(kCloseHintKey)
                cell.detailLabel.text = closeHint ? Localized("close") : Localized("open")
            }
            
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(SettingTableViewCell.reuseId, forIndexPath: indexPath) as! SettingTableViewCell
            cell.settingTitleLabel.text = self.titles[indexPath.section][indexPath.row]
            cell.iconLabel.attributedText = icon.attributedString()
            cell.accessoryType = .DisclosureIndicator
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.clearView()
        return view
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                
            // first day of week
            case 1:
                self.handleWeekOfDay()
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                
            case 2:
                self.handleOpenCloseCell(indexPath.row)
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            
            case 3:
                self.handleOpenCloseCell(indexPath.row)
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                
            default:
                break
            }
            
        } else {
            
        }
        
    }
    
    private func handleOpenCloseCell(index: Int) {
        let ud = UserDefault()
        let key = index == 2 ? kCloseDueTodayKey : kCloseHintKey
        let closeDue = ud.readBool(key)
        ud.write(key, value: !closeDue)
        
        let reloadIndex = NSIndexPath(forRow: index, inSection: 0)
        self.settingTableView.reloadRowsAtIndexPaths([reloadIndex], withRowAnimation: .Automatic)
    }
    
    private func handleWeekOfDay() {
        let ud = UserDefault()
        let weekStart = ud.readInt(kWeekStartKey)
        let weeks: DaysOfWeek
        if let ws = DaysOfWeek(rawValue: weekStart) {
            weeks = ws
        } else {
            weeks = .Sunday
        }
        
        switch weeks {
        case .Sunday:
            ud.write(kWeekStartKey, value: DaysOfWeek.Monday.rawValue)
            
        case .Monday:
            ud.write(kWeekStartKey, value: DaysOfWeek.Saturday.rawValue)
            
        case .Saturday:
            ud.write(kWeekStartKey, value: DaysOfWeek.Sunday.rawValue)
            
        default:
            break
        }
        
        
        let reloadIndex = NSIndexPath(forRow: 1, inSection: 0)
        self.settingTableView.reloadRowsAtIndexPaths([reloadIndex], withRowAnimation: .Automatic)
    }
}


