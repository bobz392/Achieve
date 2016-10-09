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
    
    fileprivate var titles = [[String]]()
    fileprivate var icons = [[String]]()
    fileprivate var sizes = [[CGFloat]]()
    
    fileprivate var selectedIndex: IndexPath? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.configMainUI()
        self.initializeControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let s = selectedIndex else { return }
        self.settingTableView.deselectRow(at: s, animated: true)
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
                                         status: .normal)
        
        self.settingTableView.separatorColor = colors.separatorColor
        self.settingTableView.reloadData()
    }
    
    fileprivate func initializeControl() {
        self.backButton.addShadow()
        self.backButton.layer.cornerRadius = kBackButtonCorner
        self.backButton.addTarget(self, action: #selector(self.cancelAction), for: .touchUpInside)
        
        self.cardView.addShadow()
        self.cardView.layer.cornerRadius = kCardViewCornerRadius
        
        self.titleLabel.text = Localized("setting")
        
        self.settingTableView
            .register(SettingTableViewCell.nib, forCellReuseIdentifier: SettingTableViewCell.reuseId)
        self.settingTableView
            .register(SettingDetialTableViewCell.nib, forCellReuseIdentifier: SettingDetialTableViewCell.reuseId)
        
        self.settingDatas()
    }
    
    // title and icon 生成
    fileprivate func settingDatas() {
        let extras = [
            Localized("emailUs"),
            Localized("about"),
            Localized("writeReview"),
            ]
        
        let general = [
            Localized("theme"),
            Localized("startDay"),
            Localized("enabDueNextDay"),
            Localized("finishSound"),
//            Localized("hintClose"),
            ]
        
        self.titles.append(general)
        self.titles.append(extras)
        
        
        let eIcons = [
            "fa-envelope",
            "fa-info-circle",
            "fa-pencil",
            ]
        
        let gIcons = [
            "fa-paint-brush",
            "fa-calendar",
            "fa-retweet",
            "fa-music",
//            "fa-question-circle",
            ]
        self.icons.append(gIcons)
        self.icons.append(eIcons)
        
        let eSize: [CGFloat] = [
            16,
            20,
            18,
        ]
        
        let gSize: [CGFloat] = [
            16,
            17,
            25,
            18,
//            20,
        ]
        
        self.sizes.append(gSize)
        self.sizes.append(eSize)
        
        self.settingTableView.reloadData()
    }
    
    // MARK: - actions
    func cancelAction() {
        guard let nav = self.navigationController else {
            return
        }
        nav.popViewController(animated: true)
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                return SettingTableViewCell.rowHeight
            } else {
                return SettingDetialTableViewCell.rowHeight
            }
        } else {
            return SettingTableViewCell.rowHeight
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let size = self.sizes[indexPath.section][indexPath.row]
        let icon = try! FAKFontAwesome(identifier:
            self.icons[indexPath.section][indexPath.row], size: size)
        icon.addAttribute(NSForegroundColorAttributeName, value: Colors().mainGreenColor)
        
        if indexPath.section == 0 && indexPath.row != 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingDetialTableViewCell.reuseId, for: indexPath) as! SettingDetialTableViewCell
            cell.settingTitleLabel.text = self.titles[indexPath.section][indexPath.row]
            cell.iconLabel.attributedText = icon.attributedString()
            cell.accessoryType = .none
            
            let ud = AppUserDefault()
            if indexPath.row == 1 {
                let weekStart = ud.readInt(kWeekStartKey)
                let weeks: DaysOfWeek
                if let ws = DaysOfWeek(rawValue: weekStart) {
                    weeks = ws
                } else {
                    weeks = .sunday
                }
                
                switch weeks {
                case .sunday:
                    cell.detailLabel.text = Localized("day7")
                case .monday:
                    cell.detailLabel.text = Localized("day1")
                case .saturday:
                    cell.detailLabel.text = Localized("day6")
                    
                default:
                    break
                }
                
            } else if indexPath.row == 2 {
                let closeDue = ud.readBool(kCloseDueTodayKey)
                cell.detailLabel.text = closeDue ? Localized("close") : Localized("open")
                
            } else if indexPath.row == 3 {
                let closeSound = ud.readBool(kCloseSoundKey)
                cell.detailLabel.text = closeSound ? Localized("close") : Localized("open")
            } else if indexPath.row == 4 {
                let closeHint = ud.readBool(kCloseHintKey)
                cell.detailLabel.text = closeHint ? Localized("close") : Localized("open")
            }
            
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingTableViewCell.reuseId, for: indexPath) as! SettingTableViewCell
            cell.settingTitleLabel.text = self.titles[indexPath.section][indexPath.row]
            cell.iconLabel.attributedText = icon.attributedString()
            cell.accessoryType = .disclosureIndicator
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = SettingHeaderView.loadNib(self)
        view?.headerTitleLabel.text =
            section == 0 ? Localized("general") : Localized("extra")
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                self.selectedIndex = indexPath
                let backgroundVC = BackgroundViewController()
                self.navigationController?.pushViewController(backgroundVC, animated: true)
                
            // first day of week
            case 1:
                self.handleWeekOfDay()
                tableView.deselectRow(at: indexPath, animated: true)
                
            default:
                self.handleOpenCloseCell(indexPath.row)
                tableView.deselectRow(at: indexPath, animated: true)
            }
            
        } else {
            switch indexPath.row {
            case 0:
                break
                
            case 1:
                self.selectedIndex = indexPath
                let aboutVC = AboutViewController()
                self.navigationController?.pushViewController(aboutVC, animated: true)
                
            case 2:
                break
                
            default:
                break
            }
        }
    }

    fileprivate func handleOpenCloseCell(_ index: Int) {
        let ud = AppUserDefault()
        let key: String
        switch index {
        case 2:
            key = kCloseDueTodayKey
        case 3:
            key = kCloseSoundKey
        case 4:
            key = kCloseHintKey
        default:
            return
        }
        let closeDue = ud.readBool(key)
        ud.write(key, value: !closeDue)
        
        let reloadIndex = IndexPath(row: index, section: 0)
        self.settingTableView.reloadRows(at: [reloadIndex], with: .automatic)
    }
    
    fileprivate func handleWeekOfDay() {
        let ud = AppUserDefault()
        let weekStart = ud.readInt(kWeekStartKey)
        let weeks: DaysOfWeek
        if let ws = DaysOfWeek(rawValue: weekStart) {
            weeks = ws
        } else {
            weeks = .sunday
        }
        
        switch weeks {
        case .sunday:
            ud.write(kWeekStartKey, value: DaysOfWeek.monday.rawValue)
            
        case .monday:
            ud.write(kWeekStartKey, value: DaysOfWeek.saturday.rawValue)
            
        case .saturday:
            ud.write(kWeekStartKey, value: DaysOfWeek.sunday.rawValue)
            
        default:
            break
        }
        
        
        let reloadIndex = IndexPath(row: 1, section: 0)
        self.settingTableView.reloadRows(at: [reloadIndex], with: .automatic)
    }
}


