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
