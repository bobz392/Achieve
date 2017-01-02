//
//  ItemTableViewCell.swift
//  Accomplish
//
//  Created by zhoubo on 16/11/24.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class ItemTableViewCell: MGSwipeTableCell {
    
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
    
    func configCell(item: TimeMethodItem, swipeEnable: Bool) {
        self.itemNameLabel.text = item.name
        self.itemTimeLabel.text = "\(item.interval)" + Localized("min")
        
        if swipeEnable {
            var rightButtons = [MGSwipeButton]()
            let width: CGFloat = 45
            let deleteImage = Icons.delete.iconImage()
            let deleteButton = MGSwipeButton(title: "",
                                             icon: deleteImage,
                                             backgroundColor: Colors.swipeRedBackgroundColor,
                                             callback: nil)
            deleteButton.tintColor = Colors.cellCardColor
            deleteButton.buttonWidth = width
            rightButtons.append(deleteButton)
            
            self.rightButtons = rightButtons
        } else {
            self.rightButtons.removeAll()
        }
    }
    
}
