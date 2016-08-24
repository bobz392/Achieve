//
//  HomeViewController.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/23.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var statusSegment: UISegmentedControl!
    @IBOutlet weak var newTaskButton: UIButton!
    @IBOutlet weak var calendarButton: UIButton!
    @IBOutlet weak var taskTableView: UITableView!
    @IBOutlet weak var currentDateLabel: UILabel!
    @IBOutlet weak var emptyHintLabel: UILabel!
    @IBOutlet weak var emptyCoffeeLabel: UILabel!
    
    private var finishTasks = [Task]()
    private var progessTasks = [Task]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.configMainUI()
        
        self.initialControl()
        self.configLabel()
        self.configMainButton()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    // MARK: - ui config
    private func configMainUI() {
        let colors = Colors()
        
        self.taskTableView.backgroundColor = colors.cloudColor
        self.currentDateLabel.textColor = colors.cloudColor
        
        self.taskTableView.separatorColor = colors.separatorColor
        self.cardView.backgroundColor = colors.cloudColor
        self.view.backgroundColor = colors.mainGreenColor
        
        self.statusSegment.tintColor = colors.mainGreenColor
        
        self.emptyHintLabel.textColor = colors.secondaryTextColor
        
        self.settingButton.tintColor = colors.mainGreenColor
        self.settingButton.backgroundColor = colors.cloudColor
        
        self.newTaskButton.tintColor = colors.mainGreenColor
        self.newTaskButton.backgroundColor = colors.cloudColor
        self.calendarButton.tintColor = colors.mainTextColor
        self.calendarButton.backgroundColor = colors.cloudColor
        
        let coffeeIcon = FAKFontAwesome.coffeeIconWithSize(60)
        coffeeIcon.addAttribute(NSForegroundColorAttributeName, value: colors.mainGreenColor)
        self.emptyCoffeeLabel.attributedText = coffeeIcon.attributedString()
        
        let cogIcon = FAKFontAwesome.cogIconWithSize(20)
        cogIcon.addAttribute(NSForegroundColorAttributeName, value: colors.mainGreenColor)
        let cogImage = cogIcon.imageWithSize(CGSize(width: 20, height: 20))
        self.settingButton.setImage(cogImage, forState: .Normal)
        
        let newIcon = FAKFontAwesome.plusIconWithSize(50)
        newIcon.addAttribute(NSForegroundColorAttributeName, value: colors.mainGreenColor)
        let newImage = newIcon.imageWithSize(CGSize(width: 70, height: 70))
        self.newTaskButton.setImage(newImage, forState: .Normal)
        
        let calendarIcon = FAKFontAwesome.calendarIconWithSize(20)
        calendarIcon.addAttribute(NSForegroundColorAttributeName, value: colors.mainGreenColor)
        let calendarImage = calendarIcon.imageWithSize(CGSize(width: 20, height: 20))
        self.calendarButton.setImage(calendarImage, forState: .Normal)
    }
    
    private func initialControl() {
        self.cardView.layer.cornerRadius = 9
        
        if #available(iOS 9, *) {
            self.taskTableView.cellLayoutMarginsFollowReadableWidth = false
        }
        
        self.statusSegment.setTitle(Localized("progess"), forSegmentAtIndex: 0)
        self.statusSegment.setTitle(Localized("completed"), forSegmentAtIndex: 1)
        self.statusSegment.addTarget(self, action: Selector(self.segmentValueChange(self.statusSegment)), forControlEvents: .ValueChanged)
        
        taskTableView.registerNib(TaskTableViewCell.nib, forCellReuseIdentifier: TaskTableViewCell.reuseId)
    }
    
    private func configLabel() {
        self.currentDateLabel.text = NSDate().formattedDateWithStyle(.MediumStyle)
        self.emptyHintLabel.text = Localized("emptyTask")
    }
    
    private func showEmptyHint(show: Bool) {
        self.emptyHintLabel.hidden = !show
        self.emptyCoffeeLabel.hidden = !show
    }
    
    private func configMainButton() {
        self.settingButton.layer.cornerRadius = 16
        
        self.newTaskButton.layer.cornerRadius = 35
        
        self.newTaskButton.addTarget(self, action:  #selector(self.newTask), forControlEvents: .TouchUpInside)
        self.newTaskButton.addTarget(self, action: #selector(self.buttonAnimationStart(_:)), forControlEvents: .TouchDown)
        self.newTaskButton.addTarget(self, action: #selector(self.buttonAnimationEnd(_:)), forControlEvents: .TouchUpOutside)
        
        self.calendarButton.layer.cornerRadius = 16
    }
    
    // MARK: - actions
    func newTask() {
        let alertController = UIAlertController(title: Localized("newTask"), message: nil, preferredStyle: .ActionSheet)
        let customAction = UIAlertAction(title: Localized("customTask"), style: .Destructive) { [unowned self] (action) in
            let vc = NewTaskViewController()
            self.addChildViewController(vc)
            vc.didMoveToParentViewController(self)
        }
        alertController.addAction(customAction)
        
        let systemAction = UIAlertAction(title: Localized("dependTask"), style: .Destructive) { (action) in
            
        }
        alertController.addAction(systemAction)
        
        let dependAction = UIAlertAction(title: Localized("systemTask"), style: .Destructive) { (action) in
            
        }
        alertController.addAction(dependAction)
        
        let cancelAction = UIAlertAction(title: Localized("cancel"), style: .Cancel) { (action) in
            
        }
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true) {
            
        }
        buttonAnimationEnd(newTaskButton)
    }
    
    func buttonAnimationStart(btn: UIButton) {
        UIView.animateWithDuration(kNormalAnimationDuration, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .CurveEaseInOut, animations: {
            btn.transform = CGAffineTransformScale(btn.transform, 0.8, 0.8)
        }) { (finish) in
            
        }
    }
    
    func buttonAnimationEnd(btn: UIButton) {
        UIView.animateWithDuration(kNormalAnimationDuration, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.4, options: .LayoutSubviews, animations: {
            btn.transform = CGAffineTransformMakeScale(1, 1)
        }) { (finish) in
            
        }
    }
    
    func segmentValueChange(seg: UISegmentedControl) {
        taskTableView.reloadData()
    }
    
    // MARK: - table view
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (statusSegment.selectedSegmentIndex == 0) {
            showEmptyHint(progessTasks.count <= 0)
            return progessTasks.count
        } else {
            showEmptyHint(finishTasks.count <= 0)
            return finishTasks.count
        }
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return TaskTableViewCell.rowHeight
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return TaskTableViewCell.rowHeight
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TaskTableViewCell.reuseId, forIndexPath: indexPath) as! TaskTableViewCell
        
        cell.configCellUse(Task())
        
        return cell
    }
}
