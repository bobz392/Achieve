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
    
    fileprivate let addressTableView = UITableView()
    
    var readPhoneType = true
    weak var delegate: TaskActionDataDelegate? = nil
    
//    class func loadFromNib(_ readPhoneType: Bool, delegate: TaskActionDataDelegate) -> AddressBookViewController {
//        let address = AddressBookViewController(nibName: "AddressBookViewController", bundle: nil)
//        address.readPhoneType = readPhoneType
//        address.delegate = delegate
//        return address
//    }
    
    fileprivate var indexingQueue = DispatchQueue(label: "achieve.addressBook.indexing")
    
    fileprivate var indexes: Indexes = []
    fileprivate var data: IndexedData = [:]
    
    init(readPhoneType: Bool, delegate: TaskActionDataDelegate) {
        self.readPhoneType = readPhoneType
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configMainUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        HUD.shared.showProgress(Localized("loading"))
        
        AddressBook.fetchAllPeopleInAddressBook(self.readPhoneType, completion: { [unowned self] people in
            self.indexingQueue.async {
                (self.indexes, self.data) = self.processPeople(people)
                DispatchQueue.main.async { [unowned self] in
                    HUD.shared.dismiss()
                    self.addressTableView.reloadData()
                    if self.data.count == 0 {
                        guard let emptyView = EmptyView.loadNib(self) else { return }
                        self.view.addSubview(emptyView)
                        emptyView.layout(superview: self.view)
                    }
                    
                }
            }
            })
    }
    
    override func configMainUI() {
        self.view.backgroundColor = Colors.mainBackgroundColor
        let bar = self.createCustomBar(height: kBarHeight, withBottomLine: true)
        let backButton = self.createLeftBarButton(icon: Icons.back)
        backButton.addTarget(self, action: #selector(self.backAction), for: .touchUpInside)
        
        self.createTitleLabel(titleText: Localized("addressBook"))
        
        self.view.addSubview(self.addressTableView)
        self.addressTableView.delegate = self
        self.addressTableView.dataSource = self
        self.addressTableView.backgroundColor = Colors.mainBackgroundColor
        self.addressTableView.tableFooterView = UIView()
        self.addressTableView.sectionIndexColor = Colors.mainTextColor
        self.addressTableView.sectionIndexBackgroundColor = Colors.mainBackgroundColor
        self.addressTableView.register(AddressBookTableViewCell.nib,
                                       forCellReuseIdentifier: AddressBookTableViewCell.reuseId)
        self.addressTableView.separatorStyle = .none
        self.addressTableView.snp.makeConstraints { (make) in
            make.top.equalTo(bar.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
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
        titleLabel.font = appFont(size: 12)
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
            guard let firstChar = personNameInLatin.first else {
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
