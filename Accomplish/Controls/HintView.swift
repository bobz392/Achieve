//
//  HintView.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/8.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

let hintIconButtonSize: CGFloat = 18

class HintView: UIView {

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    class func loadNib(_ target: AnyObject) -> HintView? {
        return Bundle.main.loadNibNamed("HintView", owner: target, options: nil)?.first as? HintView
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let colors = Colors()
        self.titleLabel.textColor = colors.mainTextColor
        self.closeButton.createIconButton(iconSize: hintIconButtonSize, imageSize: hintIconButtonSize, icon: "fa-times", color: colors.mainGreenColor, status: .normal)
        
        self.nextButton.createIconButton(iconSize: hintIconButtonSize, imageSize: hintIconButtonSize, icon: "fa-arrow-right", color: colors.mainGreenColor, status: .normal)
        
        self.collectionView.clearView()
        self.pageControl.tintColor = colors.mainGreenColor
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: screenBounds.width, height: 80)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets.zero
        layout.scrollDirection = .horizontal
        
        self.collectionView.collectionViewLayout = layout
    }
    
}
