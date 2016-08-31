//
//  KeyboardManager.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/24.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

final class KeyboardManager {
    
    static let sharedManager = KeyboardManager()
    
    static var keyboardHeight: CGFloat = 0
    static var duration: Double = 0
    static var keyboardShow: Bool = false
    
    var keyboardShowHandler: ( () -> Void)?
    var keyboardHideHandler: (() -> Void)?
    
    init() {
        NSNotificationCenter.defaultCenter().addObserverForName(
            UIKeyboardWillChangeFrameNotification, object: nil,
            queue: NSOperationQueue.mainQueue()) { notification in
                self.handleKeyboardShow(notification)
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(
            UIKeyboardWillHideNotification, object: nil,
            queue: NSOperationQueue.mainQueue()) { notification in
                self.handleKeyboardHide(notification)
        }
    }
    
    func closeNotification() {
        print("keyboard manager remove and handle")
        keyboardShowHandler = nil
        keyboardHideHandler = nil
    }
    
    private func handleKeyboardShow(notification: NSNotification) {
        if let userInfo = notification.userInfo,
            let frameValue = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue,
            let durationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue {
            //            print("change frame height to \(frameValue.height)")
            if frameValue.height > 0 {
                KeyboardManager.keyboardHeight = frameValue.height
                KeyboardManager.duration = durationValue
                KeyboardManager.keyboardShow = true
                keyboardShowHandler?()
            }
        }
    }
    
    private func handleKeyboardHide(notification: NSNotification) {
        keyboardHideHandler?()
        KeyboardManager.keyboardShow = false
    }
}