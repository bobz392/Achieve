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
        
        self.titleLabel.textColor = colors.cloudColor
        
        self.cardView.backgroundColor = colors.cloudColor
        self.view.backgroundColor = colors.mainGreenColor
        
        self.backButton.buttonColor(colors)
        self.backButton.createIconButton(iconSize: kBackButtonCorner, imageSize: kBackButtonCorner,
                                         icon: backButtonIconString, color: colors.mainGreenColor,
                                         status: UIControlState())
    }
    
    fileprivate func initializeControl() {
        self.backButton.addShadow()
        self.backButton.layer.cornerRadius = kBackButtonCorner
        self.backButton.addTarget(self, action: #selector(self.cancelAction), for: .touchUpInside)
        
        self.cardView.addShadow()
        self.cardView.layer.cornerRadius = kCardViewCornerRadius
        
        self.titleLabel.text = Localized("background")
        
        self.backgroundCollectionView.clearView()
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .vertical
        let width: CGFloat = ( screenBounds.width - 50 - 50) * 0.25
        layout.itemSize = CGSize(width: width, height: width)
        self.backgroundCollectionView.collectionViewLayout = layout
        
        self.backgroundCollectionView.register(BackgroundCollectionViewCell.nib, forCellWithReuseIdentifier: BackgroundCollectionViewCell.reuseId)
    }

    // MARK: - actions
    func cancelAction() {
        guard let nav = self.navigationController else {
            return
        }
        nav.popViewController(animated: true)
    }
}

extension BackgroundViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MainColorType.count()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: BackgroundCollectionViewCell.reuseId, for: indexPath) as! BackgroundCollectionViewCell
        let type = MainColorType(rawValue: (indexPath as NSIndexPath).row) ?? MainColorType.greenSea
        cell.contentView.backgroundColor = type.mianColor()
        cell.contentView.layer.cornerRadius = 10
        let selectedType = UserDefault().readInt(kBackgroundKey)
        cell.checkImageView.isHidden = selectedType != (indexPath as NSIndexPath).row
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        Colors.backgroundType = MainColorType(rawValue: (indexPath as NSIndexPath).row) ?? MainColorType.greenSea
        collectionView.reloadData()
        NotificationCenter.default.post(name: Notification.Name(rawValue: kBackgroundNeedRefreshNotification), object: nil)
    }
}

