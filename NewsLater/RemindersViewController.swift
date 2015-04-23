//
//  RemindersViewController.swift
//  NewsLater
//
//  Created by Mike on 4/16/15.
//  Copyright (c) 2015 Matt Zuzolo. All rights reserved.
//

import UIKit

class RemindersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var reminderTable: UITableView!
    var reminders:[String] = ["6:00AM", "7:00AM", "8:00AM"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return 2
        }else{
            return reminders.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cellIdentifier: NSString?
        
        var cell:UITableViewCell?
        
        if(indexPath.section == 0){
            cellIdentifier = "staticCellType"
            cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier as! String, forIndexPath: indexPath) as? UITableViewCell
            cell!.textLabel?.text = "switch"
            
        }else if(indexPath.section == 1){
            cellIdentifier = "dynamicCellType"
            cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier as! String, forIndexPath: indexPath) as? UITableViewCell
            cell!.textLabel?.text = reminders[indexPath.row]
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //selectedReminder = reminders[indexPath.row]
    }
    
}

