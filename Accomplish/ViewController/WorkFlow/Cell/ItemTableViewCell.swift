//
//  ItemTableViewCell.swift
//  Accomplish
//
//  Created by zhoubo on 16/11/24.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class ItemTableViewCell: BaseTableViewCell {

    static let nib = UINib(nibName: "ItemTableViewCell", bundle: nil)
    static let reuseId = "itemTableViewCell"
    static let rowHeight: CGFloat = 38
    
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let colors = Colors()
        self.itemNameLabel.textColor = Colors.mainTextColor
        self.itemNameLabel.tintColor = colors.mainGreenColor
        self.itemTimeLabel.textColor = Colors.secondaryTextColor
    }
 
    func configCell(item: TimeMethodItem) {
        self.itemNameLabel.text = item.name
        self.itemTimeLabel.text = "\(item.interval)" + Localized("min")
    }
    
}
