//
//  ArticleViewController.swift
//  NewsLater
//
//  Created by Mike on 4/16/15.
//  Copyright (c) 2015 Matt Zuzolo. All rights reserved.
//

import UIKit

class ArticleViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func share(sender: AnyObject) {
        let text = "Sharing Google website for testing!"
        
        //will take in aritcle url instead of google.com
        let url : NSURL = NSURL(fileURLWithPath: "http://www.google.com/")!
        
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
}
