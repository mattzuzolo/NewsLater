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
    var reminders:[String] = ["6 days", "7 hours", "8 hours"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return 1
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
            cell!.textLabel?.text = "Reminde me to come back"
            
            var reminderSwitch=UISwitch(frame:CGRectMake(150, 300, 0, 0));
            cell?.accessoryView = reminderSwitch
            reminderSwitch.on = true
            reminderSwitch.setOn(true, animated: false);
            reminderSwitch.addTarget(self, action: "switchValueDidChange:", forControlEvents: .ValueChanged);
            self.view.addSubview(reminderSwitch);
            
        }else if(indexPath.section == 1){
            cellIdentifier = "dynamicCellType"
            cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier as! String, forIndexPath: indexPath) as? UITableViewCell
            cell!.textLabel?.text = "Come back in"
            cell!.detailTextLabel?.text = reminders[indexPath.row]
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //selectedReminder = reminders[indexPath.row]
    }
    
    func switchValueDidChange(sender:UISwitch!)
    {
        if (sender.on == true){
            println("on")
        }
        else{
            println("off")
        }
    }
    
}

