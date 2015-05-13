//
//  ReminderPickerViewController.swift
//  NewsLater
//
//  Created by Grace on 4/30/15.
//  Copyright (c) 2015 Matt Zuzolo. All rights reserved.
//

import UIKit

class ReminderPickerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate  {

    @IBOutlet weak var reminderTimePicker: UIPickerView!
    
    @IBOutlet weak var save: UIBarButtonItem!
    let days = ["Days", "0", "1", "2", "3", "4", "5", "6", "7"]
    let hours = ["Hours", "00",  "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23"]
    
    //default start index if no previously saved time interval
    var dayPickerStartIndex = 1
    var hourPickerStartIndex = 1
    //default selected time interval if no selection done and no previously saved time interval
    var selectedDay: String = "0"
    var selectedHour: String = "00"
    //previously saved time interval
    var preDay: String?
    var preHour: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reminderTimePicker.dataSource = self
        reminderTimePicker.delegate = self
        
        //set start index and selection time interval to previously saved time interval
        dayPickerStartIndex = (preDay!.toInt()! + 1)
        hourPickerStartIndex = (preHour!.toInt()! + 1)
        selectedDay = preDay!
        selectedHour = preHour!
        
        reminderTimePicker.selectRow(dayPickerStartIndex, inComponent: 0, animated: false)
        reminderTimePicker.selectRow(hourPickerStartIndex, inComponent: 1, animated: false)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2 //2 columns of data
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (component == 0){
            return days.count
        }
        else{
            return hours.count
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if(component == 0){
            return days[row]
        }else{
            return hours[row]
        }
        
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(component == 0){
            selectedDay = "\(days[row])"
            //if user select the Day title disable save button
            if(selectedDay == "Days"){
                save.enabled = false
            }else{
                save.enabled = true
            }
        }else{
            //if user select the Hour title disable save button
            selectedHour = "\(hours[row])"
            if(selectedHour == "Hours"){
                save.enabled = false
            }else{
                save.enabled = true
            }
        }
        
    }
    
    @IBAction func backToReminder(sender: AnyObject) {
        performSegueWithIdentifier("returnToReminderList", sender: self)
    }
    
    @IBAction func saveReminder(sender: AnyObject) {
        performSegueWithIdentifier("saveToReminderList", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "saveToReminderList") {
            var destinationViewController = segue.destinationViewController as! RemindersViewController
            //if user selected 0 days and 00 hours, use the last notification time interval
            if(selectedDay == "0" && selectedHour == "00"){
                destinationViewController.setString(preDay!, hour: preHour!)
            }else{
                destinationViewController.setString(selectedDay, hour: selectedHour)
            }
        }
    }
    

}
