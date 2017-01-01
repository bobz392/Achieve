//
//  String+ConvenientMain.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/3.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation

// Hash
extension String {
    var MD5String: String {
        let digest = NSMutableData(length: Int(CC_MD5_DIGEST_LENGTH))!
        let digestPointer = unsafeBitCast(digest.mutableBytes, to: UnsafeMutablePointer<UInt8>.self)
        
        if let data = data(using: String.Encoding.utf8) {
            CC_MD5((data as NSData).bytes, CC_LONG(CC_MD5_DIGEST_LENGTH), digestPointer)
        }
        
        var result = ""
        let start = unsafeBitCast(digest.bytes, to: UnsafePointer<UInt8>.self)
        let buffer = UnsafeBufferPointer(start: start, count: Int(CC_MD5_DIGEST_LENGTH))
        for i in buffer {
            result += NSString(format: "%02x", i) as String
        }
        
        return result
    }
}

// Range
extension String {
    func subRange(_ start: Int, end: Int) -> Range<Index> {
        let startIndex = self.characters.index(self.startIndex, offsetBy: start)
        let endIndex = self.characters.index(self.startIndex, offsetBy: end)
        return Range(startIndex ..< endIndex)
    }
    
    func index(_ position: Int) -> Index {
        return self.characters.index(self.startIndex, offsetBy: position)
    }
    
    mutating func replace(_ range: NSRange, replacement: String) {
        let startIndex = self.characters.index(self.startIndex, offsetBy: range.location)
        let endIndex = self.characters.index(self.startIndex, offsetBy: range.location + range.length)
        let newRange = Range(startIndex ..< endIndex)
        replaceSubrange(newRange, with: replacement)
        
    }
}

// attribution
extension String {
    func addStrikethrough(fontSize: CGFloat = 16) -> NSAttributedString {
        return NSAttributedString(string: self, attributes: [
            NSFontAttributeName: UIFont.systemFont(ofSize: fontSize),
            NSForegroundColorAttributeName: Colors.secondaryTextColor,
            NSStrikethroughStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue,
            NSStrikethroughColorAttributeName: Colors.secondaryTextColor,
            ])
    }
    
    func fixTextFieldBugString(fontSize: CGFloat, color: UIColor) -> NSAttributedString {
        return NSAttributedString(string: self, attributes: [
            NSForegroundColorAttributeName: color,
            NSBaselineOffsetAttributeName: 0,
            NSFontAttributeName: UIFont.systemFont(ofSize: fontSize)
            ]
        )
    }
}
