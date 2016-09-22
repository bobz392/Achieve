//
//  HintView.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/8.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

//        guard let hintView = HintView.loadNib(self) else { return }
//
//        self.view.addSubview(hintView)
//        hintView.snp.makeConstraints { (make) in
//            make.center.equalTo(self.view)
//            make.height.equalTo(150)
//            make.width.equalTo(280)
//        }
//        let hints = [
//            HintItem(iconName: "fa-arrow-right", hintDetail: "asd"),
//            HintItem(iconName: "fa-arrow-right", hintDetail: "asdasdasd"),
//            HintItem(iconName: "fa-arrow-right", hintDetail: "asdasdas]sad"),
//            HintItem(iconName: "fa-arrow-right", hintDetail: "asdasdakjkasjl"),
//        ]
//        hintView.addHints(hints)

let hintIconButtonSize: CGFloat = 18

class HintView: UIView {

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    fileprivate var hints = [HintItem]()
    
    class func loadNib(_ target: AnyObject) -> HintView? {
        return Bundle.main.loadNibNamed("HintView", owner: target, options: nil)?.first as? HintView
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let colors = Colors()
        self.titleLabel.textColor = colors.mainTextColor
        self.closeButton.createIconButton(iconSize: hintIconButtonSize, imageSize: hintIconButtonSize, icon: "fa-times", color: colors.mainGreenColor, status: .normal)
        
        self.nextButton.createIconButton(iconSize: hintIconButtonSize, imageSize: hintIconButtonSize, icon: "fa-arrow-right", color: colors.mainGreenColor, status: .normal)
        
        self.pageControl.tintColor = colors.mainGreenColor
        
        self.configCollectionView()
        self.titleLabel.text = Localized("help")
    }
    
    func addHints(_ hints: [HintItem]) {
        self.hints.removeAll()
        self.hints.append(contentsOf: hints)
        self.collectionView.reloadData()
        
        self.pageControl.numberOfPages = hints.count
        self.pageControl.currentPage = 0
    }
    
}

extension HintView: UICollectionViewDelegate, UICollectionViewDataSource {
    fileprivate func configCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 280, height: 80)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets.zero
        layout.scrollDirection = .horizontal
        self.collectionView.collectionViewLayout = layout

        self.collectionView.isPagingEnabled = true
        self.collectionView.clearView()
        
        self.collectionView.register(HintCollectionViewCell.nib, forCellWithReuseIdentifier: HintCollectionViewCell.reuseId)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.pageControl.currentPage = indexPath.row
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hints.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HintCollectionViewCell.reuseId, for: indexPath) as! HintCollectionViewCell
        
        cell.configCell(item: self.hints[indexPath.row])
        
        return cell
    }
}

struct HintItem {
    var iconName: String
    var hintDetail: String
    
    init(iconName: String, hintDetail: String) {
        self.iconName = iconName
        self.hintDetail = hintDetail
    }
}
