//
//  TimeManagementViewController.swift
//  Accomplish
//
//  Created by zhoubo on 16/10/31.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class TimeManagementViewController: BaseViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var methodTableView: UITableView!
    @IBOutlet weak var createMethodButton: UIButton!
    
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
        
        self.titleLabel.textColor = colors.cloudColor
        
        self.cardView.backgroundColor = colors.cloudColor
        self.view.backgroundColor = colors.mainGreenColor
        
        self.backButton.buttonColor(colors)
        self.backButton.createIconButton(iconSize: kBackButtonCorner,
                                         icon: backButtonIconString,
                                         color: colors.mainGreenColor, status: .normal)
        self.createMethodButton.tintColor = colors.linkTextColor
        self.createMethodButton.backgroundColor = colors.cloudColor
        self.createMethodButton.addTopShadow()
    }
    
    fileprivate func initializeControl() {
        self.cardView.addShadow()
        self.cardView.layer.cornerRadius = kCardViewCornerRadius
        
        self.backButton.addShadow()
        self.backButton.layer.cornerRadius = kBackButtonCorner
        self.backButton.addTarget(self, action: #selector(self.backAction), for: .touchUpInside)
        
        self.createMethodButton.setTitle(Localized("createTimeManagement"), for: .normal)
        self.createMethodButton.addTarget(self, action: #selector(self.newMethodAction), for: .touchUpInside)
        
        self.titleLabel.text = Localized("timeManagementSetting")
    }
    
    // MARK: - actions
    func backAction() {
        guard let nav = self.navigationController else {
            return
        }
        nav.popViewController(animated: true)
    }

    func newMethodAction() {
    
    }
}

extension TimeManagementViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
