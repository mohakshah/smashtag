//
//  CDTweet.swift
//  Smashtag
//
//  Created by Mohak Shah on 17/09/16.
//  Copyright © 2016 Mohak Shah. All rights reserved.
//

import Foundation
import CoreData
import Twitter


class CDTweet: NSManagedObject {
    class func addTweetWithInfo(tweetInfo: Tweet,
                                inManagedObjectContext context: NSManagedObjectContext) -> CDTweet? {
        let request = NSFetchRequest(entityName: "CDTweet")
        request.predicate = NSPredicate(format: "id = %@", tweetInfo.id)
        
        if let tweet = (try? context.executeFetchRequest(request))?.first as? CDTweet {
            return tweet
        } else if let tweet = NSEntityDescription.insertNewObjectForEntityForName("CDTweet", inManagedObjectContext: context) as? CDTweet {
            tweet.id = tweetInfo.id
            // add user mentions
            for mention in tweetInfo.userMentions {
                if let tweetMention = TweetMention.addMentionWithKeyword(mention.keyword, inManagedObjectContext: context) {
                    tweetMention.tweets = tweetMention.tweets?.setByAddingObject(tweet) ?? NSSet(object: tweet)
                }
            }
            
            // add hashtags
            for mention in tweetInfo.hashtags {
                if let tweetMention = TweetMention.addMentionWithKeyword(mention.keyword, inManagedObjectContext: context) {
                    tweetMention.tweets = tweetMention.tweets?.setByAddingObject(tweet) ?? NSSet(object: tweet)
                }
            }
            
            return tweet
        }
        
        return nil
    }
    
    class func removeOrphanTweets(inManagedObjectContext context: NSManagedObjectContext) -> Int {
        var orphansRemoved = 0
        let request = NSFetchRequest(entityName: "CDTweet")
        request.predicate = NSPredicate(format: "searches.@count = 0")
        
        if let orphanedTweets = (try? context.executeFetchRequest(request)) as? [CDTweet] {
            orphansRemoved = orphanedTweets.count
            
            for orphan in orphanedTweets {
                context.deleteObject(orphan)
            }
        }
        
        return orphansRemoved
    }
}
