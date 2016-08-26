//
//  String+Convenient.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/26.
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

// 字符集相关
extension String {
    
    /**
     是否只包含指定字符集中的字符
     - parameter characterSet: 需要检查的字符集
     */
    func containsOnly(characterSet: NSCharacterSet) -> Bool {
        for codeUnit in utf16 {
            if !characterSet.characterIsMember(codeUnit) {
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
        if let data = dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true) {
            return NSString(data: data, encoding: NSASCIIStringEncoding) as? String
        } else {
            return nil
        }
    }
    
    private func transform(type: CFString) -> String? {
        let mutableSelf = (self as NSString).mutableCopy() as! NSMutableString
        let success = CFStringTransform(mutableSelf, nil, type, false)
        
        return success ? mutableSelf as String : nil
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
        
        (self as NSString).enumerateSubstringsInRange(NSMakeRange(0, (self as NSString).length), options: .ByComposedCharacterSequences) { (substring, _, _, stop) in
            
            guard let substring = substring else {
                return
            }
            
            if substring.isEmoji {
                result = true
                stop.initialize(true)
            }
            
        }
        
        return result
    }
    
    private var isEmoji: Bool {
        let high = (self as NSString).characterAtIndex(0)
        
        // Surrogate pair (U+1D000-1F77F)
        if (0xd800 <= high && high <= 0xdbff) {
            let low = (self as NSString).characterAtIndex(1)
            let codepoint: Int = ((Int(high) - 0xd800) * 0x400) + (Int(low) - 0xdc00) + 0x10000
            
            return (0x1d000 <= codepoint && codepoint <= 0x1f77f);
            
            // Not surrogate pair (U+2100-27BF)
        } else {
            return (0x2100 <= high && high <= 0x27bf)
        }
    }
    
}
