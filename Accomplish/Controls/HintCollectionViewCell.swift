//
//  HintCollectionViewCell.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/16.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class HintCollectionViewCell: UICollectionViewCell {

    static let nib = UINib(nibName: "HintCollectionViewCell", bundle: nil)
    static let reuseId = "hintCollectionViewCell"
    
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var hintLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
