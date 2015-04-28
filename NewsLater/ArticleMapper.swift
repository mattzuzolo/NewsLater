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
        callAPI(NYTUrl, completionHandler: completionHandler)

        
        //Do the filtering stuff here
        filteredArticles += articlesNYT
        dispatch_async(dispatch_get_main_queue(), {completionHandler(self, nil)})
    }
    
    func loadNYTArticles(URL: String, completionHandler: (ArticleMapper, String?) -> Void) {
        articlesNYT = Array<Article>() //Get a fresh Array to load in stories
        
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
                    self.jsonParser(data, completionHandler: completionHandler)
                }
            })
            
            jsonParseTask.resume()
        } else {
            dispatch_async(dispatch_get_main_queue(), {
                completionHandler(self, "Invalid URL")
            })
        }
    }
    
    
    func callAPI(URL: String, completionHandler: (ArticleMapper, String?)-> Void) -> [Article]{
        var articles = Array<Article>()
        var jsonError: NSError?
        
        //var apiResponse = APIResponse()
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
                    self.jsonParser(data, completionHandler: completionHandler)
                    //We'll probably need to parse out each individual article before mapping it.
                    //let jsonData = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    //apiResponse = Mapper<APIResponse>().map(jsonData!)!
                    /*if let jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &jsonError) as? NSDictionary {
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
                    }*/
                }
            })
            
            
            return articles
        } else {
            dispatch_async(dispatch_get_main_queue(), {
                completionHandler(self, "Invalid URL")
            })
            return []
        }
        
    }
    
    func jsonParser(jsonData: NSData, completionHandler: (ArticleMapper, String?) -> Void){
        var jsonError: NSError?
        
        //So this way works, but I feel like Swift should be smarter than this
        //IE: map jsonFields to object parameters with the same key.
        //Something like var TopStories = JSONParse(jsonData, Story.class) or somesuch.  Oh well.
        if let jsonResult = NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers, error: &jsonError) as? NSDictionary {
            if (jsonResult.count > 0) {
                if let status = jsonResult["status"] as? NSString {
                    if(status == "OK") {
                        let num_results = jsonResult["num_results"] as? Int
                        if let results = jsonResult["results"] as? NSArray {
                            for story in results {
                                if let headline = story["title"] as? String {
                                    if let url = story["url"] as? NSString {
                                        if let byline = story["byline"] as? String {
                                            if let publishedDate = story["published_date"] as? NSString {
                                                if let abstract = story["abstract"] as? NSString {
                                                    
                                                    //get media, assume 0 is the thumbnail
                                                    //Note there is a property "format" that indicates type including thumbnail
                                                    var storyMedia = Array<NSString>()
                                                    if let media = story["multimedia"] as? NSArray {
                                                        for mediaData in media {
                                                            if let mediaUrl = mediaData["url"] as? NSString {
                                                                storyMedia.append(mediaUrl) //Apparently inside of if let's they are unwrapped
                                                            }
                                                        }
                                                    }
                                                    
                                                    //Get Tags
                                                    var storyTags = Array<NSString>()
                                                    
                                                    //Description tags
                                                    if let descTags = story["des_facet"] as? NSArray {
                                                        for desc in descTags {
                                                            storyTags.append(desc as! NSString) //Cross fingers on this one
                                                        }
                                                    }
                                                    
                                                    //Organization tags
                                                    if let orgTags = story["org_facet"] as? NSArray {
                                                        for org in orgTags {
                                                            storyTags.append(org as! NSString)
                                                        }
                                                    }
                                                    
                                                    //Person tags
                                                    if let persTags = story["per_facet"] as? NSArray {
                                                        for per in persTags {
                                                            storyTags.append(per as! NSString)
                                                        }
                                                    }
                                                    
                                                    //Add it all into our stories array
                                                    filteredArticles.append(Article(headline: headline, publication: "New York Times", byline: byline, publishedDate: publishedDate, url: url, thumbnailUrl: nil, tags: storyTags))
                                                }
                                            }
                                        }
                                    }
                                }
                                
                            }
                        }
                        dispatch_async(dispatch_get_main_queue(), {completionHandler(self, nil)})
                    }
                    //Handle non-OK status types here
                }
            }
        } else {
            if let unwrappedError = jsonError {
                dispatch_async(dispatch_get_main_queue(), {completionHandler(self, "\(unwrappedError)")})
            }
        }
    }
}