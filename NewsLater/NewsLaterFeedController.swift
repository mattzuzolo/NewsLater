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
    
    @IBOutlet weak var feedView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set row height so that 5 stories will fill feed
        feedView.rowHeight = feedView.frame.height / 5

        articleMapper.loadArticles("NYT", completionHandler:{
            (articles, errorString) -> Void in
            if let unwrappedErrorString = errorString {
                //Error, so popup an alert
                self.showError("Could not load data from New York Times", error: errorString!)
                
            } else {
                self.articleMapper.filteredArticles += self.articleMapper.articlesNYT
                self.articleMapper.loadArticles("GD", completionHandler:{
                    (articles, errorString) -> Void in
                    if let unwrappedErrorString = errorString {
                        //Error, so popup an alert
                        self.showError("Could not load data from the Guardian", error: errorString!)
                        
                    } else {
                        self.articleMapper.filteredArticles += self.articleMapper.articlesGD
                        self.articleMapper.loadArticles("USAT", completionHandler:{
                            (articles, errorString) -> Void in
                            if let unwrappedErrorString = errorString {
                                //Error, so popup an alert
                                self.showError("Could not load data from USA Today", error: errorString!)
                                
                            } else {
                                self.articleMapper.filteredArticles += self.articleMapper.articlesUSAT
                                self.articleMapper.filterAPI(true) //bool value is if it's fresh or not.
                                self.feedView.reloadData()
                            }
                        })
                    }
                })
               
            }
        })
        
       
    }
    
    //Start Copy/Pasta from Homework:
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articleMapper.filteredArticles.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("article_cell", forIndexPath: indexPath) as! UITableViewCell
        cell.title?.text = articleMapper.filteredArticles[indexPath.row].headline!
        cell.subtitle?.text = articleMapper.filteredArticles[indexPath.row].publishedDate?.description
        configureCell(cell)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedArticle = articleMapper.filteredArticles[indexPath.row]
        appDelegate.addArticle(selectedArticle!)
        //performSegueWithIdentifier("goToArticle", sender: self)
    }
    
    //End CopyPasta
    
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
