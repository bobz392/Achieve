//
//  AboutViewController.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/14.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class AboutViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.configMainUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func configMainUI() {
        self.view.backgroundColor = Colors.mainBackgroundColor
        self.createCustomBar(height: kBarHeight, withBottomLine: false)
        let backButton = self.createLeftBarButton(icon: Icons.back)
        backButton.addTarget(self, action: #selector(self.backAction), for: .touchUpInside)
        
        let appLabel = UILabel()
        appLabel.font = appFont(size: 45)
        appLabel.textColor = Colors.mainIconColor
        appLabel.text = "Achieve"
        appLabel.textAlignment = .center
        self.view.addSubview(appLabel)
        appLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().multipliedBy(0.35).offset(kBarHeight)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        
        let contentLabel = UILabel()
        contentLabel.text = "We always have time enough, if we will but use it aright."
        contentLabel.numberOfLines = 0
        contentLabel.textColor = Colors.mainIconColor
        contentLabel.textAlignment = .center
        contentLabel.font = appFont(size: 14)
        self.view.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { (make) in
            make.top.equalTo(appLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
        }
        
        let acknowledgementsButton = UIButton()
        acknowledgementsButton.setTitleColor(Colors.cellLabelSelectedTextColor, for: .normal)
        acknowledgementsButton.setTitle(Localized("licenses"), for: .normal)
        acknowledgementsButton.tintColor = Colors.cloudColor
        acknowledgementsButton.addTarget(self, action: #selector(self.licensesAction), for: .touchUpInside)
        
        let appVersion = AppVersion()
        let versionLabel = UILabel()
        versionLabel.textColor = Colors.mainIconColor
        versionLabel.textAlignment = .center
        versionLabel.font = appFont(size: 12)
        versionLabel.text = Localized("version") + " \(appVersion.version)" + " (\(appVersion.build))"
        self.view.addSubview(versionLabel)
        versionLabel.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-20)
            make.centerX.equalToSuperview()
        }
        
        self.view.addSubview(acknowledgementsButton)
        acknowledgementsButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(versionLabel.snp.top).offset(-14)
            make.centerX.equalToSuperview()
        }
    }
    
    // MARK: - actions
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
