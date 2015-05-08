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

    let days = ["0", "1", "2", "3", "4", "5", "6", "7"]
    let hours = ["00",  "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23"]
    var selected : String = "";
    
    let reminderPickerStartIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reminderTimePicker.dataSource = self
        reminderTimePicker.delegate = self
        
        reminderTimePicker.selectRow(reminderPickerStartIndex, inComponent: 0, animated: false)
        
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return days.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return days[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectRow = "\(days[row])"
        
        selected = selectRow
    }


}
