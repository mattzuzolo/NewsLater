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
    var articlesNYT = Set<Article>()
    var articlesGD = Set<Article>()
    var articlesUSAT = Set<Article>()
    var filteredArticles = Array<Article>()
    
    //Dictionary type to help facilitate a more generic load method
    let urlDictionary = ["NYT": "https://api.nytimes.com/svc/topstories/v1/home.json?api-key=3caa4c3969858fadeaa4bbe5a3529235:13:71572887", "GD": "http://content.guardianapis.com/search?api-key=p7x4zprsbrgjpwx5nwuhqzkz&show-fields=thumbnail,byline&show-tags=all&days=3", "USAT": "http://api.usatoday.com/open/articles/mobile/topnews?encoding=json&api_key=qjc2b9y9ddpaj9buv9ksy4ju&days=3"]
    
    override init(){
        self.filteredArticles = Array<Article>() //Make sure it's a fresh empty array on init.
        self.articlesNYT = Set<Article>()
        self.articlesGD = Set<Article>()
        self.articlesUSAT = Set<Article>()
    }
    
    func loadArticles(api: String, completionHandler: (ArticleMapper, String?) -> Void) {
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
                    } else if(api == "GD"){
                        self.gdJsonParser(data, completionHandler: completionHandler)
                    } else if(api == "USAT"){
                        self.usatJsonParser(data, completionHandler: completionHandler)
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
                                                    var storyTags = Set<NSString>()
                                                    
                                                    //Description tags
                                                    if let descTags = story["des_facet"] as? NSArray {
                                                        for desc in descTags {
                                                            storyTags.insert(desc as! NSString) //Cross fingers on this one
                                                        }
                                                    }
                                                    
                                                    //Organization tags
                                                    if let orgTags = story["org_facet"] as? NSArray {
                                                        for org in orgTags {
                                                            storyTags.insert(org as! NSString)
                                                        }
                                                    }
                                                    
                                                    //Person tags
                                                    if let persTags = story["per_facet"] as? NSArray {
                                                        for per in persTags {
                                                            storyTags.insert(per as! NSString)
                                                        }
                                                    }
                                                    
                                                    //Add it all into our stories array
                                                    articlesNYT.insert(Article(headline: headline, publication: "New York Times", byline: byline, publishedDate: publishedDate, url: url, thumbnailUrl: nil, tags: storyTags))
                                                }
                                                //apiArraysDictionary["NYT"] = articlesNYT
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
    
    func gdJsonParser(jsonData: NSData, completionHandler: (ArticleMapper, String?) -> Void){
        var jsonError: NSError?
        
        if let jsonResults = NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers, error: &jsonError) as? NSDictionary {
            if let jsonResult = jsonResults["response"] as? NSDictionary {
            //if let jsonResult = jsonResponse?.fi {
            //if (jsonResults.count > 0) {
                
                //for jsonResult in jsonResponse! {
                //    let stattest = jsonResult["status"]
                //}
                //let jsonResponse = jsonResults["response"] as? NSDictionary
                if let status = jsonResult["status"] as? NSString {
                    if(status == "ok") {
                        let num_results = jsonResult["num_results"] as? Int
                        if let results = jsonResult["results"] as? NSArray {
                            for story in results {
                                if let headline = story["webTitle"] as? String {
                                    if let url = story["webUrl"] as? NSString {
                                        //Note there is a property "format" that indicates type including thumbnail
                                        var storyMedia = Array<NSString>()
                                        if let media = story["multimedia"] as? NSArray {
                                            for mediaData in media {
                                                if let mediaUrl = mediaData["url"] as? NSString {
                                                    storyMedia.append(mediaUrl) //Apparently inside of if let's they are unwrapped
                                                }
                                            }
                                        }
                                        var byline : String?
                                        var publishedDate : NSString?
                                        if let fields = story["fields"] as? NSDictionary {
                                            byline = fields["byline"] as? String
                                            publishedDate = fields["webPublicationDate"] as? NSString
                                        }
                                        //Get Tags
                                        var storyTags = Set<NSString>()
                                        
                                        //Description tags
                                        if let tags = story["tags"] as? NSArray {
                                            for tagDetails in tags {
                                                storyTags.insert(tagDetails["webTitle"] as! NSString) //Cross fingers on this one
                                            }
                                        }
                                        
                                        //Add it all into our stories array
                                        articlesGD.insert(Article(headline: headline, publication: "The Guardian", byline: byline, publishedDate: publishedDate, url: url, thumbnailUrl: nil, tags: storyTags))
                                    
                                        
                                    }
                                }
                                
                            }
                            //apiArraysDictionary["GD"] = articlesGD
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
    
    func usatJsonParser(jsonData: NSData, completionHandler: (ArticleMapper, String?) -> Void){
        var jsonError: NSError?
        
        if let jsonResults = NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers, error: &jsonError) as? NSDictionary {
            if let stories = jsonResults["stories"] as? NSArray {
                for story in stories {
                    if let headline = story["title"] as? String {
                        if let url = story["link"] as? NSString {
                            if let abstract = story["description"] as? NSString {
                                
                                //Note there is a property "format" that indicates type including thumbnail
                                var storyMedia = Array<NSString>()
                                if let media = story["multimedia"] as? NSArray {
                                    for mediaData in media {
                                        if let mediaUrl = mediaData["url"] as? NSString {
                                            storyMedia.append(mediaUrl) //Apparently inside of if let's they are unwrapped
                                        }
                                    }
                                }
                                let publishedDate = story["published_date"] as? NSString
                                //Get Tags
                                //var storyTags = Array<NSString>()
                                
                                //Description tags
                                var storyTags = split(headline) {$0 == " "}
                                var tagSet = Set(storyTags)
                                var nonTags = Set(["he","she","said","and","but","or","nor","the","to","is","a","an","in","had","has","when","where","what","how","there","then","this"])
                                
                                tagSet = tagSet.subtract(nonTags)
                                
                                //let thumbnailUrl = NSURL.fileURLWithPath("usatoday.png")
                                
                                //Add it all into our stories array
                                articlesUSAT.insert(Article(headline: headline, publication: "USA Today", byline: "", publishedDate: publishedDate, url: url, thumbnailUrl: nil, tags: tagSet))
                            }
                            //apiArraysDictionary["USAT"] = articlesUSAT
                        }
                    }
                    
                }
            }
            dispatch_async(dispatch_get_main_queue(), {completionHandler(self, nil)})
            
        } else {
            if let unwrappedError = jsonError {
                dispatch_async(dispatch_get_main_queue(), {completionHandler(self, "\(unwrappedError)")})
            }
        }
    }

    func filterAPI(fresh: Bool, delegate: AppDelegate){
        //Filter all the things.
        var filteredSet = Set<Article>()
        let readArticles = delegate.getReadArticlesSet()
        
        if(fresh){
           self.filteredArticles = Array<Article>()
        }
        
        //Filter out any read articles
        articlesNYT = articlesNYT.subtract(readArticles)
        articlesGD = articlesGD.subtract(readArticles)
        articlesUSAT = articlesUSAT.subtract(readArticles)
        
        self.filteredArticles += Array(articlesNYT)
        self.filteredArticles += Array(articlesGD)
        self.filteredArticles += Array(articlesUSAT)
        //Compare article tags to determine if articles in different sets are too similar
        //For the time being we are placing a higher priority on NYT articles, then Guardian, then USAToday
        //Rational: NYT provides a heavily curated list with the API we are using, the Guardian has a more focused list
        //with actual tags provided, and finally the USAToday tags are derived and the API is archaic.
        //for article in articlesNYT {
        //    article.tags?.intersect()
        //}
    }
}