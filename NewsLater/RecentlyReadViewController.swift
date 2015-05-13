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
        
        dateFormatterNYT.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'-5:00'"
        dateFormatterNYT.locale = NSLocale(localeIdentifier: "US_en_POSIX")
        
        dateFormatterTG.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatterTG.locale = NSLocale(localeIdentifier: "US_en_POSIX")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = tableView.frame.height / 5
        
        //load articles from app delegate
        recentlyRead = appDelegate.getRecentlyRead()
        if (recentlyRead != nil){
            recentlyRead = recentlyRead!.reverse()
        }
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
            cell.subtitle?.text = "The Guardian / \(recentlyRead![indexPath.row].getTimeSincePublished(dateFormatterTG))"
        }
        else{
            cell.subtitle?.text = "NY Times / \(recentlyRead![indexPath.row].getTimeSincePublished(dateFormatterNYT))"
        }
        
        //get correct thumbnail or use image not found icon
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
