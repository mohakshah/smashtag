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
    
    // refresh query list whenever the view is about to appear
    override func viewWillAppear(animated: Bool) {
        retrieveQueryList()
    }
    
    override func viewDidLoad() {
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        // make the toolbar transparent
        if let navVC = navigationController {
            navVC.toolbar.translucent = true
            navVC.toolbar.setShadowImage(UIImage(), forToolbarPosition: .Bottom)
            navVC.toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .Bottom, barMetrics: .Default)
            
            // display it
            navVC.toolbarHidden = false
        }
    }
    
    private func retrieveQueryList() {
        if let queries = RecentQueries.list {
            recentSearches = queries
        } else {
            print("Could not get the queries from user defaults")
        }
    }
    
    private func saveQueryList() {
        RecentQueries.list = recentSearches
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
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("Mentions In Search", sender: recentSearches[indexPath.row])
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let tweetTableVC = segue.destinationViewController as? TweetTableViewController where segue.identifier == "ReSearch" {
            if let searchTerm = sender as? String {
                // Set the search string of the vc
                tweetTableVC.searchString = searchTerm
            }
        } else if let mentionsTableVC = segue.destinationViewController as? MentionsTableViewController
            where segue.identifier == "Mentions In Search" {
            if let searchTerm = sender as? String {
                // initialize this vc
                mentionsTableVC.searchString = searchTerm
            }
        }
    }
    
    
    
     // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            recentSearches.removeAtIndex(indexPath.row)
            saveQueryList()
        }
    }
}
