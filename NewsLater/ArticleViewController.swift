//
//  ArticleViewController.swift
//  NewsLater
//
//  Created by Mike on 4/16/15.
//  Copyright (c) 2015 Matt Zuzolo. All rights reserved.
//

import UIKit

class ArticleViewController: UIViewController, UIWebViewDelegate {

    
    @IBOutlet weak var articleWebView: UIWebView!
    
    @IBOutlet weak var articleNavBar: UINavigationItem!

    
    var article : Article?
    //var url : NSURL?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        articleWebView.delegate = self
        
        if article != nil {
            articleNavBar.title = article!.publication
            
            //Get the URL and go to the page
            var url = NSURL(string: article!.url as! String)
            if url != nil {
                var requestPage = NSMutableURLRequest(URL: url!)
                articleWebView.loadRequest(requestPage)
            } else {
                showError("Error loading article", error: "Could not connect to " + article!.publication! + " to retrieve article.")
            }
        }
    }
    
    
    @IBAction func share(sender: AnyObject) {
        let text = "\"" + article!.headline! + "\"" + " share from News Later "
        let url : NSURL = NSURL(string: article!.url as! String)!
        
        //create an instance of UIActivityViewController
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [text, url], applicationActivities: nil)
        
        //exclude unneccesary activities
        activityViewController.excludedActivityTypes = [
            UIActivityTypePostToWeibo,
            UIActivityTypePrint,
            UIActivityTypeAssignToContact,
            UIActivityTypeSaveToCameraRoll,
            UIActivityTypeAddToReadingList,
            UIActivityTypePostToFlickr,
            UIActivityTypePostToVimeo,
            UIActivityTypePostToTencentWeibo
        ]
        
        //triggering the actual presentation
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    //Error alert popup
    func showError(title: String, error: String){
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
