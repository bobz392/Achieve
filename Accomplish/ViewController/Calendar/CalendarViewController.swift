//
//  CalendarViewController.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/4.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class CalendarViewController: BaseViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var weekView: UIView!
    @IBOutlet weak var circleView: CircleProgressView!
    
    @IBOutlet weak var createdLabel: UICountingLabel!
    @IBOutlet weak var completedLabel: UICountingLabel!
    @IBOutlet weak var showDetailButton: UIButton!
    @IBOutlet weak var createdTitleLable: UILabel!
    @IBOutlet weak var completedTitleLabel: UILabel!
    
    @IBOutlet weak var dayDetail: UIButton!
    
    lazy private var checkInManager = CheckInManager()
    lazy private var firstDate = RealmManager.shareManager.queryFirstCheckIn()?.checkInDate ?? NSDate()
    lazy private var row = 6
    
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.weekView.layoutSubviews()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let now = NSDate()
        self.calendarView.selectDates([now])
        self.calendarView.scrollToDate(now, triggerScrollToDateDelegate: true, animateScroll: false, preferredScrollPosition: nil) {
            UIView.animateWithDuration(kSmallAnimationDuration, animations: { [unowned self] in
                self.calendarView.alpha = 1
                })
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func configMainUI() {
        let colors = Colors()
        
        self.titleLabel.textColor = colors.cloudColor
        self.cardView.backgroundColor = colors.cloudColor
        self.view.backgroundColor = colors.mainGreenColor
        self.navigationController?.view.backgroundColor = colors.mainGreenColor
        
        self.backButton.buttonColor(colors)
        let cancelIcon = FAKFontAwesome.arrowLeftIconWithSize(kBackButtonCorner)
        cancelIcon.addAttribute(NSForegroundColorAttributeName, value: colors.mainGreenColor)
        self.backButton.setAttributedTitle(cancelIcon.attributedString(), forState: .Normal)
        
        self.dayDetail.setTitle(Localized("calendarReport"), forState: .Normal)
        self.dayDetail.setTitleColor(colors.cloudColor, forState: .Normal)
        self.dayDetail.addTarget(self, action: #selector(self.checkReport), forControlEvents: .TouchUpInside)
        
        self.configWeekView()
        
        self.createdLabel.textColor = colors.mainTextColor
        self.completedLabel.textColor = colors.mainTextColor
        self.createdTitleLable.textColor = colors.mainTextColor
        self.completedTitleLabel.textColor = colors.mainTextColor
    }
    
    private func initializeControl() {
        self.titleLabel.text = Localized("calendar")
        
        self.backButton.addShadow()
        self.backButton.clipsToBounds = true
        self.backButton.layer.cornerRadius = kBackButtonCorner
        self.backButton.addTarget(self, action: #selector(self.cancelAction), forControlEvents: .TouchUpInside)
        
        self.cardView.addShadow()
        self.cardView.layer.cornerRadius = 4
        
        self.calendarView.dataSource = self
        self.calendarView.delegate = self
        self.calendarView.cellInset = CGPoint(x: 0, y: 0)
        self.calendarView.registerCellViewXib(fileName: "CalendarCell")
        self.calendarView.clearView()
        self.calendarView.alpha = 0
        
        self.configCountingLabel(self.createdLabel)
        self.configCountingLabel(self.completedLabel)
    }
    
    func configCountingLabel(countLabel: UICountingLabel) {
        countLabel.numberOfLines = 1
        countLabel.animationDuration = kCalendarProgressAnimationDuration
        countLabel.method = .EaseOut
        countLabel.format = "%d"
    }
    
    func configWeekView() {
        for subview in self.weekView.subviews {
            let colors = Colors()
            guard let label = subview as? UILabel else { break }
            label.textColor = colors.mainGreenColor
            label.text = Localized("day\(label.tag + 1)")
        }
    }
    
    // MARK: - actions
    func cancelAction() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func checkReport() {
    
    }
}

extension CalendarViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    func configureCalendar(calendar: JTAppleCalendarView) -> (startDate: NSDate, endDate: NSDate, numberOfRows: Int, calendar: NSCalendar) {
        
        let secondDate = NSDate()
        let aCalendar = NSCalendar.currentCalendar()
        
        return (startDate: self.firstDate, endDate: secondDate, numberOfRows: row, calendar: aCalendar)
    }
    
    func calendar(calendar: JTAppleCalendarView, isAboutToDisplayCell cell: JTAppleDayCellView, date: NSDate, cellState: CellState) {
        guard let cell = cell as? CalendarCell else { return }
        
        cell.setupCellBeforeDisplay(cellState, date: date,
                                    hasTask: checkInManager.dateIsCheckIn(date)?.createdCount > 0)
    }
    
    func calendar(calendar: JTAppleCalendarView, didSelectDate date: NSDate, cell: JTAppleDayCellView?, cellState: CellState) {
        guard let cell = cell as? CalendarCell else { return }
        cell.cellSelectionChanged(cellState, date: date)
        
        self.showInfoWhenNeed(date)
    }
    
    func calendar(calendar: JTAppleCalendarView, didDeselectDate date: NSDate, cell: JTAppleDayCellView?, cellState: CellState) {
        guard let cell = cell as? CalendarCell else { return }
        cell.cellSelectionChanged(cellState, date: date)
    }
    
    func calendar(calendar: JTAppleCalendarView, didScrollToDateSegmentStartingWithdate startDate: NSDate, endingWithDate endDate: NSDate) {
        self.titleLabel.text = Localized("calendar") + "-" + startDate.formattedDateWithFormat(monthFormat)
    }
    
    func calendar(calendar: JTAppleCalendarView, canSelectDate date: NSDate, cell: JTAppleDayCellView, cellState: CellState) -> Bool {
        return !cellState.isSelected && !circleView.isInAnimation()
    }
    
    // 选中当前的date的进度 和 任务数量的动画
    private func showInfoWhenNeed(date: NSDate) {
        let task = RealmManager.shareManager.queryTaskCount(date)
        self.circleView.start(completed: task.complete, created: task.created)
        self.createdLabel.countFrom(0, to: CGFloat(task.created))
        self.completedLabel.countFrom(0, to: CGFloat(task.complete))
    }
}

