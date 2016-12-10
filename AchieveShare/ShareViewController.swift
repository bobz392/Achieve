//
//  ShareViewController.swift
//  AchieveShare
//
//  Created by zhoubo on 16/12/4.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices

class ShareViewController: SLComposeServiceViewController {
    
    private var contentType = ShareContentType.Unknown
    
    /**
     - 如果是 url，那么直接是可以通过
     - 如果是文字，那么需要字数大于0
     */
    override func isContentValid() -> Bool {
        if self.contentType == .URL {
            return true
        } else if self.contentType == .PlainText {
            return self.textView.text.characters.count > 0
        } else {
            guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
                let provider = extensionItem.attachments?.first as? NSItemProvider,
                let dataType = provider.registeredTypeIdentifiers.first as? String else {
                    self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
                    return false
            }
            
            if dataType == String(kUTTypePlainText) {
                self.contentType = .PlainText
                return self.textView.text.characters.count > 0
            } else if dataType == String(kUTTypeURL) {
                self.contentType = .URL
                return true
            } else {
                return false
            }
        }
    }
    
    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
        
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.

        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
            let provider = extensionItem.attachments?.first as? NSItemProvider,
            let dataType = provider.registeredTypeIdentifiers.first as? String,
            let userDefault = GroupUserDefault() else {
                return self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
        }
        let name = self.textView.text ?? ""
        let type = self.contentType.rawValue
        
        provider.loadItem(forTypeIdentifier: dataType, options: nil, completionHandler: { [unowned self] (text, error) in
            print("================")
            print("item type \(dataType), text = \(text)")
            print("================")
            var content = ""
            if dataType == String(kUTTypePlainText) {
                if let t = text as? String {
                    content = t
                }
            } else if dataType == String(kUTTypeURL) {
                if let u = text as? URL {
                    content = u.absoluteString
                }
            } else {
                self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                return
            }
            
//            print("self.childViewControllers = \(self.childViewControllers)")
//            if let first = self.childViewControllers.first {
//                first.removeFromParentViewController()
//                let shadowView = UIView(frame: )
//                UIView.animate(withDuration: 0.15, animations: {
//                    self.shadowView.alpha = 0.8
//                }, completion: { (finish) in
//                    
//                })
//            }
            userDefault.writeReadLaterOrTask(name: name, content: content, type: type)
            self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
        })
    }
    
    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        guard self.isContentValid() else { return [] }
        
        switch self.contentType {
        case .PlainText:
            let itemTask = SLComposeSheetConfigurationItem()!
            itemTask.value = Localized("shareTask")
            
//            let itemNote = SLComposeSheetConfigurationItem()!
//            itemNote.title = Localized("shareNote")
//            itemNote.value = Localized("taskNote")
//            itemNote.tapHandler = { () -> Void in
//            
//            }
            
            return [itemTask]//, itemNote]
            
        case .URL:
            let item = SLComposeSheetConfigurationItem()!
            item.value = Localized("createReadLater")
            return [item]
            
        default:
            return []
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        let colors = ShareColors()
        let titleLabel =
            UILabel(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 100, height: 30)))
        titleLabel.text = "Achieve"
        titleLabel.font = UIFont(name: "Chalkduster", size: 18)
        titleLabel.textColor = colors.cloudColor
        titleLabel.textAlignment = .center
        
        self.navigationItem.titleView = titleLabel
        self.navigationController?.navigationBar.topItem?.titleView = titleLabel
        self.navigationController?.navigationBar.tintColor = colors.cloudColor
        self.navigationController?.navigationBar.backgroundColor = colors.greenColor
    }
 
}
