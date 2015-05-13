//
//  AppDelegate.swift
//  NewsLater
//
//  Created by Matthew Zuzolo on 4/14/15.
//  Copyright (c) 2015 Matt Zuzolo. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    private var readArticles:[Article]? = Array<Article>()
    private var recentlyRead:[Article]? = Array<Article>()
    
    var articlesFile = ""
    var recentlyReadFile = ""
    let fileMgr = NSFileManager.defaultManager()
    let secPerThreeDays: NSTimeInterval = 60 * 60 * 24 * 3
    var dateFormatterNYT = NSDateFormatter()
    var dateFormatterTG = NSDateFormatter()
    
    //View pointer for the feed so we can reload on open from background
    var newsLaterFeedView : NewsLaterFeedController?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        
        articlesFile = (dirPaths[0] as! String) + "/read_articles.txt"
        recentlyReadFile = (dirPaths[0] as! String) + "/recently_read.txt"
        
        readArticles = loadArticles(articlesFile)
        recentlyRead = loadArticles(recentlyReadFile)
        
        initDateFormatters()
        
        //for local notification
        if(UIApplication.instancesRespondToSelector(Selector("registerUserNotificationSettings:"))) {
            UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: .Alert | .Badge, categories: nil))
        }
        
        return true
    
    }
    
    func loadArticles(file: String) -> [Article]?{
        var readError:NSError?
        let data = NSData(contentsOfFile:file,
            options: NSDataReadingOptions.DataReadingUncached,
            error:&readError)
        
        if (data == nil || data?.length == 0){
            return Array<Article>()
        }
        else{
            let articles = NSKeyedUnarchiver.unarchiveObjectWithData(data!) as! [Article]?
            
            if (articles != nil){
                return articles
            }
            else {
                return nil
            }
        }
    }
    
    func initDateFormatters(){
        dateFormatterNYT.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'-5:00'"
        dateFormatterNYT.locale = NSLocale(localeIdentifier: "US_en_POSIX")
        
        dateFormatterTG.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatterTG.locale = NSLocale(localeIdentifier: "US_en_POSIX")
    }
    

    func saveArticles(articles: [Article]?, file: String){
        if (articles != nil){
            let data = NSKeyedArchiver.archivedDataWithRootObject(articles!)
            
            if (data.length == 0){
                println("Empty data")
            }
            let success = data.writeToFile(file, atomically: true)
        }
    }
    
    func getRecentlyRead() -> [Article]?{
        return recentlyRead
    }
    
    func getReadArticles() -> [Article]?{
        return readArticles
    }
    
    func getReadArticlesHeadlines() -> Set<String>{
        if(readArticles != nil){
            var headlines = Set<String>()
            for article in readArticles!{
                headlines.insert(article.headline!)
            }
            return headlines
        } else {
            return Set<String>()
        }
    }
    
    func addRecentlyReadArticle(newArticle: Article){
        for article in recentlyRead!{
            if article.headline! == newArticle.headline{
                return
            }
        }
        recentlyRead?.append(newArticle)
        
        if (recentlyRead?.count > 10){
            recentlyRead!.removeAtIndex(0)
        }
        saveArticles(recentlyRead, file: recentlyReadFile)
    }
    
    func addReadArticles(newArticle: Article){
        readArticles?.append(newArticle)
        saveArticles(readArticles, file: articlesFile)
        trimArticles(readArticles)
    }
    
    func trimArticles(var articles: [Article]?){
        if articles != nil{
            for var i = 0; i < articles!.count; i++ {
                if articles![i].receivedDate.timeIntervalSinceNow > secPerThreeDays {
                    articles!.removeAtIndex(i)
                }
            }
        }
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        application.applicationIconBadgeNumber = 0
        //NSNotificationCenter.defaultCenter().postNotificationName("NotificationIdentifier", object: nil)
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        //Uncomment this stuff if you want to test date driven stuff
        /*let calendar = NSCalendar.currentCalendar()
        
        let components = calendar.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay, fromDate: NSDate())
        components.day -= 22
        
        let date = calendar.dateFromComponents(components)
        newsLaterFeedView!.defaults.setObject(date, forKey: "lastReadNews")*/
        
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        saveArticles(readArticles, file: articlesFile)
        saveArticles(recentlyRead, file: recentlyReadFile)
        
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        application.applicationIconBadgeNumber = 0
    }


}

