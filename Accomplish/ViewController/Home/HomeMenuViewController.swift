//
//  HomeMenuViewController.swift
//  Accomplish
//
//  Created by zhoubo on 16/12/21.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class HomeMenuViewController: UIViewController {

    typealias MenuShowBlock = (_ show: Bool) -> Void
    var menuShowBlock: MenuShowBlock? = nil
    
    let menuTableView = UITableView()
    
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
        self.menuTableView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        self.menuTableView.tableFooterView = UIView()
    }
}
