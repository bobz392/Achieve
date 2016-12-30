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
    
    fileprivate let weekIndex = 3
    fileprivate let closeDueIndex = 4
    fileprivate let closeSoundIndex = 5
    
    // MARK: - life circle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.configMainUI()
        self.initializeControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func configMainUI() {
        let colors = Colors()
        
        self.titleLabel.textColor = Colors.cloudColor
        
        self.settingTableView.clearView()
        self.cardView.backgroundColor = Colors.cloudColor
        self.view.backgroundColor = colors.mainGreenColor
        
        self.backButton.buttonColor(colors)
        self.backButton.createIconButton(iconSize: kBackButtonCorner,
                                         icon: backButtonIconString,
                                         color: colors.mainGreenColor, status: .normal)
        
        self.settingTableView.separatorColor = Colors.separatorColor
        self.settingTableView.reloadData()
    }
    
    fileprivate func initializeControl() {
        self.backButton.addShadow()
        self.backButton.layer.cornerRadius = kBackButtonCorner
        self.backButton.addTarget(self, action: #selector(self.backAction), for: .touchUpInside)
        
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
            Localized("timeManagementSetting"),
            Localized("shareSetting"),
            Localized("startDay"),
            Localized("enabDueNextDay"),
            Localized("finishSound"),
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
            "fa-bullseye",
            "fa-bookmark",
            "fa-calendar",
            "fa-retweet",
            "fa-music",
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
            20,
            20,
            17,
            25,
            18,
            ]
        
        self.sizes.append(gSize)
        self.sizes.append(eSize)
        
        self.settingTableView.reloadData()
    }

}

fileprivate enum DaysOfWeek: Int {
    /// Days of the week.
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
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
        
        if indexPath.section == 0 && indexPath.row >= self.weekIndex {
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingDetialTableViewCell.reuseId, for: indexPath) as! SettingDetialTableViewCell
            cell.settingTitleLabel.text = self.titles[indexPath.section][indexPath.row]
            cell.iconLabel.attributedText = icon.attributedString()
            cell.accessoryType = .none
            
            let ud = AppUserDefault()
            if indexPath.row == self.weekIndex {
                let weekStart = ud.readInt(kUserDefaultWeekStartKey)
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
            } else if indexPath.row == self.closeDueIndex {
                let closeDue = ud.readBool(kUserDefaultCloseDueTodayKey)
                cell.detailLabel.text = closeDue ? Localized("close") : Localized("open")
            } else if indexPath.row == self.closeSoundIndex {
                let closeSound = ud.readBool(kUserDefaultCloseSoundKey)
                cell.detailLabel.text = closeSound ? Localized("close") : Localized("open")
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
//                let backgroundVC = BackgroundViewController()
//                self.navigationController?.pushViewController(backgroundVC, animated: true)
                break
                
            // 工作法管理
            case 1:
                let timeVC = TimeManagementViewController()
                self.navigationController?.pushViewController(timeVC, animated: true)
            
            case 2:
                let readVC = ReadLaterViewController()
                self.navigationController?.pushViewController(readVC, animated: true)
                
            // first day of week
            case self.weekIndex:
                self.handleWeekOfDay()
                
            default:
                self.handleOpenCloseCell(indexPath.row)
            }
            
        } else {
            switch indexPath.row {
            case 0:
                guard let url = URL(string: "mailto:achieveappteam@gmail.com") else { return }
                UIApplication.shared.openURL(url)
                break
                
            case 1:
                let aboutVC = AboutViewController()
                self.navigationController?.pushViewController(aboutVC, animated: true)
                
            case 2:
                let url = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&id=1166332931"
                guard let u = URL(string: url) else { return }
                
                UIApplication.shared.openURL(u)
                break
                
            default:
                break
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    fileprivate func handleOpenCloseCell(_ index: Int) {
        let ud = AppUserDefault()
        let key: String
        switch index {
        case self.closeDueIndex:
            key = kUserDefaultCloseDueTodayKey
        case self.closeSoundIndex:
            key = kUserDefaultCloseSoundKey
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
        let weekStart = ud.readInt(kUserDefaultWeekStartKey)
        let weeks: DaysOfWeek
        if let ws = DaysOfWeek(rawValue: weekStart) {
            weeks = ws
        } else {
            weeks = .sunday
        }
        
        switch weeks {
        case .sunday:
            ud.write(kUserDefaultWeekStartKey, value: DaysOfWeek.monday.rawValue)
            
        case .monday:
            ud.write(kUserDefaultWeekStartKey, value: DaysOfWeek.saturday.rawValue)
            
        case .saturday:
            ud.write(kUserDefaultWeekStartKey, value: DaysOfWeek.sunday.rawValue)
            
        default:
            break
        }
        
        let reloadIndex = IndexPath(row: 2, section: 0)
        self.settingTableView.reloadRows(at: [reloadIndex], with: .automatic)
    }
}

// MAKR: - drawer open close call back -- not prefect
extension SettingsViewController: MenuDrawerSlideStatusDelegate {
    func slideOpen(open: Bool) {
        self.leftBarButton?.isSelected = open
    }
}

