//
//  SystemActionCollectionViewCell.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/26.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class SystemActionCollectionViewCell: UICollectionViewCell {

    static let reuseId = "systemActionCollectionViewCell"
    static let nib = UINib(nibName: "SystemActionCollectionViewCell", bundle: nil)
    
    @IBOutlet weak var actionButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
     
        let colors = Colors()
        self.contentView.backgroundColor = colors.mainGreenColor
        self.actionButton.buttonColor(colors)
        
    }
    
    func configWithIcon(iconString: String) {
        self.actionButton.layer.cornerRadius =  (UIScreen.mainScreen().bounds.width / 5 - 15) * 0.5
        let colors = Colors()
        let icon = try? FAKFontAwesome(identifier: iconString, size: 20)
        icon?.addAttribute(NSForegroundColorAttributeName, value: colors.mainGreenColor)
        actionButton.setImage(icon?.imageWithSize(CGSize(width: 20, height: 20)), forState: .Normal)
    }
    
    func configWithString(string: String) {
        self.actionButton.layer.cornerRadius =  self.actionButton.bounds.width * 0.5
        actionButton.setTitle(string, forState: .Normal)
    }
}
