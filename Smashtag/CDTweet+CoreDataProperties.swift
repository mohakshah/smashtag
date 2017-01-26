//
//  CDTweet+CoreDataProperties.swift
//  Smashtag
//
//  Created by Mohak Shah on 17/09/16.
//  Copyright © 2016 Mohak Shah. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension CDTweet {

    @NSManaged var id: String?
    @NSManaged var searches: NSSet?
    @NSManaged var mentions: NSSet?

}
