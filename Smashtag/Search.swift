//
//  Search.swift
//  Smashtag
//
//  Created by Mohak Shah on 17/09/16.
//  Copyright © 2016 Mohak Shah. All rights reserved.
//

import Foundation
import CoreData
import Twitter


class Search: NSManagedObject {
    private static let tweetPileSize = 10
    
    class func addTweetsToSearch(searchTerm: String, tweets: [Tweet], inManagedObjectContext context: NSManagedObjectContext)
    {
        if tweets.count < 1 {
            return
        }
        
        if let search = searchWithTerm(searchTerm, inManagedObjectContext: context) {
            var i = 0
            var noOfPilesThatExist = 0
            
            while i < tweets.count {
                var upperLimit = i + tweetPileSize
                if upperLimit > tweets.count {
                    upperLimit = tweets.count
                }
                
                let tweetPile = [Tweet](tweets[i..<upperLimit])
                
                // only try to add tweets in the piles which are not in the search already
                if !tweetsExistInSearch(tweetIds: tweetPile.map {$0.id},
                                        search: search,
                                        inManagedObjectContext: context)
                {
                    for tweet in tweetPile {
                        if let cdTweet = CDTweet.addTweetWithInfo(tweet, inManagedObjectContext: context) {
                            // add the CDTweet to the Search object if it hasn't been already
                            if !(search.tweets?.containsObject(cdTweet) ?? false)  {
                                search.tweets = search.tweets?.setByAddingObject(cdTweet) ?? NSSet(object: cdTweet)
                                
                                // add the mentions in the tweet to the Search Object
                                var mentions = Array<Mention>(tweet.userMentions)
                                mentions.appendContentsOf(tweet.hashtags)
                                
                                for mention in mentions {
                                    if let searchMention = getMentionForSearch(mention,
                                                                               searchItem: search,
                                                                               inManagedContext: context)
                                    {
                                        searchMention.count = NSNumber(longLong: (searchMention.count?.integerValue ?? 0) + 1)
                                    }
                                }
                            }
                        }
                    }
                } else {
                    noOfPilesThatExist += 1
                }
                
                i += 10
            }
            
            print("\(noOfPilesThatExist) piles of tweets were skipped")
            
        }
    }
    
    class func searchWithTerm(searchTerm: String, inManagedObjectContext context: NSManagedObjectContext) -> Search?
    {
        let request = NSFetchRequest(entityName: "Search")
        request.predicate = NSPredicate(format: "term =[c] %@", searchTerm)
        
        if let search = (try? context.executeFetchRequest(request))?.first as? Search {
            return search
        } else if let search = NSEntityDescription
                                .insertNewObjectForEntityForName("Search",
                                                                 inManagedObjectContext: context) as? Search
        {
            search.term = searchTerm
            return search
        }
        
        return nil
    }
    
    // note: will not delete associated cdTweets
    class func removeSearchesAndRelatedData(searchTerms: [String],
                                            inManagedObjectContext context: NSManagedObjectContext) -> Int
    {
        var deleteCount = 0
        for searchTerm in searchTerms {
            if let search = searchWithTerm(searchTerm, inManagedObjectContext: context) {
                
                // delete self
                context.deleteObject(search)
                deleteCount += 1
            }
        }
        
        return deleteCount
    }
    
    // deletes the search terms that do not match the
    // terms passed in th array
    // note: will not delete associated cdTweets
    class func removeAllSearchesBut(searchTermsToKeep: [String]?,
                                            inManagedObjectContext context: NSManagedObjectContext) -> Int
    {
        var deleteCount = 0
        
        let request = NSFetchRequest(entityName: "Search")
        if let searchTerms = searchTermsToKeep {
            request.predicate = NSPredicate(format: "NOT (term IN %@)", searchTerms)
        } else {
            request.predicate = NSPredicate(format: "ALL")
        }
        
        if let searchesToDelete = (try? context.executeFetchRequest(request)) as? [Search] {
            deleteCount = searchesToDelete.count
            
            for search in searchesToDelete {
                context.deleteObject(search)
            }
        }
        
        return deleteCount
    }
    
    private class func tweetsExistInSearch(tweetIds ids: [String],
                                    search: Search,
                                    inManagedObjectContext context: NSManagedObjectContext) -> Bool
    {
        let request = NSFetchRequest(entityName: "CDTweet")
        request.predicate = NSPredicate(format: "%@ in searches && id in %@",search, ids)
        
        if context.countForFetchRequest(request, error: nil) == ids.count {
            return true
        }
        
        return false
    }
    
    private class func getMentionForSearch(twitterMention: Twitter.Mention,
                                           searchItem: Search,
                                           inManagedContext context: NSManagedObjectContext) -> SearchMention?
    {
        let request = NSFetchRequest(entityName: "SearchMention")
        request.predicate = NSPredicate(format: "keyword =[c] %@ && search.term = %@", twitterMention.keyword, searchItem.term!)
        
        if let mention = (try? context.executeFetchRequest(request))?.first as? SearchMention {
            return mention
        } else if let newMention = SearchMention.addNewSearchMentionWithInfo(twitterMention, inManagedObjectContext: context) {
            newMention.search = searchItem
            return newMention
        }
        
        return nil
    }

}
