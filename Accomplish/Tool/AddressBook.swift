//
//  AddressBook.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/26.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit
import AddressBook

typealias AddressBookAccessRequestHandler = Bool -> Void
typealias AddressBookFetchResultHandler = [AddressBook.Person] -> Void

final class AddressBook: NSObject {
    
    class func requestAccess(completion: AddressBookAccessRequestHandler) {
        showFakeRequestIfNeeded { fakeGranted in
            guard fakeGranted else {
                return
            }
            
            dispatch_async(AddressBookProcessingQueue) {
                let addressBook = ABAddressBookCreateWithOptions(nil, nil)?.takeRetainedValue()
                ABAddressBookRequestAccessWithCompletion(addressBook) { (granted, _) in
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(granted)
                    }
                }
            }
        }
    }
    
    class func fetchAllPeopleInAddressBook(completion: AddressBookFetchResultHandler) {
        
        dispatch_async(AddressBookProcessingQueue) {
            
            var result = [Person]()
            
            guard let addressBook = ABAddressBookCreateWithOptions(nil, nil)?.takeRetainedValue() else {
                completion(result)
                return
            }
            
            guard let people = ABAddressBookCopyArrayOfAllPeople(addressBook)?.takeRetainedValue() else {
                completion(result)
                return
            }
            
            let count = CFArrayGetCount(people)
            for i in 0..<count {
                let record = unsafeBitCast(CFArrayGetValueAtIndex(people, i), ABRecordRef.self)
                // [Yan Li]
                // 没有电话号码的联系人不显示
                if let phoneNumbers = PhoneNumber.fetchPhoneNumbers(inRecord: record) {
                    let name = Name(record: record)
                    let person = Person(name: name, phoneNumbers: phoneNumbers)
                    result.append(person)
                    
                    #if debug
                        print("Added: \(name) - \(phoneNumbers)")
                    #endif
                    
                } else {
                    
                    #if debug
                        let name = Name(record: record)
                        print("Ignored: \(name)")
                    #endif
                }
            }
            
            #if debug
                print("\(result.count) contacts are added.")
            #endif
            
            dispatch_async(dispatch_get_main_queue()) {
                completion(result)
            }
        }
    }
    
}

extension AddressBook {
    
    struct Constants {
        struct Fake
        {
            static let title = "需要通讯录权限"
            static let message = "石墨文档需要获得通讯录的读取权限以邀请通讯录中的联系人。"
            static let grant = "允许"
            static let cancel = "拒绝"
        }
        
        struct Real {
            static let title = "没有权限"
            static let message = "石墨文档目前没有读取通讯录的权限，该权限可以在“系统设置 > 隐私 > 联系人”中开启。"
            static let cancel = "好的"
        }
    }
    
    struct Person {
        let name: Name
        let phoneNumbers: [PhoneNumber]
    }
    
    struct Name {
        let fullName: String
        let uppercaseStrippedLatinFullName: String
        
        init(record: ABRecordRef) {
            var nameComponents = [String]()
            
            if let firstName = ABRecordCopyValue(record, kABPersonFirstNameProperty)?.takeRetainedValue() as? String {
                nameComponents.append(firstName)
            }
            
            if let middleName = ABRecordCopyValue(record, kABPersonMiddleNameProperty)?.takeRetainedValue() as? String {
                nameComponents.append(middleName)
            }
            
            if let lastName = ABRecordCopyValue(record, kABPersonLastNameProperty)?.takeRetainedValue() as? String {
                nameComponents.append(lastName)
            }
            
            let delimiter: String
            if let nameDelimiter = ABPersonCopyCompositeNameDelimiterForRecord(record)?.takeRetainedValue() {
                delimiter = unsafeBitCast(nameDelimiter, NSString.self) as String
            } else {
                delimiter = ""
            }
            
            let nameFormat = Int(ABPersonGetCompositeNameFormatForRecord(record))
            switch nameFormat {
            case kABPersonCompositeNameFormatFirstNameFirst:
                fullName = nameComponents.joinWithSeparator(delimiter)
                
            case kABPersonCompositeNameFormatLastNameFirst:
                fullName = nameComponents.reverse().joinWithSeparator(delimiter)
                
            default:
                fullName = ""
            }
            
            uppercaseStrippedLatinFullName = fullName.latinString?.ASCIIString?.uppercaseString ?? ""
        }
    }
    
    struct PhoneNumber {
        let label: String?
        let phoneNumberString: String
        
        var displayName: String {
            if let label = label {
                return "\(label) \(phoneNumberString)"
            } else {
                return phoneNumberString
            }
        }
        
        static func fetchPhoneNumbers(inRecord record: ABRecordRef) -> [PhoneNumber]? {
            guard let phoneValue = ABRecordCopyValue(record, kABPersonPhoneProperty)?.takeRetainedValue() else {
                return nil
            }
            
            let phoneNumberCount = ABMultiValueGetCount(phoneValue)
            guard phoneNumberCount > 0 else {
                return nil
            }
            
            var phoneNumbers = [PhoneNumber]()
            
            for j in 0..<phoneNumberCount {
                guard let phoneNumberString = ABMultiValueCopyValueAtIndex(phoneValue, j)?.takeRetainedValue() as? String else {
                    continue
                }
                
                let phoneLabel = ABMultiValueCopyLabelAtIndex(phoneValue, j)?.takeRetainedValue()
                let phoneLabelString: String?
                if let phoneLabelLocalized = ABAddressBookCopyLocalizedLabel(phoneLabel)?.takeRetainedValue() {
                    phoneLabelString = unsafeBitCast(phoneLabelLocalized, NSString.self) as String
                } else {
                    phoneLabelString = nil
                }
                
                let phoneNumber = PhoneNumber(label: phoneLabelString, phoneNumberString: phoneNumberString)
                phoneNumbers.append(phoneNumber)
            }
            
            return phoneNumbers
        }
    }
}

private let AddressBookProcessingQueue = dispatch_queue_create("com.zhoubo.AddressBook", DISPATCH_QUEUE_SERIAL)

extension AddressBook {
    
    private class func showFakeRequestIfNeeded(completion: AddressBookAccessRequestHandler) {
        guard ABAddressBookGetAuthorizationStatus() == .NotDetermined else {
            completion(true)
            return
        }
        
        let alertView = UIAlertView(title: Constants.Fake.title,
                                    message: Constants.Fake.message,
                                    delegate: AddressBookAlertViewDelegate,
                                    cancelButtonTitle: Constants.Fake.cancel,
                                    otherButtonTitles: Constants.Fake.grant)
        
        AddressBookAlertViewDelegate.completion = completion
        
        alertView.show()
    }
    
}

private class AlertViewDelegate: NSObject, UIAlertViewDelegate {
    
    var completion: AddressBookAccessRequestHandler?
    
    @objc private func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        completion?(buttonIndex == 1)
    }
    
}

private let AddressBookAlertViewDelegate = AlertViewDelegate()
