//
//  SettingsViewController.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/9.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class SettingsViewController: BaseViewController {
    
    fileprivate var titles = [[String]]()
    fileprivate var icons = [[Icons]]()
    
    fileprivate let weekIndex = 1
    fileprivate let closeDueIndex = 2
    fileprivate let closeSoundIndex = 3
    
    fileprivate let settingsTableView = UITableView()
    
    // MARK: - life circle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configMainUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func configMainUI() {
        self.view.backgroundColor = Colors.mainBackgroundColor
        
        let bar = self.createCustomBar(height: kBarHeight, withBottomLine: true)
        self.congfigMenuButton()
        self.createTitleLabel(titleText: Localized("settings"), style: .center)
        
        self.configSettingsTableView(bar: bar)
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
            Localized("shareSetting"),
            Localized("startDay"),
            Localized("enabDueNextDay"),
            Localized("finishSound"),
            ]
        
        self.titles.append(general)
        self.titles.append(extras)
        
        
        let eIcons = [
            Icons.mail,
            Icons.about,
            Icons.star,
            ]
        
        let gIcons = [
            Icons.readLater,
            Icons.weekStart,
            Icons.delay,
            Icons.sound,
            ]
        self.icons.append(gIcons)
        self.icons.append(eIcons)
        
        self.settingsTableView.reloadData()
    }

}

fileprivate enum DaysOfWeek: Int {
    /// Days of the week.
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func configSettingsTableView(bar: UIView) {
        self.view.addSubview(self.settingsTableView)
        self.settingsTableView.backgroundColor = Colors.cloudColor
        self.settingsTableView.separatorColor = Colors.separatorColor
        self.settingsTableView.dataSource = self
        self.settingsTableView.delegate = self
        self.settingsTableView.separatorInset = UIEdgeInsets(top: 0, left: 48, bottom: 0, right: 0)
        self.settingsTableView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(bar.snp.bottom)
            make.bottom.equalToSuperview()
        }
        self.settingsTableView.tableFooterView = UIView()
        self.settingsTableView.register(SettingTableViewCell.nib,
                                       forCellReuseIdentifier: SettingTableViewCell.reuseId)
        self.settingsTableView.register(SettingDetialTableViewCell.nib,
                                       forCellReuseIdentifier: SettingDetialTableViewCell.reuseId)
    }
    
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
        let icon = self.icons[indexPath.section][indexPath.row]
        if indexPath.section == 0 && indexPath.row >= self.weekIndex {
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingDetialTableViewCell.reuseId, for: indexPath) as! SettingDetialTableViewCell
            cell.settingTitleLabel.text = self.titles[indexPath.section][indexPath.row]
            cell.iconImageView.image = icon.iconImage()
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
            cell.iconImageView.image = icon.iconImage()
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
        self.settingsTableView.reloadRows(at: [reloadIndex], with: .automatic)
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
        
        let reloadIndex = IndexPath(row: weekIndex, section: 0)
        self.settingsTableView.reloadRows(at: [reloadIndex], with: .automatic)
    }
}

// MAKR: - drawer open close call back -- not prefect
extension SettingsViewController: MenuDrawerSlideStatusDelegate {
    func slideOpen(open: Bool) {
        self.leftBarButton?.isSelected = open
    }
}

