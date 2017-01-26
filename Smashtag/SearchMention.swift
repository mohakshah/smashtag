//
//  SearchMention.swift
//  Smashtag
//
//  Created by Mohak Shah on 17/09/16.
//  Copyright © 2016 Mohak Shah. All rights reserved.
//

import Foundation
import CoreData
import Twitter


class SearchMention: NSManagedObject {
    private struct MentionTypes {
        static let HashTag = "HashTag"
        static let UserMention = "UserMention"
        static let Unknown = ""
    }
    class func addNewSearchMentionWithInfo(mentionInfo: Twitter.Mention,
                                        inManagedObjectContext context: NSManagedObjectContext) -> SearchMention? {
        if let newSearchMention = NSEntityDescription.insertNewObjectForEntityForName("SearchMention", inManagedObjectContext: context) as? SearchMention
        {
            newSearchMention.count = 0
            newSearchMention.keyword = mentionInfo.keyword
            
            if (mentionInfo.keyword.hasPrefix("@")) {
                newSearchMention.type = MentionTypes.UserMention
            } else if (mentionInfo.keyword.hasPrefix("#")) {
                newSearchMention.type = MentionTypes.HashTag
            } else {
                newSearchMention.type = MentionTypes.Unknown
            }
            
            return newSearchMention
        }
        return nil
    }
}
