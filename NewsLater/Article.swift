//
//  Article.swift
//  NewsLater
//
//  Created by University of Missouri on 4/16/15.
//  Copyright (c) 2015 Matt Zuzolo. All rights reserved.
//

import Foundation
import ObjectMapper

//Base Article Object
class Article: NSObject {
    var headline: String?
    var publication: String?
    var byline: String?
    var publishedDate: NSString?
    var url: NSString?
    var thumbnailUrl: NSString? //Points to the Thumbnail object
    var tags: [NSString]?
    
    init(headline: String?, publication: String?, byline: String?, publishedDate: NSString?, url: NSString?, thumbnailUrl: NSString?, tags: [NSString]?){
        self.headline = headline
        self.publication = publication
        self.byline = byline
        self.publishedDate = publishedDate
        self.url = url
        self.thumbnailUrl = thumbnailUrl
        self.tags = tags        
    }
    /*
    required init?(_ map: Map) {
        mapping(map)
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
        
    }*/
    
}

