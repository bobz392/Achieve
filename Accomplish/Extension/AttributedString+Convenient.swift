//
//  AttributedString+Convenient.swift
//  Accomplish
//
//  Created by zhoubo on 2017/1/4.
//  Copyright © 2017年 zhoubo. All rights reserved.
//

import Foundation

extension NSAttributedString {
    
    func searchHintString(search: String) -> NSAttributedString {
        let mu = NSMutableAttributedString(attributedString: self)
        let range = NSString(string: self.string).range(of: search)
        
        mu.addAttributes([NSAttributedString.Key.backgroundColor: Colors.searchBackgroundColor], range: range)
        
        return mu
    }
    
}
