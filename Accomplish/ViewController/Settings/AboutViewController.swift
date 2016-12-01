//
//  AboutViewController.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/14.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class AboutViewController: BaseViewController {

//    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var acknowledgementsButton: UIButton!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var wordLabel: UILabel!
    
    
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
        
//        self.titleLabel.textColor = colors.cloudColor
        
        self.cardView.clearView()//backgroundColor = colors.cloudColor
        self.view.backgroundColor = colors.mainGreenColor
        
        self.backButton.buttonColor(colors)
        self.backButton.createIconButton(iconSize: kBackButtonCorner,
                                         icon: backButtonIconString,
                                         color: colors.mainGreenColor,
                                         status: .normal)
        
        self.versionLabel.textColor = colors.cloudColor
        self.acknowledgementsButton.tintColor = colors.cloudColor
        
        self.nameLabel.textColor = colors.cloudColor
        self.wordLabel.textColor = colors.cloudColor
    }
    
    fileprivate func initializeControl() {
        self.backButton.addShadow()
        self.backButton.layer.cornerRadius = kBackButtonCorner
        self.backButton.addTarget(self, action: #selector(self.cancelAction), for: .touchUpInside)
        
        self.cardView.addShadow()
        self.cardView.layer.cornerRadius = kCardViewCornerRadius
        
        let appVersion = AppVersion()
        self.versionLabel.text = Localized("version") + " \(appVersion.version)" + " (\(appVersion.build))"
        self.acknowledgementsButton.setTitle(Localized("licenses"), for: .normal)
        self.acknowledgementsButton.addTarget(self, action: #selector(self.licensesAction), for: .touchUpInside)
    }
    
    // MARK: - actions
    func cancelAction() {
        guard let nav = self.navigationController else {
            return
        }
        nav.popViewController(animated: true)
    }
    
    func licensesAction() {
        let licensesVC = LicensesViewController()
        self.navigationController?.pushViewController(licensesVC, animated: true)
    }
}

struct AppVersion {
    
    var build: String {
        return Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as! String
    }
    
    var version: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    }
    
}
