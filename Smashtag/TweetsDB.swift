//
//  TweetsDB.swift
//  Smashtag
//
//  Created by Mohak Shah on 18/09/16.
//  Copyright © 2016 Mohak Shah. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class TweetsDB {
    static private let baseName = "tweets-db"
    
    static private var _moc: NSManagedObjectContext? {
        didSet {
            if _moc != nil {
                prune()
            }
        }
    }
    
    class var moc: NSManagedObjectContext? {
        if _moc == nil {
            // create a new NSManagedObjectContext
            let fm = NSFileManager.defaultManager()
            if let myDocsDir = fm.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first {
                let url = myDocsDir.URLByAppendingPathComponent(TweetsDB.baseName)
                let document = UIManagedDocument(fileURL: url)
                
                switch document.documentState {
                case UIDocumentState.Normal:
                    _moc = document.managedObjectContext
                    
                case UIDocumentState.Closed:
                    if let path = url.path {
                        let fileExists = fm.fileExistsAtPath(path)
                        if fileExists {
                            // openWithCompletionHandler has to be called on the main queue
                            dispatch_async(dispatch_get_main_queue()) {
                                document.openWithCompletionHandler() { (success) in
                                    if success {
                                        TweetsDB._moc = document.managedObjectContext
                                    }
                                }
                            }
                        } else {
                            // saveToURL has to be called on the main queue
                            dispatch_async(dispatch_get_main_queue()) {
                                document.saveToURL(document.fileURL, forSaveOperation: .ForCreating) { (success) in
                                    if success {
                                        TweetsDB._moc = document.managedObjectContext
                                    }
                                }
                            }
                        }
                    }
                default:
                    // not handling other conditions yet
                    break
                }
            }
        }
        
        return _moc
    }
    
    private static let waitTimeForMOC = USEC_PER_SEC / 10
    class func prune() {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)) {
            print("Pruning Status: ")
            if let context = _moc?.parentContext {
                context.performBlock {
                    // cleanup the database
                    let deleteCount = Search.removeAllSearchesBut(RecentQueries.list, inManagedObjectContext: context)
                    print("\(deleteCount) searches deleted")
                    
                    let tweetsRemoved = CDTweet.removeOrphanTweets(inManagedObjectContext: context)
                    let tweetMentionsRemoved = TweetMention.removeOrphanedTweetMentions(inManagedObjectContext: context)
                    
                    print("Removed \(tweetsRemoved) orphaned tweets")
                    print("Removed \(tweetMentionsRemoved) orphaned tweet mentions")
                }
            }
        }
        
    }
    
    class func printStats() {
        if let context = moc {
            let tweetCount = context.countForFetchRequest(NSFetchRequest(entityName: "CDTweet"), error: nil)
            print("\(tweetCount) tweets in the database")
            
            let searchCount = context.countForFetchRequest(NSFetchRequest(entityName: "Search"), error: nil)
            print("\(searchCount) searches in the database")
            
            let mentionCount = context.countForFetchRequest(NSFetchRequest(entityName: "SearchMention"), error: nil)
            print("\(mentionCount) mentions in the database")
            
            let tweetMentionCount = context.countForFetchRequest(NSFetchRequest(entityName: "TweetMention"), error: nil)
            print("\(tweetMentionCount) tweet mentions in the database")
        }
    }
}