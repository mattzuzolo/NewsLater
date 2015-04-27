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
    
    @IBOutlet weak var feedView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        articleMapper.loadArticles({
            (articles, errorString) -> Void in
            if let unwrappedErrorString = errorString {
                //Error, so popup an alert
                self.showError("Could not load data from NYTimes", error: errorString!)
                
            } else {
                self.feedView.reloadData()
            }
        })
    }
    
    //Start Copy/Pasta from Homework:
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articleMapper.articlesNYT.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //Why does it need as! instead of as  ... look this up
        let cell = tableView.dequeueReusableCellWithIdentifier("article_cell", forIndexPath: indexPath) as! UITableViewCell
        
        cell.textLabel?.text = articleMapper.articlesNYT[indexPath.row].headline!
        cell.detailTextLabel?.text = articleMapper.articlesNYT[indexPath.row].publishedDate?.description
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedArticle = articleMapper.articlesNYT[indexPath.row]
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
}
