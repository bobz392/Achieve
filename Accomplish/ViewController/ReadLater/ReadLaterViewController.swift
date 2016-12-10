//
//  ReadLaterViewController.swift
//  Accomplish
//
//  Created by zhoubo on 16/12/11.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit
import Fuzi

class ReadLaterViewController: BaseViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var readLatersTableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.load()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.backAction))
        self.view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func configMainUI() {
        let colors = Colors()
        
        self.titleLabel.textColor = colors.cloudColor
        
        self.readLatersTableView.clearView()
        self.cardView.backgroundColor = colors.cloudColor
        self.view.backgroundColor = colors.mainGreenColor
        
        self.backButton.buttonColor(colors)
        self.backButton.createIconButton(iconSize: kBackButtonCorner,
                                         icon: backButtonIconString,
                                         color: colors.mainGreenColor, status: .normal)
        
        self.readLatersTableView.separatorColor = colors.separatorColor
        self.readLatersTableView.reloadData()
    }
    
    fileprivate func initializeControl() {
        self.backButton.addShadow()
        self.backButton.layer.cornerRadius = kBackButtonCorner
        self.backButton.addTarget(self, action: #selector(self.backAction), for: .touchUpInside)
        
        self.cardView.addShadow()
        self.cardView.layer.cornerRadius = kCardViewCornerRadius
        
        self.titleLabel.text = Localized("setting")
        
//        self.settingTableView
//            .register(SettingTableViewCell.nib, forCellReuseIdentifier: SettingTableViewCell.reuseId)
//        self.settingTableView
//            .register(SettingDetialTableViewCell.nib, forCellReuseIdentifier: SettingDetialTableViewCell.reuseId)
    }

    // MARK: - actions
    func backAction() {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    func load() {
        let url = URL(string: "https://github.com/tid-kijyun/Kanna")!
//        guard let html = Kanna.HTML(url: url, encoding: String.Encoding.utf8) else {
//            debugPrint("html = error")
//            return
//        }
//        debugPrint("html.head = \(html.head)")
//        debugPrint("html.body = \(html.body)")
//        debugPrint("html.title = \(html.title)")
        
        let request = URLRequest(url: url)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            
            if let error = error {
                debugPrint("error = \(error)")
                return
            }
            
            guard let data = data else {
                debugPrint("data = empty")
                return
            }
            
            guard let html = try? HTMLDocument(data: data) else {
                debugPrint("data = \(data)")
                debugPrint("data = error\n \(String(data: data, encoding: String.Encoding.utf8))")
                return
            }
            
            for link in html.css("link, icon") {
                print(link.rawXML)
                print(link["href"])
            }
            
            debugPrint("html.head = \(html.head)")
            debugPrint("html.title = \(html.title)")
        })
        task.resume()
    }
}
