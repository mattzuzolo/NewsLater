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
        articlesNYT = callAPI(NYTUrl)
        
        
        //Do the filtering stuff here
        filteredArticles += articlesNYT
        dispatch_async(dispatch_get_main_queue(), {completionHandler(self, nil)})
    }
    
    func callAPI(URL: String) -> [Article]{
        var articles = Array<Article>()
        var jsonError: NSError?
        
        //var apiResponse = APIResponse()
        if let url = NSURL(string: URL) {
            let urlRequest = NSMutableURLRequest(URL: url)
            let session = NSURLSession.sharedSession()
            let jsonParseTask = session.dataTaskWithRequest(urlRequest, completionHandler: {
                (data, response, error) -> Void in
                if error != nil {
                    //dispatch_async(dispatch_get_main_queue(), {
                    //    completionHandler(self, error.localizedDescription)
                    //})
                    
                } else {
                    //self.jsonParser(data, completionHandler) 
                    //We'll probably need to parse out each individual article before mapping it.
                    //let jsonData = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    //apiResponse = Mapper<APIResponse>().map(jsonData!)!
                    if let jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &jsonError) as? NSDictionary {
                        if (jsonResult.count > 0) {
                            if let status = jsonResult["status"] as? NSString {
                                if(status == "OK") {
                                    let results = jsonResult["results"] as? NSArray
                                    for article in results!{
                                        let headline = article["title"] as? String
                                        let byline = article["byline"] as? String
                                        let publishedDate = article["published_date"] as? NSString
                                        let url = article["url"] as? NSString
                                        //var thumbnailUrl: NSString? //Points to the Thumbnail object
                                        //var tags: [NSString]?
                                        
                                        //Get Tags
                                        var storyTags = Array<NSString>()
                                        
                                        //Description tags
                                        if let descTags = article["des_facet"] as? NSArray {
                                            for desc in descTags {
                                                storyTags.append((desc as? NSString)!) //Cross fingers on this one
                                            }
                                        }
                                        
                                        //Organization tags
                                        if let orgTags = article["org_facet"] as? NSArray {
                                            for org in orgTags {
                                                storyTags.append((org as? NSString)!)
                                            }
                                        }
                                        
                                        //Person tags
                                        if let persTags = article["per_facet"] as? NSArray {
                                            for per in persTags {
                                                storyTags.append((per as? NSString)!)
                                            }
                                        }
                                        
                                        articles.append(Article(headline: headline, publication: "New York Times", byline: byline, publishedDate: publishedDate, url: url, thumbnailUrl: nil, tags: storyTags))
                                    }
                                }
                            }
                        }
                    }
                    //articles.append(Mapper<Article>().map(apiResponse.results[0] as! NSString)!)
                }
            })
            
            
            return articles
        } else {
            //dispatch_async(dispatch_get_main_queue(), {
            //    completionHandler(self, "Invalid URL")
            //})
            return []
        }
        
    }
    //let article = Mapper<Article>().map(JSONString)
}