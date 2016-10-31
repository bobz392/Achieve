//
//  StartTimeManagementViewController.swift
//  Accomplish
//
//  Created by zhoubo on 16/10/31.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class StartTimeManagementViewController: BaseViewController {

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
        
        self.view.backgroundColor = colors.mainGreenColor

    }
    
    fileprivate func initializeControl() {

    }
    
    // MARK: - actions
}
