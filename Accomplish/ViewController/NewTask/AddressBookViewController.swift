//
//  AddressBookViewController.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/26.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit


private typealias Indexes = [String]
private typealias IndexedData = [String : [AddressBook.Person]]

private let AddressBookMiscIndexKey = "#"

final class AddressBookViewController: BaseViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    var readPhoneType = true
    weak var delegate: TaskActionDataDelegate? = nil
    
    class func loadFromNib(readPhoneType: Bool, delegate: TaskActionDataDelegate) -> AddressBookViewController {
        let address = AddressBookViewController(nibName: "AddressBookViewController", bundle: nil)
        address.readPhoneType = readPhoneType
        address.delegate = delegate
        return address
    }
    
    private var indexingQueue = dispatch_queue_create("achieve.addressBook.indexing", DISPATCH_QUEUE_SERIAL)
    
    private var indexes: Indexes = []
    private var data: IndexedData = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configMainUI()
        self.initializeControl()
        
        self.config(tableView: tableView)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        HUD.sharedHUD.show()
        
        AddressBook.fetchAllPeopleInAddressBook(self.readPhoneType, completion: { [unowned self] people in
            dispatch_async(self.indexingQueue) {
                (self.indexes, self.data) = self.processPeople(people)
                dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                    HUD.sharedHUD.dismiss()
                    self.tableView.reloadData()
                    if self.data.count == 0 {
                        guard let emptyView = EmptyView.loadNib(self) else { return }
                        self.cardView.addSubview(emptyView)
                        emptyView.layout(self.cardView)
                    }
                    
                }
            }
            })
    }
    
    private func config(tableView tableView: UITableView?) {
        let colors = Colors()
        tableView?.sectionIndexColor = colors.mainTextColor
        tableView?.sectionIndexBackgroundColor = colors.cloudColor
        tableView?.registerNib(AddressBookTableViewCell.nib, forCellReuseIdentifier: AddressBookTableViewCell.reuseId)
        tableView?.separatorStyle = .None
    }
    
    override func configMainUI() {
        let colors = Colors()
        
        self.titleLabel.textColor = colors.cloudColor
        
        self.tableView.backgroundColor = colors.cloudColor
        self.cardView.backgroundColor = colors.cloudColor
        self.view.backgroundColor = colors.mainGreenColor
        
        self.cancelButton.buttonColor(colors)
        let cancelIcon = FAKFontAwesome.arrowLeftIconWithSize(kBackButtonCorner)
        cancelIcon.addAttribute(NSForegroundColorAttributeName, value: colors.mainGreenColor)
        self.cancelButton.setAttributedTitle(cancelIcon.attributedString(), forState: .Normal)
    }
    
    private func initializeControl() {
        self.cancelButton.addShadow()
        self.cancelButton.layer.cornerRadius = kBackButtonCorner
        self.cancelButton.addTarget(self, action: #selector(self.cancelAction), forControlEvents: .TouchUpInside)
        
        self.cardView.addShadow()
        self.cardView.layer.cornerRadius = kCardViewCornerRadius
        
        self.titleLabel.text = Localized("addressBook")
    }
    
    // MARK: - action
    func cancelAction() {
        self.navigationController?.popViewControllerAnimated(true)
    }
}

extension AddressBookViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return indexes.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let index = indexes[section]
        return data[index]?.count ?? 0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let index = indexes[indexPath.section]
        
        if let person = data[index]?[indexPath.row] {
            if readPhoneType {
                delegate?.actionData(person.name.fullName, info: person.phoneNumbers.first?.phoneNumberString ?? "")
            } else {
                delegate?.actionData(person.name.fullName, info: person.mails.first ?? "")
            }
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(AddressBookTableViewCell.reuseId, forIndexPath: indexPath) as? AddressBookTableViewCell else {
            return UITableViewCell()
        }
        
        let index = indexes[indexPath.section]
        
        if let person = data[index]?[indexPath.row] {
            if readPhoneType {
                cell.nameLabel.text = person.name.fullName
                cell.phoneNumberLabel.text = person.phoneNumbers.first?.displayName ?? ""
            } else {
                cell.nameLabel.text = person.name.fullName
                cell.phoneNumberLabel.text = person.mails.first ?? ""
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 25))
        
        let colors = Colors()
        view.backgroundColor = colors.cloudColor
        
        let margin: CGFloat = 16
        let titleLabel = UILabel(frame: CGRect(x: margin, y: 0, width: view.bounds.width - margin, height: view.bounds.height))
        titleLabel.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        titleLabel.font = UIFont.systemFontOfSize(12)
        titleLabel.textColor = colors.secondaryTextColor
        titleLabel.text = indexes[section]
        view.addSubview(titleLabel)
        
        return view
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return indexes
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
            
            if readPhoneType {
                var peopleWithSinglePhoneNumber = Array<AddressBook.Person>()
                for phoneNumber in person.phoneNumbers {
                    let singlePhoneNumberPerson = AddressBook.Person(name: person.name, phoneNumbers: [phoneNumber], mails: person.mails)
                    peopleWithSinglePhoneNumber.append(singlePhoneNumberPerson)
                }
                
                data[key] = data[key]! + peopleWithSinglePhoneNumber
            } else {
                var peopleWithSignleMailAddress = Array<AddressBook.Person>()
                for mail in person.mails {
                    let singleMailPerson = AddressBook.Person(name: person.name, phoneNumbers: person.phoneNumbers, mails: [mail])
                    peopleWithSignleMailAddress.append(singleMailPerson)
                }
                
                data[key] = data[key]! + peopleWithSignleMailAddress
            }
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
