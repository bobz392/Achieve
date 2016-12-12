//
//  ReadLaterViewController.swift
//  Accomplish
//
//  Created by zhoubo on 16/12/11.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit
import SafariServices

class ReadLaterViewController: BaseViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var readLatersTableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    
    fileprivate var readLaters = RealmManager.shared.allReadLaters()
    fileprivate var readLaterManager =
        ReadLaterManager()
    
    // MARK: - life circle
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
        
        self.titleLabel.text = Localized("readLaterTitle")
        
        self.readLatersTableView.register(ReadLaterTableViewCell.nib,
                                          forCellReuseIdentifier: ReadLaterTableViewCell.reuseId)
        self.readLatersTableView.tableFooterView = UIView()
    }
    
    // MARK: - actions
    func backAction() {
        let _ = self.navigationController?.popViewController(animated: true)
    }
}

extension ReadLaterViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.readLaters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReadLaterTableViewCell.reuseId, for: indexPath) as! ReadLaterTableViewCell
        
        let readLater = self.readLaters[indexPath.row]
        if readLater.cacheed {
            cell.configCell(readLater: readLater)
        } else {
            cell.loadingActivityIndicator.startAnimating()
            self.readLaterManager.downloadReadLaterPreview(readLater: readLater, finishBlock: { 
                tableView.reloadRows(at: [indexPath], with: .automatic)
                cell.loadingActivityIndicator.stopAnimating()
            })
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ReadLaterTableViewCell.rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let url = URL(string: self.readLaters[indexPath.row].link) else { return }
        if #available(iOS 9.0, *) {
            let sfVC = SFSafariViewController(url: url, entersReaderIfAvailable: true)
            self.present(sfVC, animated: true, completion: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let read = self.readLaters[indexPath.row]
            RealmManager.shared.deleteObject(read)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}
