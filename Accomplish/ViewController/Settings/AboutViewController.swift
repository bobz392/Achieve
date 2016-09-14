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
        self.backButton.createIconButton(iconSize: kBackButtonCorner, imageSize: kBackButtonCorner,
                                         icon: backButtonIconString, color: colors.mainGreenColor,
                                         status: .Normal)
        
        self.versionLabel.textColor = colors.cloudColor
        self.acknowledgementsButton.tintColor = colors.cloudColor
        
        self.nameLabel.textColor = colors.cloudColor
        self.wordLabel.textColor = colors.cloudColor
    }
    
    private func initializeControl() {
        self.backButton.addShadow()
        self.backButton.layer.cornerRadius = kBackButtonCorner
        self.backButton.addTarget(self, action: #selector(self.cancelAction), forControlEvents: .TouchUpInside)
        
        self.cardView.addShadow()
        self.cardView.layer.cornerRadius = kCardViewCornerRadius
        
//        self.titleLabel.text = Localized("about")
        
        self.versionLabel.text = Localized("version") + AppVersion().version
        self.acknowledgementsButton.setTitle(Localized("licenses"), forState: .Normal)
        self.acknowledgementsButton.addTarget(self, action: #selector(self.licensesAction), forControlEvents: .TouchUpInside)
    }
    
    // MARK: - actions
    func cancelAction() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func licensesAction() {
        let licensesVC = LicensesViewController()
        self.navigationController?.pushViewController(licensesVC, animated: true)
    }
}

struct AppVersion {
    
    var build: String {
        return NSBundle.mainBundle().infoDictionary?[kCFBundleVersionKey as String] as! String
    }
    
    var version: String {
        return NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as! String
    }
    
}
