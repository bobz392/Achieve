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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor(red:0.98, green:0.99, blue:1.00, alpha:1.00)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Logger.log("HomeMenuViewController will appear")
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Logger.log("HomeMenuViewController did appear")
        self.menuShowBlock?(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        Logger.log("HomeMenuViewController did disappear")
        self.menuShowBlock?(false)
    }
}
