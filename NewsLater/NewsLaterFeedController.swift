//
//  NewsLaterFeedController.swift
//  NewsLater
//
//  Created by University of Missouri on 4/14/15.
//  Copyright (c) 2015 Matt Zuzolo. All rights reserved.
//

import UIKit

class NewsLaterFeedController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    var articleMapper: ArticleMapper = ArticleMapper()
    var selectedArticle: Article?
    var currentArticles = Array<Article>()
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    //Store user provided details in the future and for now the time since last opened.
    let defaults = NSUserDefaults.standardUserDefaults()
    var daysForNewArticles = 3
    
    @IBOutlet weak var feedView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set row height so that 5 stories will fill feed
        feedView.rowHeight = feedView.frame.height / 5
        
        defaults.setObject(NSDate(), forKey: "lastReadNews")
        
        //Check the last time the app was opened. If never opened us default of 3 days
        let lastReadNews = defaults.objectForKey("lastReadNews") as! NSDate!
        if(lastReadNews != nil){
            daysForNewArticles = Int(lastReadNews.timeIntervalSinceNow) * -1 / 3600
            if(daysForNewArticles > 1){
                defaults.setObject(NSDate(), forKey: "lastReadNews")
            }else{
                daysForNewArticles = daysForNewArticles / 24
            }
        }
        
        reloadFilteredArticles(daysForNewArticles)
    }
    
    override func viewWillAppear(animated: Bool) {
        var indexPath = NSIndexPath(forRow: 0, inSection: 1)
        self.feedView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return currentArticles.count
        }else{
            return 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(indexPath.section == 0){
            let cell = tableView.dequeueReusableCellWithIdentifier("article_cell", forIndexPath: indexPath) as! ArticleTableViewCell
            cell.title?.text = currentArticles[indexPath.row].headline!
            
            //let date = dateFormatter.dateFromString(currentArticles[indexPath.row].publishedDate!.description)
            //println(date)
            cell.subtitle?.text = currentArticles[indexPath.row].publishedDate?.description

            if (currentArticles[indexPath.row].thumbnailUrl == nil){
                cell.thumbnail.image = UIImage(named: "BlankThumbnail")
            }
            else{
                let imageData = NSData(contentsOfURL: currentArticles[indexPath.row].thumbnailUrl!)
                if (imageData == nil){
                    cell.thumbnail.image = UIImage(named: "BlankThumbnail")
                }
                else{
                    let image = UIImage(data: imageData!)
                    cell.thumbnail.image = image!
                }
               
            }
            cell.configureCell(feedView.rowHeight, frameWidth: feedView.frame.width)
            return cell
        }else{
            var cell2 = tableView.dequeueReusableCellWithIdentifier("setting_cell", forIndexPath: indexPath) as!  ReminderTableViewCell
            cell2.title?.text = "Remind me to come back!"
            cell2.title?.textColor = UIColor.redColor()
            return cell2
        }
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.section == 0){
			if editingStyle == UITableViewCellEditingStyle.Delete {
                appDelegate.addReadArticles(currentArticles[indexPath.row])
				currentArticles.removeAtIndex(indexPath.row)
				tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
				if(articleMapper.filteredArticles.count > 0){
					currentArticles.append(articleMapper.filteredArticles[0])
					articleMapper.filteredArticles.removeAtIndex(0)
					feedView.reloadData()
				}
                //Make sure we don't go back more than a week at any given time when repopulating articles
                else if(daysForNewArticles < 6){
					reloadFilteredArticles(daysForNewArticles + 2) //Increment by 2 days
				}
                else{
                    reloadFilteredArticles(7)
                }
			}
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section != 1) {
            var cell = tableView.cellForRowAtIndexPath(indexPath) as! ArticleTableViewCell
            cell.title.textColor = UIColor(red: 102.0 / 255.0, green: 102.0 / 255.0, blue: 102.0/255.0, alpha: 1.0)

            selectedArticle = currentArticles[indexPath.row]
            appDelegate.addReadArticles(selectedArticle!)
            appDelegate.addRecentlyReadArticle(selectedArticle!)
            performSegueWithIdentifier("toArticle", sender: self)
        }else{
            performSegueWithIdentifier("toReminder", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "toArticle"){
            let destinationViewController = segue.destinationViewController as! ArticleViewController
            if(selectedArticle != nil) {
                destinationViewController.article = selectedArticle
                destinationViewController.sourceView = "feed"
            }
        }
    }
    
    
    @IBAction func returnToFeed(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func saveToFeed(segue: UIStoryboardSegue) {
        
    }
    
    //Error alert example from http://stackoverflow.com/questions/29001629/issues-with-displaying-alerts-in-swift-after-clicking-ok-it-unwinds-segue
    func showError(title: String, error: String){
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func reloadFilteredArticles(days: Int){
        //Solution from NSCoder meeting. We all agree it's not ideal, but it works for what time we had
        //Chained completionHandlers to ensure they all get called before loading the data.
        //Main issue with this (other than that they can't parrallel call) is that there
        //is a total fail if even one of the calls fails.
        articleMapper.daysToSearch = days
        articleMapper.loadArticles("NYT", completionHandler:{
            (articles, errorString) -> Void in
            if let unwrappedErrorString = errorString {
                //Error, so popup an alert
                self.showError("Could not load data from New York Times", error: errorString!)
                
            } else {
                //self.articleMapper.filteredArticles += self.articleMapper.articlesNYT
                self.articleMapper.loadArticles("GD", completionHandler:{
                    (articles, errorString) -> Void in
                    if let unwrappedErrorString = errorString {
                        //Error, so popup an alert
                        self.showError("Could not load data from the Guardian", error: errorString!)
                        
                    } else {
                        //self.articleMapper.filteredArticles += self.articleMapper.articlesGD
                        self.articleMapper.loadArticles("USAT", completionHandler:{
                            (articles, errorString) -> Void in
                            if let unwrappedErrorString = errorString {
                                //Error, so popup an alert
                                self.showError("Could not load data from USA Today", error: errorString!)
                                
                            } else {
                                //self.articleMapper.filteredArticles += self.articleMapper.articlesUSAT
                                self.articleMapper.filterAPI(false, delegate: self.appDelegate) //bool value is if it's fresh or not.
                                if(self.currentArticles.count > 0){
                                    //Remove any duplicates (IE: top cell had an article that wasn't deleted or read yet)
                                    self.articleMapper.filteredArticles = Array(Set(self.articleMapper.filteredArticles).subtract(Set(self.currentArticles)))
                                    while(self.currentArticles.count < 5){
                                        self.currentArticles.append(self.articleMapper.filteredArticles[0])
                                        self.articleMapper.filteredArticles.removeAtIndex(0)
                                    }
                                }else{
                                    self.currentArticles = Array(self.articleMapper.filteredArticles[0...4])
                                    self.articleMapper.filteredArticles.removeRange(0...4)
                                }
                                self.feedView.reloadData()
                            }
                        })
                    }
                })
                
            }
        })
    }
}
