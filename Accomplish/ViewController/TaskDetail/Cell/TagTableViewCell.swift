//
//  TagTableViewCell.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/21.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class TagTableViewCell: MGSwipeTableCell {
    
    static let nib = UINib(nibName: "TagTableViewCell", bundle: nil)
    static let reuseId = "tagTableViewCell"
    static let rowHeight: CGFloat = 60
    
    @IBOutlet weak var selectedView: UIView!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var todayCountLabel: UILabel!
    @IBOutlet weak var currentLabel: UILabel!
    internal var cellSelected = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tagLabel.textColor = Colors.mainTextColor
        self.todayCountLabel.textColor = Colors.secondaryTextColor
        
        self.currentLabel.text = Localized("currentTag")
        self.currentLabel.isHidden = true
        
        self.layoutIfNeeded()
        self.currentLabel.textColor = Colors.cellLabelSelectedTextColor
        self.currentLabel.layer.cornerRadius = self.currentLabel.frame.height * 0.5
        self.currentLabel.layer.borderColor = Colors.cellLabelSelectedTextColor.cgColor
        self.currentLabel.layer.borderWidth = 1
        
        self.selectedView.backgroundColor = Colors.mainBackgroundColor
        self.selectedView.layer.cornerRadius = 2.0
    }
    
    func configSwipeButtons(enable: Bool) {
        if enable {
            var rightButtons = [MGSwipeButton]()
            let width: CGFloat = 65
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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            self.selectedView.backgroundColor = Colors.cellSelectedColor
        } else {
            UIView.animate(withDuration: kCellAnimationDuration, animations: { [unowned self] in
                self.selectedView.backgroundColor = Colors.mainBackgroundColor
            })
        }
        
        self.cellSelected = selected
        self.currentLabel.isHidden = !selected
        self.tagLabel.font =
            selected ? appFont(size: 14, weight: UIFontWeightBold) : appFont(size: 14)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if highlighted {
            self.selectedView.backgroundColor = Colors.cellSelectedColor
        } else {
            if !self.cellSelected {
                UIView.animate(withDuration: kCellAnimationDuration, animations: { [unowned self] in
                    self.selectedView.backgroundColor = Colors.mainBackgroundColor
                })
            }
        }
    }
    
}
