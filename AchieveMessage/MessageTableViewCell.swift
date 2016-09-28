//
//  MessageTableViewCell.swift
//  Accomplish
//
//  Created by zhoubo on 2016/9/29.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {
    
    typealias MessageBlock = (_ text: String) -> Void
    
    static let nib = UINib(nibName: "MessageTableViewCell", bundle: nil)
    static let reuseId = "messageTableViewCell"
    static let rowHeight: CGFloat = 60
    
    @IBOutlet weak var contentCardView: UIView!
    @IBOutlet weak var taskTitleLabel: UILabel!
    @IBOutlet weak var taskDateLabel: UILabel!
    @IBOutlet weak var selectButton: UIButton!
    
    var messageBlock: MessageBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let colors = MessageColors()
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        
        self.contentCardView.backgroundColor = UIColor.clear
        self.selectButton.backgroundColor = colors.cloudColor
        self.selectButton.layer.cornerRadius = 12.0
        self.selectButton.clipsToBounds = true
        self.selectButton.tintColor = UIColor.clear
        self.selectButton
            .setBackgroundImage(self.colorToImage(color: colors.cloudColor),
                                for: .normal)
        self.selectButton
            .setBackgroundImage(self.colorToImage(color: colors.selectedColor),
                                for: .highlighted)
        
        self.selectButton.addTarget(self, action: #selector(self.sendAction), for: .touchUpInside)
        
        self.layoutMargins = UIEdgeInsets.zero
    }
    
    func sendAction() {
        guard let title = self.taskTitleLabel.text,
            let date = self.taskDateLabel.text else {
                return
        }
        let text = String(format: Localized("shareMessage"), title, date)
        self.messageBlock?(text)
    }
    
    func colorToImage(color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        context.setFillColor(color.cgColor)
        context.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
