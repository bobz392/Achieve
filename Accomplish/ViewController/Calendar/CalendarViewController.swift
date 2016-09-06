//
//  CalendarViewController.swift
//  Accomplish
//
//  Created by zhoubo on 16/9/4.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit
import FLAnimatedImage

class CalendarViewController: BaseViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var weekView: UIView!
    @IBOutlet weak var animatedImageView: FLAnimatedImageView!
    
    private var row = 6
    
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
        
        self.configWeekView()
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
}

extension CalendarViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    func configureCalendar(calendar: JTAppleCalendarView) -> (startDate: NSDate, endDate: NSDate, numberOfRows: Int, calendar: NSCalendar) {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        
        let firstDate = formatter.dateFromString("2016 01 05")
        let secondDate = NSDate()
        let aCalendar = NSCalendar.currentCalendar() // Properly configure your calendar to your time zone here
        
        return (startDate: firstDate!, endDate: secondDate, numberOfRows: row, calendar: aCalendar)
    }
    
    func calendar(calendar: JTAppleCalendarView, isAboutToDisplayCell cell: JTAppleDayCellView, date: NSDate, cellState: CellState) {
        guard let cell = cell as? CalendarCell else { return }
        cell.setupCellBeforeDisplay(cellState, date: date)
    }
    
    func calendar(calendar: JTAppleCalendarView, didSelectDate date: NSDate, cell: JTAppleDayCellView?, cellState: CellState) {
        guard let cell = cell as? CalendarCell else { return }
        cell.cellSelectionChanged(cellState, date: date)
    }
    
    func calendar(calendar: JTAppleCalendarView, didDeselectDate date: NSDate, cell: JTAppleDayCellView?, cellState: CellState) {
        guard let cell = cell as? CalendarCell else { return }
        cell.cellSelectionChanged(cellState, date: date)
    }
    
    func calendar(calendar: JTAppleCalendarView, didScrollToDateSegmentStartingWithdate startDate: NSDate, endingWithDate endDate: NSDate) {
        self.titleLabel.text = Localized("calendar") + "-" + startDate.formattedDateWithFormat(monthFormat)
    }
    
    func calendar(calendar: JTAppleCalendarView, canSelectDate date: NSDate, cell: JTAppleDayCellView, cellState: CellState) -> Bool {
        guard let cell = cell as? CalendarCell else { return true }
        return true
    }
}

