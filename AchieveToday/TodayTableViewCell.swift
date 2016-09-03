//
//  TodayTableViewCell.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/3.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class TodayTableViewCell: UITableViewCell {
    
    static let nib = UINib(nibName: "TodayTableViewCell", bundle: nil)
    static let reuseId = "todayTableViewCell"
    static let rowHeight: CGFloat = 40
    
    let subtaskIconSquare = "fa-square-o"
    let subtaskIconChecked = "fa-check-square-o"
    
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let colors = Colors()
        self.checkButton.tintColor = colors.cloudColor
        self.titleLabel.textColor = colors.cloudColor
        
        let icon = try! FAKFontAwesome(identifier: subtaskIconSquare, size: 22)
        let image = icon.imageWithSize(CGSize(width: 22, height: 22))
        self.checkButton.setImage(image, forState: .Normal)
        
        let hIcon = try! FAKFontAwesome(identifier: subtaskIconChecked, size: 22)
        let hImage = hIcon.imageWithSize(CGSize(width: 22, height: 22))
        self.checkButton.setImage(hImage, forState: .Highlighted)

    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        selectedBackgroundView = UIView(frame: frame)
        selectedBackgroundView?.backgroundColor = UIColor(red:0.34, green:0.40, blue:0.47, alpha:1.00)
        
        super.setSelected(selected, animated: animated)
    }
    
}
