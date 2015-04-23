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
class Article: Mappable {
    var headline: String?
    var publication: String?
    var byline: String?
    var publishedDate: NSDate?
    var url: NSString?
    var thumbnailUrl: NSString? //Points to the Thumbnail object
    var tags: [NSString]?
    
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
        
    }
    
}

