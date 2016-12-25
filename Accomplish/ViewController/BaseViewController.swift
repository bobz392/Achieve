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

class BaseViewController: UIViewController, UIGestureRecognizerDelegate {
    
    fileprivate var customNavigationBar: UIView? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let nav = self.navigationController,
            let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.setOpenDrawMode(openMode: nav.viewControllers.count <= 1)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeMainUI), name: NSNotification.Name(rawValue: kBackgroundNeedRefreshNotification), object: nil)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.edgesForExtendedLayout = UIRectEdge()
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
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
    
    @discardableResult
    func createCustomBar(height: CGFloat? = nil, withBottomLine: Bool = false) -> UIView {
        let bar = UIView()
        bar.backgroundColor = Colors.mainBackgroundColor
        self.view.addSubview(bar)
        bar.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            if let h = height {
                make.height.equalTo(h)
            }
        }
        self.customNavigationBar = bar
        
        if withBottomLine {
            let lineView = UIView()
            bar.addSubview(lineView)
            lineView.backgroundColor = Colors.separatorColor
            lineView.snp.makeConstraints({ (make) in
                make.bottom.equalToSuperview()
                make.left.equalToSuperview()
                make.right.equalToSuperview()
                make.height.equalTo(0.5)
            })
        }
        
        return bar
    }
}
