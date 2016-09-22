//
//  KeyboardManager.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/24.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

final class KeyboardManager {
    typealias KeyboardHandle = () -> Void
    
    static let sharedManager = KeyboardManager()
    static var keyboardHeight: CGFloat = 0
    static var duration: Double = 0
    static var keyboardShow: Bool = false
    
    @objc fileprivate var keyboardShowHandler: KeyboardHandle?
    @objc fileprivate var keyboardHideHandler: KeyboardHandle?
        
    init() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil,
            queue: OperationQueue.main) { notification in
                self.handleKeyboardShow(notification)
        }
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.UIKeyboardWillHide, object: nil,
            queue: OperationQueue.main) { notification in
                self.handleKeyboardHide(notification)
        }
    }
    
    func setShowHander(show: @escaping KeyboardHandle) {
        self.keyboardShowHandler = show
    }
    
    func setHideHander(hide: @escaping KeyboardHandle) {
        self.keyboardHideHandler = hide
    }
    
    
    func closeNotification() {
        SystemInfo.log("keyboard manager remove and handle")
        keyboardShowHandler = nil
        keyboardHideHandler = nil
    }
    
    fileprivate func handleKeyboardShow(_ notification: Notification) {
        if let userInfo = (notification as NSNotification).userInfo,
            let frameValue = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let durationValue = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue {
            SystemInfo.log("change frame height to \(frameValue.height)")
            if frameValue.height > 0 {
                KeyboardManager.keyboardHeight = frameValue.height
                KeyboardManager.duration = durationValue
                KeyboardManager.keyboardShow = true
                keyboardShowHandler?()
            }
        }
    }
    
    fileprivate func handleKeyboardHide(_ notification: Notification) {
        keyboardHideHandler?()
        KeyboardManager.keyboardShow = false
    }
}
