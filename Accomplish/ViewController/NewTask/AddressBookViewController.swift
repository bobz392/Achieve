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
    
    class func loadFromNib(_ readPhoneType: Bool, delegate: TaskActionDataDelegate) -> AddressBookViewController {
        let address = AddressBookViewController(nibName: "AddressBookViewController", bundle: nil)
        address.readPhoneType = readPhoneType
        address.delegate = delegate
        return address
    }
    
    fileprivate var indexingQueue = DispatchQueue(label: "achieve.addressBook.indexing")
    
    fileprivate var indexes: Indexes = []
    fileprivate var data: IndexedData = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configMainUI()
        self.initializeControl()
        
        self.config(tableView: tableView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        HUD.shared.showProgress(Localized("loading"))
        
        AddressBook.fetchAllPeopleInAddressBook(self.readPhoneType, completion: { [unowned self] people in
            self.indexingQueue.async {
                (self.indexes, self.data) = self.processPeople(people)
                DispatchQueue.main.async { [unowned self] in
                    HUD.shared.dismiss()
                    self.tableView.reloadData()
                    if self.data.count == 0 {
                        guard let emptyView = EmptyView.loadNib(self) else { return }
                        self.cardView.addSubview(emptyView)
                        emptyView.layout(superview: self.cardView)
                    }
                    
                }
            }
            })
    }
    
    fileprivate func config(tableView: UITableView?) {
        tableView?.sectionIndexColor = Colors.mainTextColor
        tableView?.sectionIndexBackgroundColor = Colors.cloudColor
        tableView?.register(AddressBookTableViewCell.nib, forCellReuseIdentifier: AddressBookTableViewCell.reuseId)
        tableView?.separatorStyle = .none
    }
    
    override func configMainUI() {
        let colors = Colors()
        
        self.titleLabel.textColor = Colors.cloudColor
        self.tableView.backgroundColor = Colors.cloudColor
        self.cardView.backgroundColor = Colors.cloudColor
        self.view.backgroundColor = colors.mainGreenColor
        
        self.cancelButton.buttonColor(colors)
        self.cancelButton.createIconButton(iconSize: kBackButtonCorner,
                                           icon: backButtonIconString,
                                           color: colors.mainGreenColor, status: .normal)
        
        self.tableView.reloadData()
    }
    
    fileprivate func initializeControl() {
        self.cancelButton.addShadow()
        self.cancelButton.layer.cornerRadius = kBackButtonCorner
        self.cancelButton.addTarget(self, action: #selector(self.backAction), for: .touchUpInside)
        
        self.cardView.addShadow()
        self.cardView.layer.cornerRadius = kCardViewCornerRadius
        
        self.titleLabel.text = Localized("addressBook")
    }
    
    // MARK: - action
    func backAction() {
        let _ = self.navigationController?.popViewController(animated: true)
    }
}

extension AddressBookViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return indexes.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let index = indexes[section]
        return data[index]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let index = indexes[indexPath.section]
        
        if let person = data[index]?[indexPath.row] {
            if readPhoneType {
                delegate?.actionData(person.name.fullName, info: person.phoneNumbers.first?.phoneNumberString ?? "")
            } else {
                delegate?.actionData(person.name.fullName, info: person.mails.first ?? "")
            }
            
            guard let nav = self.navigationController else {
                return
            }
            nav.popViewController(animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AddressBookTableViewCell.reuseId, for: indexPath) as? AddressBookTableViewCell else {
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 25))
        
        view.backgroundColor = Colors.cloudColor
        
        let margin: CGFloat = 16
        let titleLabel = UILabel(frame: CGRect(x: margin, y: 0, width: view.bounds.width - margin, height: view.bounds.height))
        titleLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        titleLabel.textColor = Colors.secondaryTextColor
        titleLabel.text = indexes[section]
        view.addSubview(titleLabel)
        
        return view
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return indexes
    }
    
}

extension AddressBookViewController {
    
    fileprivate func processPeople(_ people: [AddressBook.Person]) -> (Indexes, IndexedData) {
        var data = IndexedData()
        
        for (i, person) in people.enumerated() {
            let personNameInLatin = person.name.uppercaseStrippedLatinFullName
            Logger.log("=====> \(i+1) \(personNameInLatin)")
            guard let firstChar = personNameInLatin.characters.first else {
                continue
            }
            
            let firstString = String(firstChar)
            
            let key: String
            if firstString.containsOnly(CharacterSet.uppercaseLetters) {
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
            data[key] = value.sorted { (a, b) -> Bool in
                return a.name.uppercaseStrippedLatinFullName.localizedCaseInsensitiveCompare(b.name.uppercaseStrippedLatinFullName) == ComparisonResult.orderedAscending
            }
        }
        
        let keys = Array(data.keys)
        let indexes = keys.sorted {
            if $0 == AddressBookMiscIndexKey {
                return false
            } else if $1 == AddressBookMiscIndexKey {
                return true
            } else {
                return $0.localizedCaseInsensitiveCompare($1) == .orderedAscending
            }
        }
        
        return (indexes, data)
    }
}
