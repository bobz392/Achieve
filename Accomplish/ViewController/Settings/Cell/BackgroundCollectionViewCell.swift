//
//  BackgroundCollectionViewCell.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/11.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class BackgroundCollectionViewCell: UICollectionViewCell {
    
    static let nib = UINib(nibName: "BackgroundCollectionViewCell", bundle: nil)
    static let reuseId = "backgroundCollectionViewCell"
    
    @IBOutlet weak var checkImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.checkImageView.createIconImage(iconSize: 32, imageSize: 32, icon: "fa-check-circle-o", color: Colors().cloudColor)
    }

}
