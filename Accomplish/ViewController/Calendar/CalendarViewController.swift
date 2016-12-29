//
//  CalendarViewController.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/4.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarViewController: BaseViewController {
    
    @IBOutlet weak var titleButton: UIButton!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var backButton: UIButton!
    var calendarView: JTAppleCalendarView!
    @IBOutlet weak var weekView: UIView!
    @IBOutlet weak var circleView: CircleProgressView!
    @IBOutlet weak var monthButton: UIButton!
    @IBOutlet weak var monthButtonRightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var createdLabel: UICountingLabel!
    @IBOutlet weak var completedLabel: UICountingLabel!
    @IBOutlet weak var createdTitleLable: UILabel!
    @IBOutlet weak var completedTitleLabel: UILabel!
    
    @IBOutlet weak var scheduleButton: UIButton!
    
    lazy fileprivate var checkInManager = CheckInManager()
    lazy fileprivate var firstDate =
        RealmManager.shared.queryCheckIn()?.checkInDate ?? NSDate()
    lazy fileprivate var row = 6
    fileprivate var inTodayAlleady = false
    fileprivate var monthButtonRight: CGFloat = 0
    
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
            let startMonth = self.checkInManager.getMonthCheckIn().first?.checkInDate?.month()
            self.calendarView.selectDates([now])
            
            if startMonth != NSDate().month() {
                self.calendarView.scrollToDate(now, triggerScrollToDateDelegate: true, animateScroll: true, completionHandler: {
                    UIView.animate(withDuration: kSmallAnimationDuration, animations: { [unowned self] in
                        self.calendarView.alpha = 1
                        self.showInfoWhenNeed(Date())
                    })
                })
            } else {
                self.calendarView.alpha = 1
                self.showInfoWhenNeed(Date())
            }
            
            self.inTodayAlleady = true
        }
        
        self.monthButtonRight = self.monthButton.frame.width * 0.9 + 5
    }
    
    override func configMainUI() {
        let colors = Colors()
        
        self.titleButton.tintColor = Colors.cloudColor
        self.cardView.backgroundColor = Colors.cloudColor
        self.view.backgroundColor = colors.mainGreenColor
        self.navigationController?.view.backgroundColor = colors.mainGreenColor
        
        self.backButton.buttonColor(colors)
        self.backButton.createIconButton(iconSize: kBackButtonCorner,
                                         icon: backButtonIconString,
                                         color: colors.mainGreenColor, status: .normal)
        
        
        self.scheduleButton.setTitle(Localized("calendarReport"), for: .normal)
        self.scheduleButton.setTitle(Localized("noSchedule"), for: .disabled)
        self.scheduleButton.setTitleColor(Colors.cloudColor, for: .normal)
        self.scheduleButton.addTarget(self, action: #selector(self.checkReport), for: .touchUpInside)
        
        self.configWeekView()
        
        self.createdLabel.textColor = Colors.cloudColor
        self.completedLabel.textColor = Colors.cloudColor
        self.createdTitleLable.textColor = Colors.cloudColor
        self.completedTitleLabel.textColor = Colors.cloudColor
        
        self.monthButton.backgroundColor = Colors.cloudColor
        self.monthButton.setTitleColor(colors.mainGreenColor, for: .normal)
    }
    
    fileprivate func initializeControl() {
        self.backButton.addShadow()
        self.backButton.layer.cornerRadius = kBackButtonCorner
        self.backButton.addTarget(self, action: #selector(self.backAction), for: .touchUpInside)
        
        self.cardView.addShadow()
        self.cardView.layer.cornerRadius = 4
        
        self.calendarView = JTAppleCalendarView(frame: CGRect.zero)
        self.calendarView.clearView()
        self.cardView.addSubview(self.calendarView)
        self.calendarView.snp.makeConstraints { (maker) in
            maker.top.equalTo(self.weekView.snp.bottom)
            maker.left.equalTo(self.cardView).offset(5)
            maker.bottom.equalTo(self.cardView).offset(-5)
            maker.right.equalTo(self.cardView).offset(-5)
        }
        self.calendarView.cellInset = CGPoint(x: 0, y: 0)
        self.calendarView.registerCellViewXib(file: "CalendarCell")
        self.calendarView.dataSource = self
        self.calendarView.delegate = self
        self.calendarView.clearView()
        self.calendarView.alpha = 0
        
        self.configCountingLabel(self.createdLabel)
        self.configCountingLabel(self.completedLabel)
        self.calendarView.reloadData()
        
        self.titleButton.addTarget(self, action: #selector(self.returnTodayAction), for: .touchUpInside)
        
        self.monthButton.setTitle(Localized("monthly"), for: .normal)
        self.monthButton.layer.cornerRadius = 14
        self.monthButton.addTarget(self, action: #selector(self.monthAction), for: .touchUpInside)
    }
    
    func configCountingLabel(_ countLabel: UICountingLabel) {
        countLabel.numberOfLines = 1
        countLabel.animationDuration = kCalendarProgressAnimationDuration
        countLabel.method = .easeIn
        countLabel.format = "%d"
    }
    
    func configWeekView() {
        let startDay = AppUserDefault().readInt(kUserDefaultWeekStartKey)
        
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
    func backAction() {
        let _ = self.navigationController?.popViewController(animated: true)
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
    
    func monthAction() {
        let monthVC =
            MonthViewController(checkIns: self.checkInManager.getMonthCheckIn())
        self.navigationController?.pushViewController(monthVC, animated: true)
    }
}

extension CalendarViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    
    public func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let endDate = self.firstDate.addingMonths(10)!
        let startDate = self.firstDate.subtractingMonths(2)!
        let aCalendar = Calendar.current
        
        let firstDayOfWeekValue = AppUserDefault().readInt(kUserDefaultWeekStartKey)
        let firstDayOfWeek = DaysOfWeek(rawValue: firstDayOfWeekValue) ?? DaysOfWeek.sunday
        let params = ConfigurationParameters(startDate: startDate, endDate: endDate, numberOfRows: row, calendar: aCalendar, firstDayOfWeek: firstDayOfWeek)
        
        return params
    }
    
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplayCell cell: JTAppleDayCellView, date: Date, cellState: CellState) {
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
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        guard let startDate = visibleDates.monthDates.first else { return }
        
        let nsStartDate = startDate as NSDate
        let inMonth = nsStartDate.month() == NSDate().month()
        self.monthButton.isEnabled = inMonth
        self.monthButtonRightConstraint.constant =
            inMonth ? 0 : self.monthButtonRight
        
        UIView.animate(withDuration: kNormalAnimationDuration, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.4, options: .beginFromCurrentState, animations: { [unowned self] in
            self.view.layoutIfNeeded()
        }) { (finish) in }
        
        let newTitle = Localized("calendar")
            + "-" + nsStartDate.formattedDate(withFormat: MonthFormat)
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

// MAKR: - drawer open close call back -- not prefect
extension CalendarViewController: MenuDrawerSlideStatusDelegate {
    func slideOpen(open: Bool) {
        self.leftBarButton?.isSelected = open
    }
}
