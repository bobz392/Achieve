//
//  BaseViewController.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/26.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

let kBackgroundNeedRefreshNotification = "theme.need.refresh.notify"

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.changeMainUI), name: kBackgroundNeedRefreshNotification, object: nil)
        
        self.edgesForExtendedLayout = .None
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func configMainUI() {
        
    }
    
    func changeMainUI() {
        if self.isViewLoaded() && self.view.window != nil {
            UIView.animateWithDuration(kNormalAnimationDuration) {
                self.configMainUI()
            }
        } else {
            self.configMainUI()
        }
    }
}
