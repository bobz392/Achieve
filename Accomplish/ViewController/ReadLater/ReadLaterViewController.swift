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
    
    fileprivate let readLaterTableView = UITableView()
    fileprivate let emptyLabel = UILabel()
    
    fileprivate var readLaters = RealmManager.shared.allReadLaters()
    fileprivate var readLaterManager =
        ReadLaterManager()
    
    // MARK: - life circle
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
        self.createTitleLabel(titleText: Localized("readLaterTitle"), style: .center)
        self.configReadLaterTableView(bar: bar)
    }

}

extension ReadLaterViewController: UITableViewDelegate, UITableViewDataSource {
    func configReadLaterTableView(bar: UIView) {
        self.view.addSubview(self.readLaterTableView)
        self.readLaterTableView.snp.makeConstraints { (make) in
            make.top.equalTo(bar.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        self.readLaterTableView.delegate = self
        self.readLaterTableView.dataSource = self
        self.readLaterTableView.separatorColor = Colors.separatorColor
        self.readLaterTableView.register(ReadLaterTableViewCell.nib,
                                          forCellReuseIdentifier: ReadLaterTableViewCell.reuseId)
        self.readLaterTableView.tableFooterView = UIView()
    }
    
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
