//
//  DiningTableViewController.swift
//  WVU Mobile
//
//  Created by Kaitlyn Landmesser on 1/3/17.
//  Copyright © 2017 WVU Mobile. All rights reserved.
//

import UIKit
import FSCalendar

class DiningTableViewController: UIViewController {
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var menuTable: UITableView!
    
    var menu = Menu(diningHall: .Arnold)
    var diningHall = DiningHall.Arnold
    
    var selectedDate = Date()
    
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    
    private let gregorian = Calendar(identifier: .gregorian)
    private let calendarRange = 60.0 * 60.0 * 24.0 * 60.0 // one month
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.calendar.select(Date())
        self.calendar.scope = .week
        self.calendar.scopeGesture.isEnabled = true
        
        loadToday()

    }
    
    func loadToday() {
        DispatchQueue.global().async {
            MenuRequest.getMenu(on: Date(), at: self.diningHall, completion: { result in
                DispatchQueue.main.sync {
                    if let r = result {
                        self.menu = r
                    }
                    self.menuTable.reloadData()
                }
            })
        }
    }
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        return Date().addingTimeInterval(-2.0)
    }
    
    func maximumDate(for calendar: FSCalendar) -> Date {
        return Date().addingTimeInterval(calendarRange)
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        NSLog("change page to \(self.formatter.string(from: calendar.currentPage))")
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        NSLog("calendar did select date \(self.formatter.string(from: date))")
        if monthPosition == .previous || monthPosition == .next {
            calendar.setCurrentPage(date, animated: true)
        }
        
        self.selectedDate = date
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendarHeightConstraint.constant = bounds.height
        view.layoutIfNeeded()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu.menu.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menu-item", for: indexPath)
        
        cell.textLabel?.text = menu.menu[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}