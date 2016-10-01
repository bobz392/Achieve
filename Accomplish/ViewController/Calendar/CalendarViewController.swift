//
//  CalendarViewController.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/4.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit

class CalendarViewController: BaseViewController {
    
    @IBOutlet weak var titleButton: UIButton!
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
    
    lazy fileprivate var checkInManager = CheckInManager()
    lazy fileprivate var firstDate =
        RealmManager.shareManager.queryCheckIn()?.checkInDate ?? NSDate()
    lazy fileprivate var row = 6
    fileprivate var inTodayAlleady = false
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.inTodayAlleady == false {
            let now = Date()
            self.calendarView.selectDates([now])
            self.calendarView.scrollToDate(now, triggerScrollToDateDelegate: true, animateScroll: false, preferredScrollPosition: nil) {
                UIView.animate(withDuration: kSmallAnimationDuration, animations: { [unowned self] in
                    self.calendarView.alpha = 1
                    })
            }
            self.inTodayAlleady = true
        }
    }

    override func configMainUI() {
        let colors = Colors()
        
        self.titleButton.tintColor = colors.cloudColor
        self.cardView.backgroundColor = colors.cloudColor
        self.view.backgroundColor = colors.mainGreenColor
        self.navigationController?.view.backgroundColor = colors.mainGreenColor
        
        self.backButton.buttonColor(colors)
        self.backButton.createIconButton(iconSize: kBackButtonCorner, imageSize: kBackButtonCorner,
                                           icon: backButtonIconString, color: colors.mainGreenColor,
                                           status: .normal)
    
        
        self.scheduleButton.setTitle(Localized("calendarReport"), for: .normal)
        self.scheduleButton.setTitle(Localized("noSchedule"), for: .disabled)
        self.scheduleButton.setTitleColor(colors.cloudColor, for: .normal)
        self.scheduleButton.addTarget(self, action: #selector(self.checkReport), for: .touchUpInside)
        
        self.configWeekView()
        
        self.createdLabel.textColor = colors.cloudColor
        self.completedLabel.textColor = colors.cloudColor
        self.createdTitleLable.textColor = colors.cloudColor
        self.completedTitleLabel.textColor = colors.cloudColor
    }
    
    fileprivate func initializeControl() {        
        self.backButton.addShadow()
        self.backButton.layer.cornerRadius = kBackButtonCorner
        self.backButton.addTarget(self, action: #selector(self.cancelAction), for: .touchUpInside)
        
        self.cardView.addShadow()
        self.cardView.layer.cornerRadius = 4
        
        
        let startDay = AppUserDefault().readInt(kWeekStartKey)
        self.calendarView.firstDayOfWeek = DaysOfWeek(rawValue: startDay) ?? DaysOfWeek.sunday
        self.calendarView.cellInset = CGPoint(x: 0, y: 0)
        self.calendarView.registerCellViewXib(fileName: "CalendarCell")
        self.calendarView.dataSource = self
        self.calendarView.delegate = self
        self.calendarView.clearView()
        self.calendarView.alpha = 0
        
        self.configCountingLabel(self.createdLabel)
        self.configCountingLabel(self.completedLabel)
        self.calendarView.reloadData()
        
        self.titleButton.addTarget(self, action: #selector(self.returnTodayAction), for: .touchUpInside)
    }
    
    func configCountingLabel(_ countLabel: UICountingLabel) {
        countLabel.numberOfLines = 1
        countLabel.animationDuration = kCalendarProgressAnimationDuration
        countLabel.method = .easeIn
        countLabel.format = "%d"
    }
    
    func configWeekView() {
        let startDay = AppUserDefault().readInt(kWeekStartKey)
        
        for subview in self.weekView.subviews {
            let colors = Colors()
            guard let label = subview as? UILabel else { break }
            label.textColor = colors.mainGreenColor
            if startDay == DaysOfWeek.monday.rawValue {
                label.text = Localized("day\(label.tag)")
            } else if startDay == DaysOfWeek.saturday.rawValue {
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
        guard let nav = self.navigationController else { return }
        nav.popViewController(animated: true)
    }
    
    func checkReport() {
        guard let checkDate = self.calendarView.selectedDates.first else { return }
        let reportVC = ReportViewController(checkInDate: checkDate as NSDate)
        self.navigationController?.pushViewController(reportVC, animated: true)
    }
    
    func returnTodayAction() {
        let now = Date()
        self.calendarView.selectDates([now])
        self.calendarView.scrollToDate(now, triggerScrollToDateDelegate: true, animateScroll: true, preferredScrollPosition: nil, completionHandler: nil)
    }
}

extension CalendarViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> (startDate: Date, endDate: Date, numberOfRows: Int, calendar: Calendar) {
        
        let secondDate = self.firstDate.addingMonths(12) as NSDate
        let aCalendar = Calendar.current
        
        return (startDate: self.firstDate as Date, endDate: secondDate as Date, numberOfRows: row, calendar: aCalendar)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, isAboutToDisplayCell cell: JTAppleDayCellView, date: Date, cellState: CellState) {
        guard let cell = cell as? CalendarCell else { return }
        
        let createCount = self.checkInManager.taskCount(date: date).created
        
        cell.setupCellBeforeDisplay(cellState, date: date,
                                    hasTask: createCount > 0)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        guard let cell = cell as? CalendarCell else { return }
        cell.cellSelectionChanged(cellState, date: date)
        self.showInfoWhenNeed(date)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        guard let cell = cell as? CalendarCell else { return }
        cell.cellSelectionChanged(cellState, date: date)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentStartingWithdate startDate: Date, endingWithDate endDate: Date) {
        let newTitle = Localized("calendar") + "-" + (startDate as NSDate).formattedDate(withFormat: MonthFormat)
        self.titleButton.setTitle(newTitle, for: .normal)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, canSelectDate date: Date, cell: JTAppleDayCellView, cellState: CellState) -> Bool {
        return !cellState.isSelected && !circleView.isInAnimation()
    }
    
    // 选中当前的date的进度 和 任务数量的动画
    fileprivate func showInfoWhenNeed(_ date: Date) {
        let counts = self.checkInManager.taskCount(date: date)
        let created = counts.created
        let completed = counts.completed
        self.circleView.start(completed: completed, created: created)
        self.createdLabel.count(from: 0, to: CGFloat(created))
        self.completedLabel.count(from: 0, to: CGFloat(completed))
        
        self.scheduleButton.isEnabled = created > 0
    }
}

