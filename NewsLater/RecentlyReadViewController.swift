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
    var dateFormatterNYT = NSDateFormatter()
    var dateFormatterTG = NSDateFormatter()
    var recentlyRead: Array<Article>? = nil
    var selectedArticle: Article?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatterNYT.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        dateFormatterNYT.locale = NSLocale(localeIdentifier: "US_en_POSIX")
        
        dateFormatterTG.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatterTG.locale = NSLocale(localeIdentifier: "US_en_POSIX")
        
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
        
        var date: NSDate?
        println(recentlyRead![indexPath.row].publishedDate!.description)
        
        if recentlyRead![indexPath.row].publication! == "The Guardian"{
            println("The Guardian")
            date = dateFormatterTG.dateFromString(recentlyRead![indexPath.row].publishedDate!.description)
        }
        else{
            println("NYT")
            date = dateFormatterNYT.dateFromString(recentlyRead![indexPath.row].publishedDate!.description)
        }
        
        println(date)
        cell.subtitle?.text = "\(recentlyRead![indexPath.row].publication!) / \(recentlyRead![indexPath.row].publishedDate!.description)"
        
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
        selectedArticle = recentlyRead![indexPath.row]
        performSegueWithIdentifier("historyToArticle", sender: self)

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
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
