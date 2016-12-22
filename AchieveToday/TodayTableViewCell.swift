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
    
    var task: GroupTask?
    
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let cloudColor = Colors.cloudColor
        let mainTextColor = Colors.mainTextColor
        
        let uncheckImage = Icons.uncheck.iconImage()
        self.checkButton.setImage(uncheckImage, for: .normal)
        
        let checkImage = Icons.check.iconImage()
        self.checkButton.setImage(checkImage, for: .highlighted)
        
        if #available(iOS 10.0, *) {
            self.titleLabel.textColor = mainTextColor
            self.checkButton.tintColor = mainTextColor
            self.infoLabel.textColor = mainTextColor
        } else {
            self.titleLabel.textColor = cloudColor
            self.checkButton.tintColor = cloudColor
            self.infoLabel.textColor = cloudColor
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        selectedBackgroundView = UIView(frame: frame)
        if #available(iOS 10.0, *) {
            selectedBackgroundView?.backgroundColor = UIColor(red:0.93, green:0.94, blue:0.95, alpha:0.4)
        } else {
            selectedBackgroundView?.backgroundColor = UIColor(red:0.34, green:0.40, blue:0.47, alpha:1.00)
        }
        
        super.setSelected(selected, animated: animated)
    }
    
    
    func configWithTimeMethod() {
        self.checkButton.isHidden = true
        self.infoLabel.text = Localized("timeMethodRunning")
    }
}
