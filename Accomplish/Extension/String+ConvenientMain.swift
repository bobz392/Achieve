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
        let digestPointer = unsafeBitCast(digest.mutableBytes, UnsafeMutablePointer<UInt8>.self)
        
        if let data = dataUsingEncoding(NSUTF8StringEncoding) {
            CC_MD5(data.bytes, CC_LONG(CC_MD5_DIGEST_LENGTH), digestPointer)
        }
        
        var result = ""
        let start = unsafeBitCast(digest.bytes, UnsafePointer<UInt8>.self)
        let buffer = UnsafeBufferPointer(start: start, count: Int(CC_MD5_DIGEST_LENGTH))
        for i in buffer {
            result += NSString(format: "%02x", i) as String
        }
        
        return result
    }
}

// Range
extension String {
    func subRange(start: Int, end: Int) -> Range<Index> {
        let startIndex = self.startIndex.advancedBy(start)
        let endIndex = self.startIndex.advancedBy(end)
        return Range(startIndex ..< endIndex)
    }
    
    func index(position: Int) -> Index {
        return self.startIndex.advancedBy(position)
    }
    
    mutating func replace(range: NSRange, replacement: String) {
        let startIndex = self.startIndex.advancedBy(range.location)
        let endIndex = self.startIndex.advancedBy(range.location + range.length)
        let newRange = Range(startIndex ..< endIndex)
        replaceRange(newRange, with: replacement)
        
    }
}

// attribution
extension String {
    func addStrikethrough() -> NSAttributedString {
        let colors = Colors()
        return NSAttributedString(string: self, attributes: [
            NSForegroundColorAttributeName: colors.secondaryTextColor,
            NSStrikethroughStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue,
            NSStrikethroughColorAttributeName: colors.secondaryTextColor,
            ])
    }
}