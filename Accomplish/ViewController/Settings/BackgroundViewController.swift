//
//  BackgroundViewController.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/11.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class BackgroundViewController: BaseViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var backButton: AwesomeButton!
    @IBOutlet weak var backgroundCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.configMainUI()
        self.initializeControl()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func configMainUI() {
        let colors = Colors()
        debugPrint(Colors.backgroundType)
        self.titleLabel.textColor = colors.cloudColor
        
        self.cardView.backgroundColor = colors.cloudColor
        self.view.backgroundColor = colors.mainGreenColor
        
        self.backButton.buttonColor(colors)
        self.backButton.createIconButton(iconSize: kBackButtonCorner, imageSize: kBackButtonCorner,
                                         icon: backButtonIconString, color: colors.mainGreenColor,
                                         status: .Normal)
    }
    
    private func initializeControl() {
        self.backButton.addShadow()
        self.backButton.layer.cornerRadius = kBackButtonCorner
        self.backButton.addTarget(self, action: #selector(self.cancelAction), forControlEvents: .TouchUpInside)
        
        self.cardView.addShadow()
        self.cardView.layer.cornerRadius = kCardViewCornerRadius
        
        self.titleLabel.text = Localized("background")
        
        self.backgroundCollectionView.clearView()
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .Vertical
        let width: CGFloat = ( screenBounds.width - 50 - 50) * 0.25
        layout.itemSize = CGSize(width: width, height: width)
        self.backgroundCollectionView.collectionViewLayout = layout
        
        self.backgroundCollectionView.registerNib(BackgroundCollectionViewCell.nib, forCellWithReuseIdentifier: BackgroundCollectionViewCell.reuseId)
    }

    // MARK: - actions
    func cancelAction() {
        self.navigationController?.popViewControllerAnimated(true)
    }
}

extension BackgroundViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MainColorType.count()
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(
            BackgroundCollectionViewCell.reuseId, forIndexPath: indexPath) as! BackgroundCollectionViewCell
        let type = MainColorType(rawValue: indexPath.row) ?? MainColorType.GreenSea
        cell.contentView.backgroundColor = type.mianColor()
        cell.contentView.layer.cornerRadius = 10
        let selectedType = UserDefault().readInt(kBackgroundKey)
        cell.checkImageView.hidden = selectedType != indexPath.row
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        Colors.backgroundType = MainColorType(rawValue: indexPath.row) ?? MainColorType.GreenSea
        collectionView.reloadData()
        NSNotificationCenter.defaultCenter().postNotificationName(kBackgroundNeedRefreshNotification, object: nil)
    }
}

