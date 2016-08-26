//
//  ScheduleViewController.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/25.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class ScheduleViewController: BaseViewController {
    
    weak var taskDateDelegate: NewTaskDateDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.back))
        self.view.addGestureRecognizer(tap)
    }
    
    override func configMainUI() {
        let colors = Colors()
        
        self.view.backgroundColor = colors.mainGreenColor
    }
    
    func back() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
