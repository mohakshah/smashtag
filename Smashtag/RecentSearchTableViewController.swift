//
//  RecentSearchTableViewController.swift
//  Smashtag
//
//  Created by Mohak Shah on 26/08/16.
//  Copyright © 2016 Mohak Shah. All rights reserved.
//

import UIKit

class RecentSearchTableViewController: UITableViewController {
    
    // model
    var recentSearches = [String]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    private let standardUserDefaults = NSUserDefaults.standardUserDefaults()
    
    // refresh query list whenever the view is about to appear
    override func viewWillAppear(animated: Bool) {
        retrieveQueryList()
    }
    
    private func retrieveQueryList() {
        if let queries = standardUserDefaults.objectForKey(UserDefaultsKeys.recentQueries) as? [String] {
            recentSearches = queries
        } else {
            print("Could not get the queries from user defaults")
        }
    }
    
    private func saveQueryList() {
        standardUserDefaults.setObject(recentSearches, forKey: UserDefaultsKeys.recentQueries)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentSearches.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PlainTextCell", forIndexPath: indexPath)

        // Configure the cell...
        cell.textLabel?.text = recentSearches[indexPath.row]

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("ReSearch", sender: recentSearches[indexPath.row])
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let tweetTableVC = segue.destinationViewController as? TweetTableViewController where segue.identifier == "ReSearch" {
            if let searchTerm = sender as? String {
                // Set the search string of the vc
                tweetTableVC.searchString = searchTerm
            }
        }
    }
    
     // Override to support editing the table view.
//    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        if editingStyle == .Delete {
//            // Delete the row from the data source
//            recentSearches.removeAtIndex(indexPath.row)
//            saveQueryList()
//        }
//    }

}