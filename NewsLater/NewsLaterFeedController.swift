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
    
    let dateFormatter = NSDateFormatter()
    
    @IBOutlet weak var feedView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set up the date formatter
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        //set row height so that 5 stories will fill feed
        feedView.rowHeight = feedView.frame.height / 5

        //Chained completionHandlers to ensure they all get called before loading the data. 
        //Main issue with this (other than that they can't parrallel call) is that there
        //is a total fail if even one of the calls fails.
        if(articleMapper.filteredArticles.count < 5){
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
                                    
                                    self.currentArticles = Array(self.articleMapper.filteredArticles[0...4])
                                    self.articleMapper.filteredArticles.removeRange(0...4)
                                    self.feedView.reloadData()
                                }
                            })
                        }
                    })
                   
                }
            })
        }
        else{

            currentArticles = Array(articleMapper.filteredArticles[0...4])
            articleMapper.filteredArticles.removeRange(0...4)
            feedView.reloadData()
        }
        
       
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
            cell.subtitle?.text = currentArticles[indexPath.row].publishedDate?.description
            cell.configureCell(feedView.rowHeight, frameWidth: feedView.frame.width)
            return cell
        }else{
            var cell2:UITableViewCell?
            cell2 = tableView.dequeueReusableCellWithIdentifier("setting_cell", forIndexPath: indexPath) as? UITableViewCell
            cell2!.textLabel?.text = "Remind me to come back!"
            cell2!.textLabel?.textColor = UIColor.redColor()
            return cell2!
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section != 1) {
            selectedArticle = articleMapper.filteredArticles[indexPath.row]
            appDelegate.addArticle(selectedArticle!)
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
    
}
