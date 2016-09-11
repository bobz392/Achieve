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
    @IBOutlet weak var createdTitleLable: UILabel!
    @IBOutlet weak var completedTitleLabel: UILabel!
    
    @IBOutlet weak var scheduleButton: UIButton!
    
    lazy private var checkInManager = CheckInManager()
    lazy private var firstDate = RealmManager.shareManager.queryFirstCheckIn()?.checkInDate ?? NSDate()
    lazy private var row = 6
    private var toTodayAlleady = false
    
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
        
        if self.toTodayAlleady == false {
            let now = NSDate()
            self.calendarView.selectDates([now])
            self.calendarView.scrollToDate(now, triggerScrollToDateDelegate: true, animateScroll: false, preferredScrollPosition: nil) {
                UIView.animateWithDuration(kSmallAnimationDuration, animations: { [unowned self] in
                    self.calendarView.alpha = 1
                    })
            }
            self.toTodayAlleady = true
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
        
        self.scheduleButton.setTitle(Localized("calendarReport"), forState: .Normal)
        self.scheduleButton.setTitle(Localized("noSchedule"), forState: .Disabled)
        self.scheduleButton.setTitleColor(colors.cloudColor, forState: .Normal)
        self.scheduleButton.addTarget(self, action: #selector(self.checkReport), forControlEvents: .TouchUpInside)
        
        self.configWeekView()
        
        self.createdLabel.textColor = colors.cloudColor
        self.completedLabel.textColor = colors.cloudColor
        self.createdTitleLable.textColor = colors.cloudColor
        self.completedTitleLabel.textColor = colors.cloudColor
    }
    
    private func initializeControl() {
        self.titleLabel.text = Localized("calendar")
        
        self.backButton.addShadow()
        self.backButton.layer.cornerRadius = kBackButtonCorner
        self.backButton.addTarget(self, action: #selector(self.cancelAction), forControlEvents: .TouchUpInside)
        
        self.cardView.addShadow()
        self.cardView.layer.cornerRadius = 4
        
        
        let startDay = UserDefault().readInt(kWeekStartKey)
        self.calendarView.firstDayOfWeek = DaysOfWeek(rawValue: startDay) ?? DaysOfWeek.Sunday
        self.calendarView.cellInset = CGPoint(x: 0, y: 0)
        self.calendarView.registerCellViewXib(fileName: "CalendarCell")
        self.calendarView.dataSource = self
        self.calendarView.delegate = self
        self.calendarView.clearView()
        self.calendarView.alpha = 0
        
        self.configCountingLabel(self.createdLabel)
        self.configCountingLabel(self.completedLabel)
        self.calendarView.reloadData()
    }
    
    func configCountingLabel(countLabel: UICountingLabel) {
        countLabel.numberOfLines = 1
        countLabel.animationDuration = kCalendarProgressAnimationDuration
        countLabel.method = .EaseIn
        countLabel.format = "%d"
    }
    
    func configWeekView() {
        let startDay = UserDefault().readInt(kWeekStartKey)
        
        for subview in self.weekView.subviews {
            let colors = Colors()
            guard let label = subview as? UILabel else { break }
            label.textColor = colors.mainGreenColor
            if startDay == DaysOfWeek.Monday.rawValue {
                label.text = Localized("day\(label.tag)")
            } else if startDay == DaysOfWeek.Saturday.rawValue {
                if label.tag < 3 {
                    label.text = Localized("day\(label.tag + 5)")
                } else {
                    label.text = Localized("day\(label.tag - 2)")
                }
            } else {
                if label.tag == 1 {
                    label.text = Localized("day7")
                } else {
                    label.text = Localized("day\(label.tag - 1)")
                }
            }
        }
    }
    
    // MARK: - actions
    func cancelAction() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func checkReport() {
        guard let checkDate = self.calendarView.selectedDates.first else { return }
        let reportVC = ReportViewController(checkInDate: checkDate)
        self.navigationController?.pushViewController(reportVC, animated: true)
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
                                    hasTask: checkInManager.checkInWithDate(date)?.createdCount > 0)
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
//        let created: Int
//        let completed: Int
//        if let checkIn = self.checkInManager.checkInWithDate(date) {
//            created = checkIn.createdCount
//            completed = checkIn.completedCount
//        } else {
//            if date.isToday() {
//                let task = RealmManager.shareManager.queryTaskCount(date)
//                created = task.created
//                completed = task.complete
//            } else {
//                created = 0
//                completed = 0
//            }
//        }
        
        let task = RealmManager.shareManager.queryTaskCount(date)
        let created = task.created
        let completed = task.complete
        self.circleView.start(completed: completed, created: created)
        self.createdLabel.countFrom(0, to: CGFloat(created))
        self.completedLabel.countFrom(0, to: CGFloat(completed))
        
        self.scheduleButton.enabled = created > 0
    }
}

