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
                                self.feedView.reloadData()
                            }
                        })
                    }
                })
               
            }
        })
        
       
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articleMapper.filteredArticles.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("article_cell", forIndexPath: indexPath) as! ArticleTableViewCell
        cell.title?.text = articleMapper.filteredArticles[indexPath.row].headline!
        cell.subtitle?.text = "\(articleMapper.filteredArticles[indexPath.row].publication!) / \(articleMapper.filteredArticles[indexPath.row].publishedDate?.description)"
        cell.configureCell(feedView.rowHeight, frameWidth: feedView.frame.width)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedArticle = articleMapper.filteredArticles[indexPath.row]
        appDelegate.addArticle(selectedArticle!)
        //performSegueWithIdentifier("goToArticle", sender: self)
    }
    
    @IBAction func returnToFeed(segue: UIStoryboardSegue) {
        
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
