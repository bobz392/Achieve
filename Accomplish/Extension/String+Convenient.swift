//
//  String+Convenient.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/26.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation

// Date
extension String {
    func dateFromCreatedFormatString() -> NSDate {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = CreatedDateFormat
        dateFormatter.calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let d = dateFormatter.date(from: self) ?? Date()
        
        return d as NSDate
    }
    
    func dateFromString(_ format: String) -> NSDate {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let d = dateFormatter.date(from: self) ?? Date()
        
        return d as NSDate
    }
    

    func optionalDateFromString(_ format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        return dateFormatter.date(from: self)
    }
}

// counting
extension String {
    func isEmpty() -> Bool {
        return self.characters.count <= 0
    }
    
    func length() -> Int {
        return self.characters.count
    }
}

// Subscript
extension String {
    subscript (r: Range<Int>) -> String {
        get {
            let startIndex = self.characters.index(self.startIndex, offsetBy: r.lowerBound)
            let endIndex = self.characters.index(self.startIndex, offsetBy: r.upperBound)
            
            return self[Range(startIndex ..< endIndex)]
        }
    }
    
    subscript (r: NSRange) -> String {
        get {
            let startIndex = self.characters.index(self.startIndex, offsetBy: r.location)
            let endIndex = self.characters.index(self.startIndex, offsetBy: r.length + r.location)
            return self[Range(startIndex ..< endIndex)]
        }
    }
    
    subscript (p: Int) -> String {
        get {
            let startIndex = self.characters.index(self.startIndex, offsetBy: p)
            let endIndex = self.characters.index(self.startIndex, offsetBy: p + 1)
            
            return self[Range(startIndex ..< endIndex)]
        }
    }
    
}

// 字符集相关
extension String {
    
    /**
     是否只包含指定字符集中的字符
     - parameter characterSet: 需要检查的字符集
     */
    func containsOnly(_ characterSet: CharacterSet) -> Bool {
        for codeUnit in utf16 {
            if !characterSet.contains(UnicodeScalar(codeUnit)!) {
                return false
            }
        }
        
        return true
    }
    
}

// 字符串的各种变换
extension String {
    
    /**
     把当前字符串变换成拉丁字符串，例如：`你好` -> `nǐ hǎo`
     */
    var latinString: String? {
        return transform(kCFStringTransformToLatin)
    }
    
    /**
     把当前字符串变换成 ASCII 字符串，例如：`nǐ hǎo` -> `ni hao`
     */
    var ASCIIString: String? {
        if let data = data(using: String.Encoding.ascii, allowLossyConversion: true) {
            return NSString(data: data, encoding: String.Encoding.ascii.rawValue) as? String
        } else {
            return nil
        }
    }
    
    fileprivate func transform(_ type: CFString) -> String? {
        let mutableSelf = (self as NSString).mutableCopy() as! NSMutableString
        let success = CFStringTransform(mutableSelf, nil, type, false)
        
        return success ? mutableSelf as String : nil
    }
    
}

extension String {
    func intValue() -> Int? {
        return Int(self)
    }
}

// Emoji 相关
// See: https://github.com/woxtu/NSString-RemoveEmoji/blob/master/NSString%2BRemoveEmoji/NSString%2BRemoveEmoji.m
extension String {
    
    /**
     当前字符串是否包含了 emoji
     */
    var containsEmoji: Bool {
        var result = false
        
        (self as NSString).enumerateSubstrings(in: NSMakeRange(0, (self as NSString).length), options: .byComposedCharacterSequences) { (substring, _, _, stop) in
            
            guard let substring = substring else {
                return
            }
            
            if substring.isEmoji {
                result = true
                stop.initialize(to: true)
            }
            
        }
        
        return result
    }
    
    fileprivate var isEmoji: Bool {
        let high = (self as NSString).character(at: 0)
        
        // Surrogate pair (U+1D000-1F77F)
        if (0xd800 <= high && high <= 0xdbff) {
            let low = (self as NSString).character(at: 1)
            let codepoint: Int = ((Int(high) - 0xd800) * 0x400) + (Int(low) - 0xdc00) + 0x10000
            
            return (0x1d000 <= codepoint && codepoint <= 0x1f77f);
            
            // Not surrogate pair (U+2100-27BF)
        } else {
            return (0x2100 <= high && high <= 0x27bf)
        }
    }
    
}
