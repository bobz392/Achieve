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
        let digestPointer = digest.mutableBytes.assumingMemoryBound(to: UInt8.self)
        
        if let data = data(using: String.Encoding.utf8) {
            CC_MD5((data as NSData).bytes, CC_LONG(CC_MD5_DIGEST_LENGTH), digestPointer)
        }
        
        var result = ""
        let start = digest.bytes.assumingMemoryBound(to: UInt8.self)
        let buffer = UnsafeBufferPointer(start: start, count: Int(CC_MD5_DIGEST_LENGTH))
        for i in buffer {
            result += NSString(format: "%02x", i) as String
        }
        
        return result
    }
}

// Range
extension String {
    
    func index(_ position: Int) -> Index {
        return self.index(self.startIndex, offsetBy: position)
    }
}

// attribution
extension String {
    func addStrikethrough(fontSize: CGFloat = 16) -> NSAttributedString {
        return NSAttributedString(string: self, attributes: [
            NSAttributedString.Key.font: appFont(size: fontSize),
            NSAttributedString.Key.foregroundColor: Colors.secondaryTextColor,
            NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue,
            NSAttributedString.Key.strikethroughColor: Colors.secondaryTextColor,
            ])
    }
    
    func fixTextFieldBugString(fontSize: CGFloat, color: UIColor) -> NSAttributedString {
        return NSAttributedString(string: self, attributes: [
            NSAttributedString.Key.foregroundColor: color,
            NSAttributedString.Key.baselineOffset: 0,
            NSAttributedString.Key.font: appFont(size: fontSize)
            ]
        )
    }
}
