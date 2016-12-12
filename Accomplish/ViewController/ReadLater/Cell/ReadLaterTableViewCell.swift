//
//  ReadLaterTableViewCell.swift
//  Accomplish
//
//  Created by zhoubo on 16/12/11.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit
import Kingfisher

class ReadLaterTableViewCell: BaseTableViewCell {
    
    static let nib = UINib(nibName: "ReadLaterTableViewCell", bundle: nil)
    static let reuseId = "readLaterTableViewCell"
    static let rowHeight: CGFloat = 70
    
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var previewImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var previewImageViewRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var siteLabel: UILabel!
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let colors = Colors()
        self.clearView()
        self.contentView.clearView()
        
        self.titleLabel.textColor = colors.mainTextColor
        self.siteLabel.textColor = colors.secondaryTextColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configCell(readLater: ReadLater) {
        self.loadingActivityIndicator.stopAnimating()
        self.previewImageView.isHidden = false
        self.titleLabel.text = readLater.name
        if let url = URL(string: readLater.link) {
            self.siteLabel.text = url.host ?? ""
        }
        
        if let imageLink = readLater.previewImageLink,
            let url = URL(string: imageLink) {
            self.previewImageViewWidthConstraint.constant = 50
            self.previewImageViewRightConstraint.constant = 10
            self.previewImageView?.kf.setImage(with: url, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, url) in
                self.previewImageView.image = image
            })
        } else {
            self.previewImageView.isHidden = true
            self.previewImageViewWidthConstraint.constant = 0
            self.previewImageViewRightConstraint.constant = 0
        }
    }
}
