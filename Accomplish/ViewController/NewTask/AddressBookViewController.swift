//
//  AddressBookViewController.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/26.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit
import MessageUI
import SVProgressHUD

private typealias Indexes = [String]
private typealias IndexedData = [String : [AddressBook.Person]]

private let AddressBookMiscIndexKey = "#"

final class AddressBookViewController: UIViewController {
    
    @IBOutlet var searchBarTopConstraint: NSLayoutConstraint!
    @IBOutlet var tableView: UITableView!
    
    weak var delegate: TaskActionDataDelegate? = nil
    
    class func loadFromNib() -> AddressBookViewController {
        return AddressBookViewController(nibName: "AddressBookViewController", bundle: nil)
    }
    
    private var indexingQueue = dispatch_queue_create("com.shimo.AddressBook.indexing", DISPATCH_QUEUE_SERIAL)
    
    private var indexes: Indexes = []
    private var data: IndexedData = [:]
    
    private var searchResult: [AddressBook.Person] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "通讯录"
        
        edgesForExtendedLayout = .None
        
        config(tableView: tableView)
        config(tableView: searchDisplayController?.searchResultsTableView)
        
        SVProgressHUD.show()
        AddressBook.requestAccess { (finish) in
            AddressBook.fetchAllPeopleInAddressBook { people in
                dispatch_async(self.indexingQueue) {
                    (self.indexes, self.data) = self.processPeople(people)
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        SVProgressHUD.dismiss()
                        
                        self.tableView.reloadData()
                    }
                }
            }
            
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBarHidden = true
    }
    
    private func config(tableView tableView: UITableView?) {
        let colorValue: CGFloat = 68 / 255
        let sectionIndexColor = UIColor(red: colorValue, green: colorValue, blue: colorValue, alpha: 1)
        tableView?.sectionIndexColor = sectionIndexColor
        
        tableView?.sectionIndexBackgroundColor = UIColor.clearColor()
        tableView?.registerNib(AddressBookTableViewCell.nib, forCellReuseIdentifier: AddressBookTableViewCell.reuseId)
        tableView?.separatorStyle = .None
    }
    
}

extension AddressBookViewController: UITableViewDelegate, UITableViewDataSource {
    
    private func isSearchResultTableView(tableView: UITableView) -> Bool {
        return tableView === searchDisplayController?.searchResultsTableView
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isSearchResultTableView(tableView) {
            return 0
        } else {
            return 25
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if isSearchResultTableView(tableView) {
            return 1
        } else {
            return indexes.count
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearchResultTableView(tableView) {
            return searchResult.count
        } else {
            let index = indexes[section]
            return data[index]?.count ?? 0
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let index = indexes[indexPath.section]
        let person: AddressBook.Person?
        
        if isSearchResultTableView(tableView) {
            person = searchResult[indexPath.row]
        } else {
            person = data[index]?[indexPath.row]
        }
        
        if let person = person {
            delegate?.actionData(person.name.fullName, info: person.phoneNumbers.first?.phoneNumberString ?? "")
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(AddressBookTableViewCell.reuseId, forIndexPath: indexPath) as? AddressBookTableViewCell else {
            return UITableViewCell()
        }
        
        let index = indexes[indexPath.section]
        let person: AddressBook.Person?
        
        if isSearchResultTableView(tableView) {
            person = searchResult[indexPath.row]
        } else {
            person = data[index]?[indexPath.row]
        }
        
        if let person = person {
            cell.nameLabel.text = person.name.fullName
            cell.phoneNumberLabel.text = person.phoneNumbers.first?.displayName ?? ""
            cell.invitationHandler = {
                self.invite(person: person)
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 25))
        let bgColorValue: CGFloat = 241 / 255
        view.backgroundColor = UIColor(red: bgColorValue, green: bgColorValue, blue: bgColorValue, alpha: 1)
        
        let margin: CGFloat = 16
        let titleLabel = UILabel(frame: CGRect(x: margin, y: 0, width: view.bounds.width - margin, height: view.bounds.height))
        titleLabel.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        titleLabel.font = UIFont.systemFontOfSize(12)
        let textColorValue: CGFloat = 184 / 255
        titleLabel.textColor = UIColor(red: textColorValue, green: textColorValue, blue: textColorValue, alpha: 1)
        titleLabel.text = indexes[section]
        view.addSubview(titleLabel)
        
        return view
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        if isSearchResultTableView(tableView) {
            return [""]
        } else {
            return indexes
        }
    }
    
}

extension AddressBookViewController: UISearchDisplayDelegate {
    
    func searchDisplayControllerWillBeginSearch(controller: UISearchDisplayController) {
        //    setStatusBarDark()
    }
    
    func searchDisplayControllerWillEndSearch(controller: UISearchDisplayController) {
        //    setStatusBarLight()
    }
    
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String?) -> Bool {
        
        guard let keyword = searchString else {
            searchResult = []
            return true
        }
        
        // 在索引线程搜索
        dispatch_async(indexingQueue) {
            var result = Array<AddressBook.Person>()
            for index in self.indexes {
                if let data = self.data[index] {
                    for person in data {
                        if person.name.fullName.containsString(keyword) ||
                            person.name.uppercaseStrippedLatinFullName.containsString(keyword.uppercaseString) {
                            result.append(person)
                        }
                    }
                }
            }
            
            // 切回主线程 reload
            dispatch_async(dispatch_get_main_queue()) {
                self.searchResult = result
                self.searchDisplayController?.searchResultsTableView.reloadData()
            }
        }
        
        return false
    }
    
}

extension AddressBookViewController {
    
    private func processPeople(people: [AddressBook.Person]) -> (Indexes, IndexedData) {
        var data = IndexedData()
        
        for (i, person) in people.enumerate() {
            let personNameInLatin = person.name.uppercaseStrippedLatinFullName
            
            #if debug
                print("=====> \(i+1) \(personNameInLatin)")
            #endif
            
            guard let firstChar = personNameInLatin.characters.first else {
                continue
            }
            
            let firstString = String(firstChar)
            
            let key: String
            if firstString.containsOnly(NSCharacterSet.uppercaseLetterCharacterSet()) {
                key = firstString
            } else {
                key = AddressBookMiscIndexKey
            }
            
            if data[key] == nil {
                data[key] = Array<AddressBook.Person>()
            }
            
            var peopleWithSinglePhoneNumber = Array<AddressBook.Person>()
            for phoneNumber in person.phoneNumbers {
                let singlePhoneNumberPerson = AddressBook.Person(name: person.name, phoneNumbers: [phoneNumber])
                peopleWithSinglePhoneNumber.append(singlePhoneNumberPerson)
            }
            
            data[key] = data[key]! + peopleWithSinglePhoneNumber
        }
        
        for (key, value) in data {
            data[key] = value.sort { (a, b) -> Bool in
                return a.name.uppercaseStrippedLatinFullName.localizedCaseInsensitiveCompare(b.name.uppercaseStrippedLatinFullName) == NSComparisonResult.OrderedAscending
            }
        }
        
        let keys = Array(data.keys)
        let indexes = keys.sort {
            if $0 == AddressBookMiscIndexKey {
                return false
            } else if $1 == AddressBookMiscIndexKey {
                return true
            } else {
                return $0.localizedCaseInsensitiveCompare($1) == .OrderedAscending
            }
        }
        
        return (indexes, data)
    }
    
}

extension AddressBookViewController: MFMessageComposeViewControllerDelegate {
    
    private func invite(person person: AddressBook.Person) {
        
        guard MFMessageComposeViewController.canSendText() else {
            SVProgressHUD.showWithStatus("无法发送短信")
            return
        }
        
        guard let phoneNumberString = person.phoneNumbers.first?.phoneNumberString else {
            SVProgressHUD.showWithStatus("无法添加该联系人")
            return
        }
        
        let messageComposer = MFMessageComposeViewController()
        messageComposer.recipients = [phoneNumberString]
        //    messageComposer.body = shareInfo.makeBodyText(username: delegate.name ?? "", html: false)
        messageComposer.messageComposeDelegate = self
        
        navigationController?.presentViewController(messageComposer, animated: true, completion: nil)
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        
        if result == MessageComposeResultFailed {
            SVProgressHUD.showWithStatus("邀请失败")
        }
        
        if result == MessageComposeResultCancelled {
            SVProgressHUD.showWithStatus("邀请已取消")
        }
        
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

// MARK: - UIKit Bug Workaround

extension AddressBookViewController {
    
    func searchDisplayController(controller: UISearchDisplayController, willShowSearchResultsTableView tableView: UITableView) {
        controller.searchResultsTableView.contentInset = UIEdgeInsetsZero
    }
    
}
