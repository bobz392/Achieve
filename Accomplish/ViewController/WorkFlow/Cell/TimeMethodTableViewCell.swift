//
//  TimeMethodTableViewCell.swift
//  Accomplish
//
//  Created by zhoubo on 16/11/2.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class TimeMethodTableViewCell: MGSwipeTableCell {
    
    static let nib = UINib(nibName: "TimeMethodTableViewCell", bundle: nil)
    static let reuseId = "timeMethodTableViewCell"
    static let rowHeight: CGFloat = 70

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timesLabel: UILabel!
    @IBOutlet weak var cellCardView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.nameLabel.textColor = Colors.mainTextColor
        self.timesLabel.textColor = Colors.secondaryTextColor
        self.cellCardView.layer.cornerRadius = 4
        self.cellCardView.addCardShadow()
        
        self.rightSwipeSettings.transition = .drag
        self.rightSwipeSettings.topMargin = 12
        self.rightSwipeSettings.bottomMargin = 0
        self.touchOnDismissSwipe = true
    }
    
    func configCell(method: TimeMethod, enableSwipe: Bool) {
        self.nameLabel.text = method.name
        self.timesLabel.text =
            String(format: Localized(method.useTimes > 1 ? "useTimes" : "useTime"), method.useTimes)
        
        if enableSwipe {
            var rightButtons = [MGSwipeButton]()
            let width: CGFloat = 65
            let deleteImage = Icons.delete.iconImage()
            let deleteButton = MGSwipeButton(title: "",
                                             icon: deleteImage,
                                             backgroundColor: Colors.deleteButtonBackgroundColor,
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
            self.cellCardView.backgroundColor = Colors.cellCardSelectedColor
        } else {
            UIView.animate(withDuration: kCellAnimationDuration, animations: { [unowned self] in
                self.cellCardView.backgroundColor = Colors.cellCardColor
            })
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if highlighted {
            self.cellCardView.backgroundColor = Colors.cellCardSelectedColor
        } else {
            UIView.animate(withDuration: kCellAnimationDuration, animations: { [unowned self] in
                self.cellCardView.backgroundColor = Colors.cellCardColor
            })
        }
    }

}
