//
//  ArticleMapper.swift
//  NewsLater
//
//  Created by University of Missouri on 4/16/15.
//  Copyright (c) 2015 Matt Zuzolo. All rights reserved.
//

import Foundation
import ObjectMapper

class ArticleMapper: NSObject{
    var articlesNYT: [Article]?
    //var articlesWP: [Article]?
    //var articleUSAT: [Article]?
    
    let NYTUrl = "https://api.nytimes.com/svc/topstories/v1/home.json?api-key=3caa4c3969858fadeaa4bbe5a3529235:13:71572887"
    
    func loadArticles(completionHandler: (ArticleMapper, String?) -> Void){
        callAPI(NYTUrl, completionHandler: completionHandler)
    }
    
    func callAPI(URL: String, completionHandler: (ArticleMapper, String?) -> Void){
        if let url = NSURL(string: URL) {
            let urlRequest = NSMutableURLRequest(URL: url)
            let session = NSURLSession.sharedSession()
            let jsonParseTask = session.dataTaskWithRequest(urlRequest, completionHandler: {
                (data, response, error) -> Void in
                if error != nil {
                    dispatch_async(dispatch_get_main_queue(), {
                        completionHandler(self, error.localizedDescription)
                    })
                } else {
                    //self.jsonParser(data, completionHandler)
                    let jsonData = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    let articles = Mapper<Article>().map(jsonData)
                }
            })
            
            jsonParseTask.resume()
        } else {
            dispatch_async(dispatch_get_main_queue(), {
                completionHandler(self, "Invalid URL")
            })
        }
        
    }
    //let article = Mapper<Article>().map(JSONString)
}