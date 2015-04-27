//
//  APIResponse.swift
//  NewsLater
//
//  Created by University of Missouri on 4/23/15.
//  Copyright (c) 2015 Matt Zuzolo. All rights reserved.
//

import Foundation
import ObjectMapper

//Our Basic Story
class APIResponse: Mappable {
    var status: String?
    var results: [Article]?
    
    required init?(_ map: Map) {
        mapping(map)
    }
    
    //Basic mapping function.
    func mapping(map: Map) {
        status        <- map["status"]
        results       <- map["results"]
        }
}