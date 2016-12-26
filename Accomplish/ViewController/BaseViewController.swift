//
//  BaseViewController.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/26.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit
import SnapKit

class BaseViewController: UIViewController, UIGestureRecognizerDelegate {
    
    fileprivate var customNavigationBar: UIView? = nil
    fileprivate var leftBarButton: UIButton? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = .all
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)   
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    func configMainUI() {
        
    }
    
    /**
     返回一个自定义的 bar。
     并且已经添加到 view 中，可以直接拿来使用。
     如果 height 为 nil，则表示 bar height 有内容来填充控制。
     */
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
    
    @discardableResult
    func createLeftBarButton(iconString: String) -> UIButton {
        guard let bar = self.customNavigationBar else {
            fatalError("you don't created a bar now")
        }
        let leftBarButton = UIButton(type: .custom)
        leftBarButton.buttonWithIcon(icon: iconString)
        bar.addSubview(leftBarButton)
        leftBarButton.snp.makeConstraints { (make) in
            make.width.equalTo(kBarIconSize)
            make.height.equalTo(kBarIconSize)
            make.top.equalTo(bar).offset(26)
            make.left.equalToSuperview().offset(12)
        }
        self.leftBarButton = leftBarButton
        return leftBarButton
    }
}
