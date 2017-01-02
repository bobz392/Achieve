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
    
    var customNavigationBar: UIView? = nil
    var leftBarButton: UIButton? = nil
    
    fileprivate var sourceViewBlock: SourceViewBlock? = nil
    fileprivate var previewViewControllerBlock: PreviewViewControllerBlock? = nil
    
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
    func createLeftBarButton(icon: Icons) -> UIButton {
        guard let bar = self.customNavigationBar else {
            fatalError("you don't created a bar now")
        }
        let leftBarButton = UIButton(type: .custom)
        leftBarButton.buttonWithIcon(icon: icon.iconString())
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
    
    @discardableResult
    func congfigMenuButton() -> UIButton {
        guard let bar = self.customNavigationBar else {
            fatalError("you don't created a bar now")
        }
        
        let menuButton = MenuButton()
        bar.addSubview(menuButton)
        menuButton.snp.makeConstraints { (make) in
            make.width.equalTo(kBarIconSize)
            make.height.equalTo(kBarIconSize)
            make.top.equalTo(bar).offset(26)
            make.left.equalToSuperview().offset(12)
        }
        menuButton.lineWidth = kMenuBarLineWidth
        menuButton.lineMargin = (kBarIconSize - kMenuBarLineWidth) * 0.5
        menuButton.lineCapRound = true
        menuButton.thickness = 2.5
        menuButton.backgroundColor = UIColor.clear
        menuButton.strokeColor = Colors.mainIconColor
        menuButton.addTarget(self, action: #selector(self.openMenuAction), for: .touchUpInside)
        
        self.leftBarButton = menuButton
        return menuButton
    }
    
    @discardableResult
    func createTitleLabel(titleText: String, style: ControllerTitleStyle = .center) -> UILabel {
        guard let bar = self.customNavigationBar else {
            fatalError("you don't created a bar now")
        }
        
        let titleLabel = UILabel()
        titleLabel.textColor = Colors.mainTextColor
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.text = titleText
        bar.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(10)
            if style == .center {
                make.centerX.equalToSuperview()
            } else {
                if let leftButton = self.leftBarButton {
                    make.left.equalTo(leftButton.snp.right).offset(12)
                } else {
                    make.left.equalToSuperview().offset(12)
                }
            }
        }

        return titleLabel
    }
    
    @discardableResult
    func createPlusButton() -> UIButton {
        let newTaskButton = AwesomeButton(type: .custom)
        self.view.addSubview(newTaskButton)
        let side: CGFloat = DeviceSzie.isSmallDevice() ? 50 : 70
        
        newTaskButton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-15)
            make.width.equalTo(side)
            make.height.equalTo(side)
            make.centerX.equalToSuperview()
        }
        newTaskButton.addShadow()
        newTaskButton.layer.cornerRadius = side * 0.5
        newTaskButton.buttonWithIcon(icon: Icons.plus.iconString(),
                                     backgroundColor: Colors.cellCardColor)
        
        return newTaskButton
    }
    
    func openMenuAction() {
        appDelegate?.drawer?.open(.left, animated: true, completion: nil)
    }
    
    func backAction() {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    func dismissAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
}

// Mark: - 3d touch
extension BaseViewController: UIViewControllerPreviewingDelegate {
    typealias SourceViewBlock = () -> UIView
    typealias PreviewViewControllerBlock = (UIViewControllerPreviewing, CGPoint) -> UIViewController?
    
    @available(iOS 9.0, *)
    func registerPerview(sourceViewBlock: @escaping SourceViewBlock,
                         previewViewControllerBlock: @escaping PreviewViewControllerBlock) {
        self.previewViewControllerBlock = previewViewControllerBlock
        self.sourceViewBlock = sourceViewBlock
        
        if self.traitCollection.forceTouchCapability == .available {
            self.registerForPreviewing(with: self, sourceView: sourceViewBlock())
        } else {
            Logger.log("该设备不支持3D-Touch")
        }
    }
    
    @available(iOS 9.0, *)
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.navigationController?.pushViewController(viewControllerToCommit, animated: false)
    }
    
    @available(iOS 9.0, *)
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        return self.previewViewControllerBlock?(previewingContext, location)
    }
    
    @available(iOS 8.0, *)
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 9.0, *) {
            switch traitCollection.forceTouchCapability {
            case .available:
                guard let block = self.sourceViewBlock else { return }
                self.registerForPreviewing(with: self, sourceView: block())
            default:
                return
            }
        }
    }

}

enum ControllerTitleStyle {
    case center
    case left
}
