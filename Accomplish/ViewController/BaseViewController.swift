//
//  BaseViewController.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/26.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit
import SnapKit

let kBackgroundNeedRefreshNotification = "theme.need.refresh.notify"

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeMainUI), name: NSNotification.Name(rawValue: kBackgroundNeedRefreshNotification), object: nil)
        
        self.edgesForExtendedLayout = UIRectEdge()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func configMainUI() {
        
    }
    
    func changeMainUI() {
        if self.isViewLoaded && self.view.window != nil {
            UIView.animate(withDuration: kNormalAnimationDuration, animations: {
                self.configMainUI()
            }) 
        } else {
            self.configMainUI()
        }
    }
}
