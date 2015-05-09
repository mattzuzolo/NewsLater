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
    var recentlyRead: Array<Article>? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            return 0;
        }
        else{
            return recentlyRead!.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("article_cell", forIndexPath: indexPath) as! ArticleTableViewCell
        cell.title?.text = recentlyRead![indexPath.row].headline!
        cell.subtitle?.text = "\(recentlyRead![indexPath.row].publication!) / \(recentlyRead![indexPath.row].publishedDate?.description)"
        
        if (recentlyRead?[indexPath.row].thumbnailUrl == nil){
            cell.thumbnail.image = UIImage(named: "BlankThumbnail.png")
        }
        else{
            let imageData = NSData(contentsOfURL: recentlyRead![indexPath.row].thumbnailUrl!)
            if (imageData == nil){
                cell.thumbnail.image = UIImage(named: "BlankThumbnail.png")
            }
            else{
                let image = UIImage(data: imageData!)
                cell.thumbnail.image = image!
            }
            
        }
        cell.configureCell(tableView.rowHeight, frameWidth: tableView.frame.width)
        return cell
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        //do stuff
    }
}
