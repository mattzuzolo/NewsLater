//
//  Article.swift
//  NewsLater
//
//  Created by University of Missouri on 4/16/15.
//  Copyright (c) 2015 Matt Zuzolo. All rights reserved.
//

import Foundation

//Our Basic Story
struct Article{
    var headline: NSString
    var byline: NSString
    //var abstract: NSString
    var publishedDate: NSString
    var url: NSString
    var thumbnailUrl: NSString //Points to the Thumbnail object
    //var mediaUrls: Array<NSString>
    var tags: Array<NSString>
}