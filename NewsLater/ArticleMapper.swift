//
//  ArticleMapper.swift
//  NewsLater
//
//  Created by University of Missouri on 4/16/15.
//  Copyright (c) 2015 Matt Zuzolo. All rights reserved.
//

import Foundation
//import ObjectMapper

class ArticleMapper: NSObject{
    var articlesNYT = Set<Article>()
    var articlesGD = Set<Article>()
    var articlesUSAT = Set<Article>()
    var filteredArticles = Array<Article>()
    
    //Set of words we don't want made into tags
    let nonTags = Set(["he","she","said","and","but","or","nor","the","to","is","a","an","at","of","in","had","has","when","where","what","with","how","there","then","this", "for", "after", "before", "however", "by"])
    
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
                                                    var thumbnailUrlString : String?
                                                    if let media = story["multimedia"] as? NSArray {
                                                        for mediaData in media {
                                                            let mediaType = (mediaData["format"] as! String).lowercaseString
                                                            if(mediaType.rangeOfString("thumb") != nil) {
                                                                thumbnailUrlString = (mediaData["url"] as? String)
                                                                break
                                                            }
                                                        }
                                                    }
                                                    
                                                    var thumbnailUrl : NSURL?
                                                    if(thumbnailUrlString != nil){
                                                        thumbnailUrl = NSURL(string: thumbnailUrlString!)
                                                    }  //Possibly easier to point to no thumbnail graphic here.
                                                    
                                                    //Get Tags
                                                    var storyTags = Set<String>()
                                                    
                                                    //Description tags
                                                    if let descTags = story["des_facet"] as? NSArray {
                                                        for desc in descTags {
                                                            var tags = (desc as! NSString).lowercaseString
                                                            tags = tags.stringByTrimmingCharactersInSet(NSCharacterSet.punctuationCharacterSet())
                                                            tags = tags.stringByTrimmingCharactersInSet(NSCharacterSet.symbolCharacterSet())
                                                            let tagSplit = split(tags) {$0 == " "}
                                                            for tag in tagSplit{
                                                                storyTags.insert(tag) //Cross fingers on this one
                                                            }
                                                        }
                                                    }
                                                    
                                                    //Organization tags
                                                    if let orgTags = story["org_facet"] as? NSArray {
                                                        for org in orgTags {
                                                            var tags = (org as! NSString).lowercaseString
                                                            tags = tags.stringByTrimmingCharactersInSet(NSCharacterSet.punctuationCharacterSet())
                                                            tags = tags.stringByTrimmingCharactersInSet(NSCharacterSet.symbolCharacterSet())
                                                            let tagSplit = split(tags) {$0 == " "}
                                                            for tag in tagSplit{
                                                                storyTags.insert(tag) //Cross fingers on this one
                                                            }
                                                        }
                                                    }
                                                    
                                                    //Person tags
                                                    if let persTags = story["per_facet"] as? NSArray {
                                                        for per in persTags {
                                                            var tags = (per as! NSString).lowercaseString
                                                            tags = tags.stringByTrimmingCharactersInSet(NSCharacterSet.punctuationCharacterSet())
                                                            tags = tags.stringByTrimmingCharactersInSet(NSCharacterSet.symbolCharacterSet())
                                                            let tagSplit = split(tags) {$0 == " "}
                                                            for tag in tagSplit{
                                                                storyTags.insert(tag) //Cross fingers on this one
                                                            }
                                                        }
                                                    }
                                                    
                                                    storyTags = storyTags.subtract(nonTags)
                                                    
                                                    //Add it all into our stories array
                                                    articlesNYT.insert(Article(headline: headline, publication: "New York Times", byline: byline, publishedDate: publishedDate, url: url, thumbnailUrl: thumbnailUrl, tags: storyTags))
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
                if let status = jsonResult["status"] as? NSString {
                    if(status == "ok") {
                        let num_results = jsonResult["num_results"] as? Int
                        if let results = jsonResult["results"] as? NSArray {
                            for story in results {
                                if let headline = story["webTitle"] as? String {
                                    if let url = story["webUrl"] as? NSString {
                                        var byline : String?
                                        let publishedDate = story["webPublicationDate"] as? NSString
                                        var thumbnailUrlString : String?
                                        if let fields = story["fields"] as? NSDictionary {
                                            byline = fields["byline"] as? String
                                            thumbnailUrlString = fields["thumbnail"] as? String
                                        }
                                        
                                        var thumbnailUrl : NSURL?
                                        if(thumbnailUrlString != nil){
                                            thumbnailUrl = NSURL(string: thumbnailUrlString!)
                                        }  //Possibly easier to point to no thumbnail graphic here.
                                        
                                        //Get Tags
                                        var storyTags = Set<String>()
                                        
                                        //Description tags
                                        if let tags = story["tags"] as? NSArray {
                                            for tagDetails in tags {
                                                var tagSplit = split((tagDetails["webTitle"] as! NSString).lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.punctuationCharacterSet()).stringByTrimmingCharactersInSet(NSCharacterSet.symbolCharacterSet())) {$0 == " "}
                                                for tag in tagSplit {
                                                    storyTags.insert(tag) //Cross fingers on this one
                                                }
                                            }
                                        }
                                        
                                        storyTags = storyTags.subtract(nonTags)
                                        
                                        //Add it all into our stories array
                                        articlesGD.insert(Article(headline: headline, publication: "The Guardian", byline: byline, publishedDate: publishedDate, url: url, thumbnailUrl: thumbnailUrl, tags: storyTags))
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
                            let abstract = story["description"] as? NSString
                                
                            let publishedDate = story["pubDate"] as? NSString
                                
                            //Description tags
                            //Deriving tags from the headline
                            let lowerHeadline = headline.lowercaseString
                            var storyTags = split(lowerHeadline) {$0 == " "}
                            var tagSet = Set(storyTags)
                            
                            tagSet = tagSet.subtract(nonTags)
                            
                            let thumbnailUrl = NSURL.fileURLWithPath("usatoday.png")
                            
                            //Add it all into our stories array
                            articlesUSAT.insert(Article(headline: headline, publication: "USA Today", byline: "", publishedDate: publishedDate, url: url, thumbnailUrl: thumbnailUrl, tags: tagSet))
                        
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
        
        
        if(fresh){
            //TODO Make sure this is the right way to do this (aka Ask Mike)...
            //Save the existing files, "fresh" assumes that all remaining files have been depleted/unwanted.
            delegate.saveArticles(self.filteredArticles, file: delegate.articlesFile)
           self.filteredArticles = Array<Article>()
        }
        
        //TEST just testing to make sure that articles get filtered out appropriately... Hint: They do
        //delegate.saveArticles(Array(self.articlesNYT), file: delegate.articlesFile)
        
        let readHeadlines = delegate.getReadArticlesHeadlines()
        
        //Filter out any read articles
        //articlesNYT = articlesNYT.subtract(readArticles)
        //articlesGD = articlesGD.subtract(readArticles)
        //articlesUSAT = articlesUSAT.subtract(readArticles)
        //Apperently, .Net has spoiled me.  Set's use type Hashable in Swift, so looking into that later
        //Switching to the hard way to get the job done:
        for nytArticle in articlesNYT {
            if readHeadlines.contains(nytArticle.headline!) {
                articlesNYT.remove(nytArticle)
            } // Swift needs an Elvis operator ?:
        }
        
        for gdArticle in articlesGD {
            if readHeadlines.contains(gdArticle.headline!) {
                articlesNYT.remove(gdArticle)
            } // Swift needs an Elvis operator ?:
        }
        
        for usatArticle in articlesUSAT {
            if readHeadlines.contains(usatArticle.headline!) {
                articlesNYT.remove(usatArticle)
            } // Swift needs an Elvis operator ?:
        }
        
        
        //Compare article tags to determine if articles in different sets are too similar
        //For the time being we are placing a higher priority on NYT articles, then Guardian, then USAToday
        //Rational: NYT provides a heavily curated list with the API we are using, the Guardian has a more focused list
        //with actual tags provided, and finally the USAToday tags are derived and the API is archaic.
        for NYTArticle in articlesNYT {
            var removed = false
            for GDArticle in articlesGD {
                let hits = NYTArticle.tags?.intersect(GDArticle.tags!)
                if(hits?.count >= 2){
                    if(arc4random_uniform(2) == 1){
                        articlesGD.remove(GDArticle)
                    } else{
                        articlesNYT.remove(NYTArticle)
                        removed = true
                        break //no need to continue search GD as we assume there are no dupes internally to an API
                    }
                }
                
            }
            
            if(removed){
                continue //no need to search USAT since GD will do that after NYT
            }
            
            for USATArticle in articlesUSAT {
                let hits = NYTArticle.tags?.intersect(USATArticle.tags!)
                if(hits?.count >= 2){
                    if(arc4random_uniform(2) == 1){
                        articlesGD.remove(USATArticle)
                    } else{
                        articlesNYT.remove(NYTArticle)
                        removed = true
                        break //no need to continue search USAT as we assume there are no dupes internally to an API
                    }
                }
            }
        }
        
        for GDArticle in articlesGD {
            for USATArticle in articlesUSAT {
                let hits = GDArticle.tags?.intersect(USATArticle.tags!)
                if(hits?.count >= 2){
                    if(arc4random_uniform(2) == 1){
                        articlesGD.remove(USATArticle)
                    } else{
                        articlesNYT.remove(GDArticle)
                        break //no need to continue search USAT as we assume there are no dupes internally to an API
                    }
                }
            }
        }
        
        self.filteredArticles += Array(articlesNYT)
        self.filteredArticles += Array(articlesGD)
        self.filteredArticles += Array(articlesUSAT)
    }
}