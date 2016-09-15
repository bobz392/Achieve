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
    
    var task: [String]?
    let subtaskIconSquare = "fa-square-o"
    let subtaskIconChecked = "fa-check-square-o"
    
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let cloudColor = UIColor(red:0.93, green:0.94, blue:0.95, alpha:1.00)
        
        self.titleLabel.textColor = cloudColor
        self.checkButton.tintColor = cloudColor
        
        let icon = try! FAKFontAwesome(identifier: subtaskIconSquare, size: 22)
        let image = icon.image(with: CGSize(width: 22, height: 22))
        self.checkButton.setImage(image, for: UIControlState())
        
        let hIcon = try! FAKFontAwesome(identifier: subtaskIconChecked, size: 22)
        let hImage = hIcon.image(with: CGSize(width: 22, height: 22))
        self.checkButton.setImage(hImage, for: .highlighted)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        selectedBackgroundView = UIView(frame: frame)
        selectedBackgroundView?.backgroundColor = UIColor(red:0.34, green:0.40, blue:0.47, alpha:1.00)
        
        super.setSelected(selected, animated: animated)
    }
    
}
