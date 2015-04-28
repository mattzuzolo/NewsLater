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
    var articlesGD = Array<Article>()
    var articleUSAT = Array<Article>()
    var filteredArticles = Array<Article>()
    
    //Dictionary type to help facilitate a more generic load method
    var apiArraysDictionary = [String: [Article]]()
    let urlDictionary = ["NYT": "https://api.nytimes.com/svc/topstories/v1/home.json?api-key=3caa4c3969858fadeaa4bbe5a3529235:13:71572887", "GD": "guardianURL", "USAT": "USATURL"]
    
    override init(){
        self.apiArraysDictionary["NYT"] = articlesNYT
        self.apiArraysDictionary["GD"] = articlesGD
        self.apiArraysDictionary["USAT"] = articleUSAT
    }
    
    func loadArticles(api: String, completionHandler: (ArticleMapper, String?) -> Void) {
        apiArraysDictionary[api] = Array<Article>() //Get a fresh Array to load in stories
        
        let URL = urlDictionary[api];
        if let url = NSURL(string: URL!) {
            let urlRequest = NSMutableURLRequest(URL: url)
            let session = NSURLSession.sharedSession()
            let jsonParseTask = session.dataTaskWithRequest(urlRequest, completionHandler: {
                (data, response, error) -> Void in
                if error != nil {
                    dispatch_async(dispatch_get_main_queue(), {
                        completionHandler(self, error.localizedDescription)
                    })
                } else {
                    if(api == "NYT"){
                        self.nytJsonParser(data, completionHandler: completionHandler)
                    }
                }
            })
            
            jsonParseTask.resume()
        } else {
            dispatch_async(dispatch_get_main_queue(), {
                completionHandler(self, "Invalid URL")
            })
        }
    }
    
    func nytJsonParser(jsonData: NSData, completionHandler: (ArticleMapper, String?) -> Void){
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
                                                    articlesNYT.append(Article(headline: headline, publication: "New York Times", byline: byline, publishedDate: publishedDate, url: url, thumbnailUrl: nil, tags: storyTags))
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