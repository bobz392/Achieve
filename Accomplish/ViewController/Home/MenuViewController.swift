//
//  HomeMenuViewController.swift
//  Accomplish
//
//  Created by zhoubo on 16/12/21.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    
    typealias MenuShowBlock = (_ show: Bool) -> Void
    
    var menuShowBlock: MenuShowBlock? = nil
    fileprivate let menuTableView = UITableView()
    fileprivate let icons =
        [Icons.home, Icons.calendar, Icons.tag, Icons.timeManagement, Icons.settings]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.uiConfig()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.menuShowBlock?(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.menuShowBlock?(false)
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
    
}
