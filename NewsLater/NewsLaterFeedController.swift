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
    
    @IBOutlet weak var feedView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            configureCell(cell)
            return cell
        }else{
            var cell2 = tableView.dequeueReusableCellWithIdentifier("setting_cell", forIndexPath: indexPath) as! ReminderTableViewCell
            cell2.title?.text = "Remind me to come back!"
            cell2.title?.textColor = UIColor.redColor()
            return cell2
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath){
        if(indexPath.section == 0){
            if editingStyle == UITableViewCellEditingStyle.Delete {
                currentArticles.removeAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
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
    
    func configureCell(cell: ArticleTableViewCell){
        let width = feedView.frame.width
        let height = feedView.rowHeight
        
        let views = ["thumbnail": cell.thumbnail, "title": cell.title, "subtitle": cell.subtitle]
        
        //Visual Format Language representation of needed constraints
        let imageHStr = "H:|-\(width / 10)-[thumbnail(<=\(height * 8 / 10))]-(>=\(width - ((8 * height / 10) + width / 10)))-|"
        let imageVStr = "V:|-\(height / 10)-[thumbnail(<=\(height * 8 / 10))]-(>=\(height / 10))-|"
        let titleHStr = "H:|-\((2 * width / 10) + (height * 8 / 10))-[title]-|"
        let subtitleHStr = "H:|-\((2 * width / 10) + (height * 8 / 10))-[subtitle]-|"
        let labelVStr = "V:|-\(height / 10)-[title][subtitle]-\(height / 10)-|"
        
        cell.thumbnail.setTranslatesAutoresizingMaskIntoConstraints(false)
        cell.title.setTranslatesAutoresizingMaskIntoConstraints(false)
        cell.subtitle.setTranslatesAutoresizingMaskIntoConstraints(false)
        

        var thumbnailConstrH = NSLayoutConstraint.constraintsWithVisualFormat(imageHStr, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        var thumbnailConstrV =  NSLayoutConstraint.constraintsWithVisualFormat(imageVStr, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        var titleConstrH = NSLayoutConstraint.constraintsWithVisualFormat(titleHStr, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        var subtitleConstrH = NSLayoutConstraint.constraintsWithVisualFormat(subtitleHStr, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        var labelConstrV = NSLayoutConstraint.constraintsWithVisualFormat(labelVStr, options: NSLayoutFormatOptions(0), metrics: nil, views: views)
        
        cell.addConstraints(thumbnailConstrH)
        cell.addConstraints(thumbnailConstrV)
        cell.addConstraints(titleConstrH)
        cell.addConstraints(subtitleConstrH)
        cell.addConstraints(labelConstrV)
    }
}
