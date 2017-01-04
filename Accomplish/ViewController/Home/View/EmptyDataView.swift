//
//  EmptyPreceedTaskView.swift
//  Accomplish
//
//  Created by zhoubo on 16/12/21.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class EmptyDataView: UIView {
    
    static let height: CGFloat = 168
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var linkButton: UIButton!
    
    class func loadNib(_ target: AnyObject) -> EmptyDataView? {
        guard let view =
            Bundle.main.loadNibNamed("EmptyDataView", owner: target, options: nil)?
                .first as? EmptyDataView else {
                    return nil
        }

        view.backgroundColor = Colors.mainBackgroundColor
        view.nameLabel.textColor = Colors.emptyTintColor
        view.linkButton.setTitleColor(Colors.linkButtonTextColor, for: .normal)
        
        return view
    }
    
    @discardableResult
    func setImage(imageName: String) -> EmptyDataView {
        self.imageView.image =
            UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
        
        self.imageView.tintColor = Colors.emptyTintColor
        return self
    }
    
    @discardableResult
    func setTitle(title: String) -> EmptyDataView {
        self.nameLabel.text = title
        return self
    }

}
