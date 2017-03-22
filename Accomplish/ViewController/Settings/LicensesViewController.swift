//
//  LicensesViewController.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/14.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class LicensesViewController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configMainUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func configMainUI() {
        self.view.backgroundColor = Colors.mainBackgroundColor
        let bar = self.createCustomBar(height: kBarHeight, withBottomLine: true)
        let backButton = self.createLeftBarButton(icon: Icons.back)
        backButton.addTarget(self, action: #selector(self.backAction), for: .touchUpInside)
        self.createTitleLabel(titleText: Localized("licenses"), style: .center)
        
        let textView = UITextView()
        self.view.addSubview(textView)
        textView.font = appFont(size: 14, weight: UIFontWeightLight)
        textView.textColor = Colors.mainTextColor
        textView.backgroundColor = Colors.mainBackgroundColor
        textView.snp.makeConstraints { (make) in
            make.top.equalTo(bar.snp.bottom).offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(10)
        }
        
        if let stringURL = Bundle.main.url(forResource: "Acknowledgements", withExtension: nil) {
            DispatchQueue(label: "com.shimo.fileReading", attributes: []).async {
                if let string = try? String(contentsOf: stringURL, encoding: String.Encoding.utf8) {
                    DispatchQueue.main.async {
                        textView.text = string
                    }
                }
            }
        }

    }
    
 }
