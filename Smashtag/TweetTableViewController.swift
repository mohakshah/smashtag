//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by Mohak Shah on 22/08/16.
//  Copyright © 2016 Mohak Shah. All rights reserved.
//

import UIKit
import Twitter
import CoreData

class TweetTableViewController: UITableViewController, UITextFieldDelegate {
    
    // model
    var tweets = [Array<Twitter.Tweet>] () {
        didSet {
            tableView.reloadData()
        }
    }
    
    var searchString: String? {
        didSet {
            tweets.removeAll()
            searchForTweets()
            title = searchString
            addSearchStringToRecentSearches()
        }
    }
    
    var searchFilters = " -filter:retweets"
    
    /*
     * searches the standard user defaults for the recent queries and updates the list to include the current
     * query. Also removes any duplicates and trims the list down to the 100 most recent searches
     */
    private func addSearchStringToRecentSearches() {
        if let searchString = self.searchString {
            if var queries  = RecentQueries.list {
                
                // remove duplicates
                var i = 0
                while i < queries.count {
                    if queries[i].caseInsensitiveCompare(searchString) == .OrderedSame {
                        queries.removeAtIndex(i)
                        i -= 1
                    }
                    i += 1
                }
                
                // add the new query
                queries.insert(searchString, atIndex: 0)
                
                // save to user defaults
                RecentQueries.list = queries
            } else {
                // since there are no existing queries in the history, just add the current one
                // as an array containing 1 element
                RecentQueries.list = [searchString]
            }
        }
    }
    
    // returns a Twitter.Request object constructed from the searchString
    private var twitterRequest: Twitter.Request? {
        if let query = searchString where !query.isEmpty {
            return Request(search: query + searchFilters, count: 100)
        }
        
        return nil
    }
    
    private var lastTwitterRequest: Twitter.Request?
    
    // asynchronously searches for tweets
    private func searchForTweets() {
        if let request = twitterRequest {
            lastTwitterRequest = request
            
            request.fetchTweets { [weak weakSelf = self] (newTweets) in
                // insert results on the main queue
                dispatch_async(dispatch_get_main_queue()) {
                    if request == weakSelf?.lastTwitterRequest {
                        weakSelf?.tweets.insert(newTweets, atIndex: 0)
                    }
                }
                
                // save tweets on this queue
                if request == weakSelf?.lastTwitterRequest {
                    weakSelf?.saveSearchResultsToDb(weakSelf!.searchString!, newTweets: newTweets)
                }
            }
        }
    }
    
    private func saveSearchResultsToDb(searchString: String, newTweets: [Tweet]) {
        if let moc = TweetsDB.moc {
            moc.performBlock {
                Search.addTweetsToSearch(searchString, tweets: newTweets, inManagedObjectContext: moc)
                
                TweetsDB.printStats()
            }
        } else {
            print("Could not get the moc")
        }
    }
    
    
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
            searchTextField.text = searchString
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // only consider if the user has entered a non-empty string
        if let userInput = textField.text {
            if userInput.isEmpty {
                return false
            }
            
            textField.resignFirstResponder()
            searchString = userInput
            return true
        }
        
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !isRootOfNavigationVC {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Home", style: .Plain, target: self, action: #selector(self.popToHome))
        }
        
        // make the toolbar transparent
        if let navVC = navigationController {
            navVC.toolbar.translucent = true
            navVC.toolbar.setShadowImage(UIImage(), forToolbarPosition: .Bottom)
            navVC.toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .Bottom, barMetrics: .Default)
        
            // display it
            navVC.toolbarHidden = false
        }
        
        let cameraButton = UIBarButtonItem(barButtonSystemItem: .Camera, target: self, action: #selector(self.browsePhotos))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        toolbarItems = [flexibleSpace, cameraButton]
        
        if searchString == nil {
            searchString = "#500px"
        }
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func browsePhotos() {
        performSegueWithIdentifier("BrowsePhotos", sender: nil)
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "BrowsePhotos" {
            if let pcvc = segue.destinationViewController as? PhotoCollectionViewController {
                var mediaItems = [MediaItem]()
                for tweet in tweets.flatten() {
                    mediaItems.appendContentsOf(tweet.media)
                }
                
                pcvc.mediaItems = mediaItems
            }
        } else if let cell = sender as? TweetTableViewCell {
            if let tweetDetailVC = segue.destinationViewController as? TweetDetailViewController {
                // set the model of the detail vc
                tweetDetailVC.tweet = cell.tweet
            }
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tweets.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count
    }
    
    let reusableCellIdentifier = "TweetCell"

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reusableCellIdentifier, forIndexPath: indexPath)
        let tweet = tweets[indexPath.section][indexPath.row]
        if let tweetCell = cell as? TweetTableViewCell {
            tweetCell.tweet = tweet
        }
        
        return cell
    }
}
