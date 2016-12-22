//
//  AddressBookTableViewCell.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/26.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

final class AddressBookTableViewCell: UITableViewCell {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var phoneNumberLabel: UILabel!
    
    static var reuseId: String {
        return "AddressBookTableViewCell"
    }
    
    static var nib: UINib {
        return UINib(nibName: "AddressBookTableViewCell", bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        self.backgroundColor = Colors.cloudColor
        self.contentView.backgroundColor = Colors.cloudColor
    }
}
