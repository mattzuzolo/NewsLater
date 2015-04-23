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
    var articlesNYT = Array<Article>()
    //var articlesWP: [Article]?
    //var articleUSAT: [Article]?
    var filteredArticles = Array<Article>()
    
    let NYTUrl = "https://api.nytimes.com/svc/topstories/v1/home.json?api-key=3caa4c3969858fadeaa4bbe5a3529235:13:71572887"
    
    func loadArticles(completionHandler: (ArticleMapper, String?) -> Void){
        articlesNYT = callAPI(NYTUrl, completionHandler: completionHandler)
    }
    
    func callAPI(URL: String, completionHandler: (ArticleMapper, String?) -> Void) -> [Article]{
        var articles = Array<Article>()
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
                    //We'll probably need to parse out each individual article before mapping it.
                    let jsonData = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    articles.append(Mapper<Article>().map(jsonData)!)
                }
            })
            
            jsonParseTask.resume()
            return articles
        } else {
            dispatch_async(dispatch_get_main_queue(), {
                completionHandler(self, "Invalid URL")
            })
            return []
        }
        
    }
    //let article = Mapper<Article>().map(JSONString)
}