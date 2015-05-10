//
//  RecentlyReadViewController.swift
//  NewsLater
//
//  Created by Mike on 4/16/15.
//  Copyright (c) 2015 Matt Zuzolo. All rights reserved.
//

import UIKit

class RecentlyReadViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var dateFormatter = NSDateFormatter()
    var recentlyRead: Array<Article>? = nil
    var selectedArticle: Article?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZ"
        dateFormatter.locale = NSLocale(localeIdentifier: "US_en_POSIX")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = tableView.frame.height / 5
        
        //load articles from app delegate
        recentlyRead = appDelegate.getRecentlyRead()
        tableView.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (recentlyRead == nil){
            return 1;
        }
        else{
            return recentlyRead!.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("article_cell", forIndexPath: indexPath) as! ArticleTableViewCell
        cell.title?.text = recentlyRead![indexPath.row].headline!
//        var testString = "2015-05-09T13:11:41-05:00"
//        println(recentlyRead![indexPath.row].publishedDate!.description)
//        //var date = NSDate()
//        var err = NSError()
//        //let testDate = dateFormatter.getObjectValue(&date, forString: testString, errorDescription: &err)
//        //println(testString)
//        let date2 = dateFormatter.dateFromString(recentlyRead![indexPath.row].publishedDate!.description)
//        let date = NSDate(timeIntervalSinceNow: 0)
//        //println(date)
//        let testDate = dateFormatter.dateFromString(testString)
//        //println(dateFormatter.stringFromDate(date))
//        println(testDate)
//        println(date2)
        
        cell.subtitle?.text = "\(recentlyRead![indexPath.row].publication!) / \(recentlyRead![indexPath.row].publishedDate?.description)"
        
        if (recentlyRead?[indexPath.row].thumbnailUrl == nil){
            cell.thumbnail.image = UIImage(named: "BlankThumbnail")
        }
        else{
            let imageData = NSData(contentsOfURL: recentlyRead![indexPath.row].thumbnailUrl!)
            if (imageData == nil){
                cell.thumbnail.image = UIImage(named: "BlankThumbnail")
            }
            else{
                let image = UIImage(data: imageData!)
                cell.thumbnail.image = image!
            }
            
        }
        cell.configureCell(tableView.rowHeight, frameWidth: tableView.frame.width)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("HIT")
        selectedArticle = recentlyRead![indexPath.row]
        performSegueWithIdentifier("historyToArticle", sender: self)

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println("Preparing for segue")
        if(segue.identifier == "historyToArticle"){
            //segue started
            let destinationViewController = segue.destinationViewController as! ArticleViewController
            if(selectedArticle != nil) {
                destinationViewController.article = selectedArticle
                destinationViewController.sourceView = "history"
            }
        }
    }
    
    @IBAction func returnToHistory(segue: UIStoryboardSegue) {
        
    }
}
