//
//  TaskDetailViewController.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/29.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class TaskDetailViewController: BaseViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var detailTableView: UITableView!
    
    var task: Task
    
    init(task: Task) {
        self.task = task
        super.init(nibName: "TaskDetailViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.task = Task()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        configMainUI()
        initializeControl()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func configMainUI() {
        let colors = Colors()
        
        self.titleLabel.textColor = colors.cloudColor
        
        self.detailTableView.backgroundColor = colors.cloudColor
        self.detailTableView.separatorColor = colors.separatorColor
        
        self.cardView.backgroundColor = colors.cloudColor
        self.view.backgroundColor = colors.mainGreenColor
        
        self.cancelButton.buttonColor(colors)
        let cancelIcon = FAKFontAwesome.arrowLeftIconWithSize(40)
        cancelIcon.addAttribute(NSForegroundColorAttributeName, value: colors.mainGreenColor)
        self.cancelButton.setAttributedTitle(cancelIcon.attributedString(), forState: .Normal)
    }
    
    private func initializeControl() {
        if #available(iOS 9, *) {
            self.detailTableView.cellLayoutMarginsFollowReadableWidth = false
        }
        self.detailTableView.tableFooterView = UIView()
        self.detailTableView.registerNib(SystemTaskTableViewCell.nib, forCellReuseIdentifier: SystemTaskTableViewCell.reuseId)
        
        self.cancelButton.addShadow()
        self.cancelButton.layer.cornerRadius = 30
        self.cancelButton.addTarget(self, action: #selector(self.cancelAction), forControlEvents: .TouchUpInside)
        
        self.cardView.addShadow()
        self.cardView.layer.cornerRadius = kCardViewCornerRadius
        
        self.titleLabel.text = task.getNormalDisplayTitle()
    }
    
    func cancelAction() {
        self.navigationController?.popViewControllerAnimated(true)
    }
}

extension TaskDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4 + (task.subTaskCount > 0 ? task.subTaskCount - 1 : 0)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
