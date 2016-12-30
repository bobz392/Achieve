//
//  HomeMenuViewController.swift
//  Accomplish
//
//  Created by zhoubo on 16/12/21.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    
    fileprivate let cacheHomeVC: HomeViewController
    fileprivate let menuTableView = UITableView()
    var cacheViewControllers = [Int: UIViewController]()
    var currentIndex = 0
    weak var menuDelegate: MenuDrawerSlideStatusDelegate? = nil
    
    fileprivate let icons =
        [Icons.home, Icons.calendar, Icons.tag, Icons.timeManagement, Icons.settings]

    init(withHomeVC: HomeViewController) {
        self.cacheHomeVC = withHomeVC
        self.menuDelegate = withHomeVC
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.cacheHomeVC = HomeViewController()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.uiConfig()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        self.cacheViewControllers.removeAll()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.menuDelegate?.slideOpen(open: true)
        self.menuTableView.selectRow(at: IndexPath(row: self.currentIndex, section:0),
                                     animated: true, scrollPosition: .none)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.menuDelegate?.slideOpen(open: false)
    }
    
    fileprivate func uiConfig() {
        self.view.backgroundColor = Colors.mainBackgroundColor
        
        self.view.addSubview(self.menuTableView)
        self.menuTableView.clearView()
        self.menuTableView.separatorStyle = .none
        self.menuTableView.delegate = self
        self.menuTableView.dataSource = self
        self.menuTableView.register(MenuTableViewCell.nib,
                                    forCellReuseIdentifier: MenuTableViewCell.reuseId)
        self.menuTableView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        self.menuTableView.tableFooterView = UIView()
    }
    
    func selectedNewMenu(index: Int) {
        self.menuTableView.selectRow(at: IndexPath(row: index, section:0), animated: false, scrollPosition: .none)
        self.tableView(self.menuTableView, didSelectRowAt: IndexPath(row: index, section:0))
    }
    
}

// MARK: -- UITableView delegate and dataSource
extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MenuTableViewCell.reuseId,
                                                 for: indexPath) as! MenuTableViewCell
        cell.configCell(icon: self.icons[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return MenuHeaderView.height
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = MenuHeaderView.loadNib(self)
        header?.setNewDate(date: NSDate())
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? MenuTableViewCell.rowHeight + 20 : MenuTableViewCell.rowHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.icons.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else { return }
        
        if indexPath.row == self.currentIndex {
            appDelegate.drawer?.closeDrawer(animated: true, completion: nil)
            return
        }
        
        let viewController: UIViewController
        
        switch indexPath.row {
        case 0:
            viewController = self.cacheHomeVC
        case 1:
            if let vc = self.cacheViewControllers[0] {
                viewController = vc
            } else {
                let calendarVC = CalendarViewController()
                self.cacheViewControllers[0] = calendarVC
                viewController = calendarVC
            }
        case 2:
            if let vc = self.cacheViewControllers[1] {
                viewController = vc
            } else {
                let tagVC = TagViewController()
                self.cacheViewControllers[1] = tagVC
                viewController = tagVC
            }
        case 3:
            if let vc = self.cacheViewControllers[2] {
                viewController = vc
            } else {
                let tmVC = TimeManagementViewController(isSelectTM: false, selectTMBlock: nil)
                self.cacheViewControllers[2] = tmVC
                viewController = tmVC
            }
        case 4:
            if let vc = self.cacheViewControllers[3] {
                viewController = vc
            } else {
                let settingVC = SettingsViewController()
                self.cacheViewControllers[3] = settingVC
                viewController = settingVC
            }
            
        default:
            return
        }
        
        if let delegate = viewController as? MenuDrawerSlideStatusDelegate {
            self.menuDelegate = delegate
        }
        
        let deselectIndex = IndexPath(row: self.currentIndex, section: 0)
        tableView.deselectRow(at: deselectIndex, animated: true)
        self.currentIndex = indexPath.row
        appDelegate.drawer?.setCenterView(viewController, withCloseAnimation: true,
                                          completion: { (finish) in
                                            
        })
    }
    
}

protocol MenuDrawerSlideStatusDelegate: NSObjectProtocol {
    func slideOpen(open: Bool)
}
