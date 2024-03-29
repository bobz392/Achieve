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
    
    @IBOutlet weak var cardView: UIView!
    var calendarView: JTAppleCalendarView!
    fileprivate let dateButton = UIButton()
    @IBOutlet weak var weekView: UIView!
    @IBOutlet weak var circleView: CircleProgressView!
    @IBOutlet weak var monthButton: UIButton!
    @IBOutlet weak var monthButtonRightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var createdLabel: UICountingLabel!
    @IBOutlet weak var completedLabel: UICountingLabel!
    @IBOutlet weak var createdTitleLable: UILabel!
    @IBOutlet weak var completedTitleLabel: UILabel!
    
    @IBOutlet weak var circleViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var circleViewBottomConstraint: NSLayoutConstraint!
    
    lazy fileprivate var checkInManager = CheckInManager()
    lazy fileprivate var firstDate =
        RealmManager.shared.queryCheckIn()?.checkInDate ?? NSDate()
    lazy fileprivate var row = 6
    fileprivate var inTodayAlleady = false
    fileprivate var monthButtonRight: CGFloat = 0
    fileprivate var currentWeekStart = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configMainUI()
        self.initializeControl()
        
        if #available(iOS 9.0, *) {
            self.registerPerview(sourceViewBlock: { [unowned self] () -> UIView in
                return self.circleView.circleButton
                }, previewViewControllerBlock: { [unowned self] (previewingContext: UIViewControllerPreviewing, location: CGPoint) -> UIViewController? in
                    guard true == self.circleView.circleButton.point(inside: location, with: nil),
                        let checkDate = self.calendarView.selectedDates.first else { return nil }
                    let scheduleVC = ScheduleViewController(checkInDate: checkDate as NSDate)
                    previewingContext.sourceRect = self.circleView.frame
                    return scheduleVC
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.weekView.layoutSubviews()
        self.circleView.configButtonCorner()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.inTodayAlleady == false {
            let now = Date()
            let startMonth = self.firstDate.month() 
            self.calendarView.selectDates([now])
            
            self.calendarView.scrollToDate(now, triggerScrollToDateDelegate: true, animateScroll: true, completionHandler: {
                UIView.animate(withDuration: kSmallAnimationDuration, animations: { [unowned self] in
                    self.calendarView.alpha = 1
                    self.showInfoWhenNeed(Date())
                })
            })
            
            if startMonth == NSDate().month() {
                self.calendarView.alpha = 1
                self.showInfoWhenNeed(Date())
            }
        
            self.inTodayAlleady = true
        } else {
            if self.currentWeekStart != AppUserDefault().readInt(kUserDefaultWeekStartKey) {
                self.configWeekView()
                self.calendarView.reloadData()
            }
        }
        
        self.monthButtonRight = self.monthButton.frame.width * 0.9 + 5
    }
    
    override func configMainUI() {
        self.view.backgroundColor = Colors.mainBackgroundColor
        
        self.cardView.backgroundColor = Colors.cellCardColor
        let bar = self.createCustomBar(height: kBarHeight)
        self.view.sendSubviewToBack(bar)
        self.createTitleLabel(titleText: Localized("calendar"))
        let menuButton = self.congfigMenuButton()
        
        bar.addSubview(self.dateButton)
        self.dateButton.setTitleColor(Colors.mainIconColor, for: .normal)
        self.dateButton.tintColor = Colors.mainIconColor
        self.dateButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalTo(menuButton)
        }
        self.dateButton.addTarget(self, action: #selector(self.returnTodayAction), for: .touchUpInside)
        self.circleViewTopConstraint.constant = DeviceSzie.isSmallDevice() ? 40 : 50
        self.circleViewBottomConstraint.constant = DeviceSzie.isSmallDevice() ? 5 : 20
        self.circleView.circleButton
            .addTarget(self, action:  #selector(self.enterSchedule),
                       for: .touchUpInside)
        self.configWeekView()
        
        self.createdLabel.textColor = Colors.mainTextColor
        self.completedLabel.textColor = Colors.mainTextColor
        self.createdTitleLable.textColor = Colors.secondaryTextColor
        self.completedTitleLabel.textColor = Colors.secondaryTextColor
        
        self.monthButton.backgroundColor = Colors.cellCardColor
        self.monthButton.setTitleColor(Colors.linkButtonTextColor, for: .normal)
        
        self.cardView.snp.makeConstraints { (maker) in
            maker.top.equalTo(bar.snp.bottom).offset(5)
        }
    }
    
    fileprivate func initializeControl() {
        self.cardView.addCardShadow()
        self.cardView.layer.cornerRadius = 4
        
        self.calendarView = JTAppleCalendarView(frame: CGRect.zero)
        self.calendarView.clearView()
        self.cardView.addSubview(self.calendarView)
        self.calendarView.snp.makeConstraints { (maker) in
            maker.top.equalTo(self.weekView.snp.bottom).offset(10)
            maker.left.equalTo(self.cardView).offset(5)
            maker.bottom.equalTo(self.cardView).offset(-5)
            maker.right.equalTo(self.cardView).offset(-5)
        }
        
//        self.calendarView.cellInset = CGPoint(x: 0, y: 0)
        self.calendarView.calendarDelegate = self
        self.calendarView.calendarDataSource = self
        self.calendarView.isPagingEnabled = true
        self.calendarView.scrollDirection = .horizontal
        self.calendarView.register(CalendarCell.nib,
                                   forCellWithReuseIdentifier: "CalendarCell")
        self.calendarView.clearView()
        self.calendarView.alpha = 0
        
        self.configCountingLabel(self.createdLabel)
        self.configCountingLabel(self.completedLabel)
        self.calendarView.reloadData()
        
        
        self.monthButton.setTitle(Localized("monthly"), for: .normal)
        self.monthButton.layer.cornerRadius = 14
        self.monthButton.addTarget(self, action: #selector(self.monthAction), for: .touchUpInside)
    }
    
    fileprivate func configCountingLabel(_ countLabel: UICountingLabel) {
        countLabel.numberOfLines = 1
        countLabel.animationDuration = kCalendarProgressAnimationDuration
        countLabel.method = .easeIn
        countLabel.format = "%d"
    }
    
    fileprivate func configWeekView() {
        let startDay = AppUserDefault().readInt(kUserDefaultWeekStartKey)
        
        for subview in self.weekView.subviews {
            guard let label = subview as? UILabel else { break }
            label.textColor = Colors.mainIconColor
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
    @objc func enterSchedule() {
        guard let checkDate = self.calendarView
            .selectedDates.first else { return }
        let scheduleVC = ScheduleViewController(checkInDate: checkDate as NSDate)
        self.navigationController?.pushViewController(scheduleVC, animated: true)
    }
    
    @objc func returnTodayAction() {
        let now = Date()
        self.calendarView.selectDates([now])
        self.calendarView.scrollToDate(now, triggerScrollToDateDelegate: true, animateScroll: true, preferredScrollPosition: nil, completionHandler: nil)
    }
    
    @objc func monthAction() {
        guard let date = self.calendarView.visibleDates()
            .monthDates.first?.date else { return }
        let nd = date as NSDate
        let monthVC = MonthViewController(queryFormat: nd.formattedDate(withFormat: ChartQueryDateFormat))
        self.navigationController?.pushViewController(monthVC, animated: true)
    }
}

extension CalendarViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let c = calendarView.dequeueReusableJTAppleCell(withReuseIdentifier: "CalendarCell", for: indexPath)
        guard let cell = c as? CalendarCell else { return c }
        let createCount = self.checkInManager.taskCount(date: date).created
        cell.setupCellBeforeDisplay(cellState, date: date,
                                    hasTask: createCount > 0)
        return cell
    }
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let endDate = Date()
        let startDate = self.firstDate as Date
        let aCalendar = Calendar.current
        
        self.currentWeekStart = AppUserDefault().readInt(kUserDefaultWeekStartKey)
        let firstDayOfWeek = DaysOfWeek(rawValue: self.currentWeekStart) ?? DaysOfWeek.sunday
        let params = ConfigurationParameters(startDate: startDate, endDate: endDate, numberOfRows: row, calendar: aCalendar, firstDayOfWeek: firstDayOfWeek)
        
        return params
    }
    
//    public func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
//    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let cell = cell as? CalendarCell else { return }
        cell.cellSelectionChanged(cellState, date: date)
        self.showInfoWhenNeed(date)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let cell = cell as? CalendarCell else { return }
        cell.cellSelectionChanged(cellState, date: date)
    }

    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        guard let startDate = visibleDates.monthDates.first?
            .date else { return }

        let nsStartDate = startDate as NSDate
        let inMonth = nsStartDate.month() <= NSDate().month() || nsStartDate.year() < NSDate().year()
        self.monthButton.isEnabled = inMonth
        self.monthButtonRightConstraint.constant =
            inMonth ? 0 : self.monthButtonRight
        
        UIView.animate(withDuration: kNormalAnimationDuration, delay: 0, usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.4, options: .beginFromCurrentState, animations: { [unowned self] in
            self.view.layoutIfNeeded()
        }) { (finish) in }
        
        let newTitle = nsStartDate.formattedDate(withFormat: MonthFormat)
        self.dateButton.setTitle(newTitle, for: .normal)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {
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
        self.circleView.scheduleLabel.text =
            created > 0 ? Localized("schedule") : Localized("noSchedule")
    }
    
}

// MAKR: - drawer open close call back -- not prefect
extension CalendarViewController: MenuDrawerSlideStatusDelegate {
    func slideOpen(open: Bool) {
        self.leftBarButton?.isSelected = open
    }
}
