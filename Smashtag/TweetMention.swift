//
//  TweetMention.swift
//  Smashtag
//
//  Created by Mohak Shah on 17/09/16.
//  Copyright © 2016 Mohak Shah. All rights reserved.
//

import Foundation
import CoreData


class TweetMention: NSManagedObject {
    class func addMentionWithKeyword(keyword: String,
                                     inManagedObjectContext context: NSManagedObjectContext) -> TweetMention?
    {
        let request = NSFetchRequest(entityName: "TweetMention")
        request.predicate = NSPredicate(format: "keyword =[c] %@", keyword)
        
        if let tweetMention = (try? context.executeFetchRequest(request))?.first as? TweetMention {
            return tweetMention
        } else if let newTweetMention =
            NSEntityDescription.insertNewObjectForEntityForName("TweetMention", inManagedObjectContext: context) as? TweetMention
        {
            newTweetMention.keyword = keyword
            return newTweetMention
        }
        
        return nil
    }
    
    class func removeOrphanedTweetMentions(inManagedObjectContext context: NSManagedObjectContext) -> Int {
        var orphansRemoved = 0
        let request = NSFetchRequest(entityName: "TweetMention")
        request.predicate = NSPredicate(format: "tweets.@count = 0")
        
        if let mentions = (try? context.executeFetchRequest(request)) as? [TweetMention] {
            orphansRemoved = mentions.count
            
            for orphan in mentions {
                context.deleteObject(orphan)
            }
        }
        
        return orphansRemoved
    }

}
