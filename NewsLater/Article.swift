//
//  Article.swift
//  NewsLater
//
//  Created by University of Missouri on 4/16/15.
//  Copyright (c) 2015 Matt Zuzolo. All rights reserved.
//

import Foundation
import ObjectMapper

//Our Basic Story
class Article: NSObject, Mappable, NSCoding {
    var headline: NSString?
    var publication: NSString?
    var byline: NSString?
    var publishedDate: NSDate?
    var url: NSString?
    var thumbnailUrl: NSString? //Points to the Thumbnail object
    var tags: [NSString]?
    
    required init?(_ map: Map) {
        super.init()
        mapping(map)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init()
        self.headline = aDecoder.decodeObjectForKey("headline") as! NSString?
        self.publication = aDecoder.decodeObjectForKey("publication") as! NSString?
        self.byline = aDecoder.decodeObjectForKey("byline") as! NSString?
        self.publishedDate = aDecoder.decodeObjectForKey("publishedDate") as! NSDate?
        self.url = aDecoder.decodeObjectForKey("url") as! NSString?
        self.thumbnailUrl = aDecoder.decodeObjectForKey("thumbnailUrl") as! NSString?
        self.tags = aDecoder.decodeObjectForKey("tags") as! [NSString]?
        
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.headline, forKey: "headline")
        aCoder.encodeObject(self.publication, forKey: "publication")
        aCoder.encodeObject(self.byline, forKey: "byline")
        aCoder.encodeObject(self.publishedDate, forKey: "publishedDate")
        aCoder.encodeObject(self.url, forKey: "url")
        aCoder.encodeObject(self.thumbnailUrl, forKey: "thumbnailUrl")
        aCoder.encodeObject(self.tags, forKey: "tags")

    }
    
    //Basic mapping function.
    func mapping(map: Map) {
        publication     <- map["publication"]
        if publication != nil {
            if(publication!.isEqual("New York Times")){
                //Do all the NYT mapping
            } else if(publication!.isEqual("Washington Post")){
                //Do all the WP mapping
            } else if(publication!.isEqual("USA Today")){
                //Do all the USA Today mapping
            }
            //Do all the unified mapping.
            headline        <- map["headline"]
            byline          <- map["byline"]
            publishedDate   <- (map["publishedDate"], DateTransform())
            url             <- map["url"]
            thumbnailUrl    <- map["thumbnailUrl"]
            tags            <- map["tags"]
        }
    }
    
    func loadFeed(){
        
    }
    
}

